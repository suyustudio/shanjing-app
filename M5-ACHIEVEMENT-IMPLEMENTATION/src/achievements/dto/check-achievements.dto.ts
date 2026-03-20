export class TrailStatsDto {
  distance: number;
  duration: number;
  isNight: boolean;
  isRain: boolean;
  isSolo: boolean;
}

export class CheckAchievementsDto {
  triggerType: 'trail_completed' | 'share' | 'manual';
  trailId?: string;
  stats?: TrailStatsDto;
}
