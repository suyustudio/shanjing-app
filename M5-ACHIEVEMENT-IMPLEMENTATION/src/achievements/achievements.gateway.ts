import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  OnGatewayConnection,
  OnGatewayDisconnect,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { Logger, UseGuards } from '@nestjs/common';
import { WsJwtGuard } from '../auth/guards/ws-jwt.guard';

interface AchievementUnlockedPayload {
  achievementId: string;
  level: string;
  name: string;
  message: string;
  badgeUrl: string;
}

@WebSocketGateway({
  namespace: 'achievements',
  cors: {
    origin: '*',
  },
})
@UseGuards(WsJwtGuard)
export class AchievementsGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  private readonly logger = new Logger(AchievementsGateway.name);
  private readonly userSockets: Map<string, string[]> = new Map();

  handleConnection(client: Socket) {
    try {
      const userId = client.handshake.auth.userId as string;
      
      if (!userId) {
        this.logger.warn('Connection attempt without userId');
        client.disconnect();
        return;
      }

      // 将 socket 与用户关联
      if (!this.userSockets.has(userId)) {
        this.userSockets.set(userId, []);
      }
      this.userSockets.get(userId).push(client.id);

      client.join(`user:${userId}`);
      this.logger.log(`User ${userId} connected to achievements namespace`);
    } catch (error) {
      this.logger.error('Connection error:', error);
      client.disconnect();
    }
  }

  handleDisconnect(client: Socket) {
    try {
      const userId = client.handshake.auth.userId as string;
      
      if (userId && this.userSockets.has(userId)) {
        const sockets = this.userSockets.get(userId);
        const index = sockets.indexOf(client.id);
        
        if (index > -1) {
          sockets.splice(index, 1);
        }

        if (sockets.length === 0) {
          this.userSockets.delete(userId);
        }
      }

      this.logger.log(`Client ${client.id} disconnected`);
    } catch (error) {
      this.logger.error('Disconnect error:', error);
    }
  }

  /**
   * 发送成就解锁通知
   */
  sendAchievementUnlocked(userId: string, payload: AchievementUnlockedPayload): void {
    this.server.to(`user:${userId}`).emit('achievement:unlocked', payload);
    this.logger.log(`Sent achievement unlocked notification to user ${userId}`);
  }

  /**
   * 发送成就进度更新
   */
  sendProgressUpdate(
    userId: string,
    payload: {
      achievementId: string;
      progress: number;
      requirement: number;
      percentage: number;
    },
  ): void {
    this.server.to(`user:${userId}`).emit('achievement:progress', payload);
  }

  /**
   * 检查用户是否在线
   */
  isUserOnline(userId: string): boolean {
    return this.userSockets.has(userId) && this.userSockets.get(userId).length > 0;
  }

  @SubscribeMessage('achievements:subscribe')
  handleSubscribe(client: Socket): void {
    const userId = client.handshake.auth.userId as string;
    
    if (userId) {
      client.join(`user:${userId}`);
      client.emit('achievements:subscribed', { success: true });
    }
  }

  @SubscribeMessage('achievements:markViewed')
  async handleMarkViewed(
    client: Socket,
    payload: { achievementId: string },
  ): Promise<void> {
    const userId = client.handshake.auth.userId as string;
    
    if (userId && payload.achievementId) {
      // 这里可以调用 service 来标记已查看
      client.emit('achievements:marked', {
        achievementId: payload.achievementId,
        success: true,
      });
    }
  }
}
