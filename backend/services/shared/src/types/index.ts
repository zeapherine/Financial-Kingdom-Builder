// Common User Types
export interface User {
  id: string;
  email: string;
  username: string;
  tier: number;
  createdAt: Date;
  updatedAt: Date;
}

export interface UserProfile extends User {
  firstName?: string;
  lastName?: string;
  avatar?: string;
  kingdomLevel: number;
  totalXp: number;
  currentStreak: number;
}

// Trading Types
export interface Portfolio {
  userId: string;
  totalValue: number;
  availableBalance: number;
  totalPnL: number;
  positions: Position[];
}

export interface Position {
  id: string;
  symbol: string;
  quantity: number;
  averagePrice: number;
  currentPrice: number;
  unrealizedPnL: number;
  type: 'long' | 'short';
}

export interface Order {
  id: string;
  userId: string;
  symbol: string;
  side: 'buy' | 'sell';
  type: 'market' | 'limit' | 'stop';
  quantity: number;
  price?: number;
  status: 'pending' | 'filled' | 'cancelled' | 'rejected';
  createdAt: Date;
  filledAt?: Date;
}

// Gamification Types
export interface Achievement {
  id: string;
  name: string;
  description: string;
  icon: string;
  rarity: 'common' | 'rare' | 'epic' | 'legendary';
  xpReward: number;
  unlockCondition: string;
}

export interface UserAchievement {
  userId: string;
  achievementId: string;
  unlockedAt: Date;
  progress: number;
  completed: boolean;
}

export interface LeaderboardEntry {
  userId: string;
  username: string;
  avatar?: string;
  score: number;
  rank: number;
  kingdomLevel: number;
}

// Education Types
export interface EducationModule {
  id: string;
  title: string;
  description: string;
  tier: number;
  category: 'financial-literacy' | 'risk-management' | 'technical-analysis' | 'trading-psychology';
  difficulty: 'beginner' | 'intermediate' | 'advanced';
  estimatedDuration: number; // minutes
  xpReward: number;
  prerequisites: string[];
  content: ModuleContent[];
  version: number;
  status: 'draft' | 'published' | 'archived';
  createdAt: Date;
  updatedAt: Date;
  createdBy: string;
  publishedAt?: Date;
  scheduledAt?: Date;
  tags: string[];
  analytics: ModuleAnalytics;
}

export interface ModuleContent {
  id: string;
  type: 'text' | 'video' | 'quiz' | 'interactive' | 'image';
  title: string;
  content: string;
  duration?: number;
  order: number;
  metadata?: ContentMetadata;
}

export interface ContentMetadata {
  videoUrl?: string;
  imageUrl?: string;
  altText?: string;
  thumbnailUrl?: string;
  fileSize?: number;
  mimeType?: string;
  quizConfig?: QuizConfig;
}

export interface QuizConfig {
  questions: QuizQuestion[];
  passingScore: number;
  timeLimit?: number; // minutes
  allowRetry: boolean;
  maxAttempts: number;
}

export interface QuizQuestion {
  id: string;
  type: 'multiple-choice' | 'true-false' | 'fill-blank' | 'drag-drop';
  question: string;
  options?: string[];
  correctAnswer: string | string[];
  explanation: string;
  points: number;
}

export interface UserProgress {
  userId: string;
  moduleId: string;
  progress: number; // 0-100
  completed: boolean;
  lastAccessed: Date;
  startedAt: Date;
  completedAt?: Date;
  quizAttempts: QuizAttempt[];
  timeSpent: number; // minutes
  contentProgress: ContentProgress[];
}

export interface QuizAttempt {
  id: string;
  attemptNumber: number;
  score: number;
  maxScore: number;
  passed: boolean;
  answers: QuizAnswer[];
  startedAt: Date;
  completedAt: Date;
  timeSpent: number;
}

export interface QuizAnswer {
  questionId: string;
  answer: string | string[];
  isCorrect: boolean;
  points: number;
}

export interface ContentProgress {
  contentId: string;
  completed: boolean;
  timeSpent: number;
  lastAccessed: Date;
}

export interface ModuleAnalytics {
  totalViews: number;
  completionRate: number;
  averageScore: number;
  averageTimeSpent: number;
  retryRate: number;
  dropOffPoints: DropOffPoint[];
  lastUpdated: Date;
}

export interface DropOffPoint {
  contentId: string;
  dropOffRate: number;
  averageTimeBeforeDropOff: number;
}

export interface EducationCategory {
  id: string;
  name: string;
  description: string;
  icon: string;
  color: string;
  order: number;
  parentId?: string;
  isActive: boolean;
}

export interface ContentVersion {
  id: string;
  moduleId: string;
  version: number;
  changes: string[];
  createdBy: string;
  createdAt: Date;
  content: ModuleContent[];
}

export interface ABTestConfig {
  id: string;
  name: string;
  description: string;
  moduleId: string;
  variants: ABTestVariant[];
  trafficSplit: number; // percentage
  startDate: Date;
  endDate?: Date;
  status: 'draft' | 'running' | 'completed' | 'paused';
  metrics: ABTestMetrics;
}

export interface ABTestVariant {
  id: string;
  name: string;
  content: ModuleContent[];
  trafficPercentage: number;
}

export interface ABTestMetrics {
  totalParticipants: number;
  completionRates: Record<string, number>; // variantId -> completion rate
  averageScores: Record<string, number>;
  conversionRates: Record<string, number>;
}

// Social Types
export interface Message {
  id: string;
  senderId: string;
  receiverId: string;
  content: string;
  type: 'text' | 'image' | 'trade-share';
  createdAt: Date;
  readAt?: Date;
}

export interface Friendship {
  id: string;
  requesterId: string;
  receiverId: string;
  status: 'pending' | 'accepted' | 'declined' | 'blocked';
  createdAt: Date;
  acceptedAt?: Date;
}

// Notification Types
export interface NotificationPreferences {
  userId: string;
  pushEnabled: boolean;
  emailEnabled: boolean;
  categories: {
    trading: boolean;
    education: boolean;
    social: boolean;
    achievements: boolean;
    system: boolean;
  };
}

export interface PushNotification {
  id: string;
  userId: string;
  title: string;
  message: string;
  category: 'trading' | 'education' | 'social' | 'achievements' | 'system';
  data?: Record<string, any>;
  sentAt: Date;
  readAt?: Date;
}

// API Response Types
export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
  timestamp: string;
}

export interface PaginatedResponse<T> extends ApiResponse<T[]> {
  pagination: {
    page: number;
    limit: number;
    total: number;
    pages: number;
  };
}

// Service Health Types
export interface ServiceHealth {
  status: 'healthy' | 'unhealthy';
  service: string;
  version: string;
  uptime: number;
  timestamp: string;
  dependencies?: Record<string, 'healthy' | 'unhealthy'>;
}