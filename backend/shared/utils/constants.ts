// Kingdom Tier Constants
export const KINGDOM_TIERS = {
  VILLAGE: 1,
  TOWN: 2,
  CITY: 3,
  KINGDOM: 4,
} as const;

export const TIER_NAMES = {
  [KINGDOM_TIERS.VILLAGE]: 'Village Foundations',
  [KINGDOM_TIERS.TOWN]: 'Town Development',
  [KINGDOM_TIERS.CITY]: 'City Expansion',
  [KINGDOM_TIERS.KINGDOM]: 'Kingdom Mastery',
} as const;

// XP and Level Constants
export const XP_MULTIPLIER = 100;
export const LEVEL_XP_BASE = 1000;

export const calculateXpForLevel = (level: number): number => {
  return LEVEL_XP_BASE * level * XP_MULTIPLIER;
};

export const calculateLevelFromXp = (xp: number): number => {
  return Math.floor(Math.sqrt(xp / LEVEL_XP_BASE));
};

// Trading Constants
export const VIRTUAL_STARTING_BALANCE = 10000;

export const POSITION_SIZE_LIMITS = {
  [KINGDOM_TIERS.VILLAGE]: { maxPercent: 100, virtual: true },
  [KINGDOM_TIERS.TOWN]: { maxPercent: 20, virtual: false },
  [KINGDOM_TIERS.CITY]: { maxPercent: 50, virtual: false },
  [KINGDOM_TIERS.KINGDOM]: { maxPercent: 100, virtual: false },
} as const;

// Achievement Categories
export const ACHIEVEMENT_CATEGORIES = {
  TRADING: 'trading',
  EDUCATION: 'education',
  SOCIAL: 'social',
  MILESTONE: 'milestone',
  SPECIAL: 'special',
} as const;

export const ACHIEVEMENT_RARITIES = {
  COMMON: 'common',
  RARE: 'rare',
  EPIC: 'epic',
  LEGENDARY: 'legendary',
} as const;

// Education Constants
export const EDUCATION_CATEGORIES = {
  FINANCIAL_LITERACY: 'financial-literacy',
  RISK_MANAGEMENT: 'risk-management',
  TECHNICAL_ANALYSIS: 'technical-analysis',
  TRADING_PSYCHOLOGY: 'trading-psychology',
} as const;

export const DIFFICULTY_LEVELS = {
  BEGINNER: 'beginner',
  INTERMEDIATE: 'intermediate',
  ADVANCED: 'advanced',
} as const;

// Notification Categories
export const NOTIFICATION_CATEGORIES = {
  TRADING: 'trading',
  EDUCATION: 'education',
  SOCIAL: 'social',
  ACHIEVEMENTS: 'achievements',
  SYSTEM: 'system',
} as const;

// API Constants
export const API_RATE_LIMITS = {
  STANDARD: { windowMs: 15 * 60 * 1000, max: 100 },
  TRADING: { windowMs: 15 * 60 * 1000, max: 50 },
  SOCIAL: { windowMs: 15 * 60 * 1000, max: 200 },
  EDUCATION: { windowMs: 15 * 60 * 1000, max: 150 },
} as const;

// Service Ports
export const SERVICE_PORTS = {
  API_GATEWAY: 3000,
  TRADING: 3001,
  GAMIFICATION: 3002,
  EDUCATION: 3003,
  SOCIAL: 3004,
  NOTIFICATIONS: 3005,
} as const;

// Environment Constants
export const ENVIRONMENTS = {
  DEVELOPMENT: 'development',
  STAGING: 'staging',
  PRODUCTION: 'production',
} as const;

// Error Codes
export const ERROR_CODES = {
  VALIDATION_ERROR: 'VALIDATION_ERROR',
  AUTHENTICATION_ERROR: 'AUTHENTICATION_ERROR',
  AUTHORIZATION_ERROR: 'AUTHORIZATION_ERROR',
  NOT_FOUND: 'NOT_FOUND',
  INTERNAL_ERROR: 'INTERNAL_ERROR',
  RATE_LIMIT_ERROR: 'RATE_LIMIT_ERROR',
  SERVICE_UNAVAILABLE: 'SERVICE_UNAVAILABLE',
} as const;