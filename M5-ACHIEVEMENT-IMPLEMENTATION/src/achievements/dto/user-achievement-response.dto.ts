export class UserAchievementItemDto {
  achievementId: string;
  key: string;
  name: string;
  category: string;
  currentLevel: string | null;
  currentProgress: number;
  nextRequirement: number;
  percentage: number;
  unlockedAt: string | null;
  isNew: boolean;
}

export class UserAchievementResponseDto {
  totalCount: number;
  unlockedCount: number;
  newUnlockedCount: number;
  achievements: UserAchievementItemDto[];
}
