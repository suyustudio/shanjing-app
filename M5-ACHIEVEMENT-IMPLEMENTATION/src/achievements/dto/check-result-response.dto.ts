export class NewlyUnlockedDto {
  achievementId: string;
  level: string;
  name: string;
  message: string;
  badgeUrl: string;
}

export class ProgressUpdatedDto {
  achievementId: string;
  progress: number;
  requirement: number;
  percentage: number;
}

export class CheckResultResponseDto {
  newlyUnlocked: NewlyUnlockedDto[];
  progressUpdated: ProgressUpdatedDto[];
}
