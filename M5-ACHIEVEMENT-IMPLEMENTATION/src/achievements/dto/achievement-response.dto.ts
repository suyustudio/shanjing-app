export class AchievementLevelDto {
  level: string;
  requirement: number;
  name: string;
  description?: string;
  iconUrl?: string;
}

export class AchievementResponseDto {
  id: string;
  key: string;
  name: string;
  description?: string;
  category: string;
  iconUrl?: string;
  isHidden: boolean;
  sortOrder: number;
  levels: AchievementLevelDto[];
}
