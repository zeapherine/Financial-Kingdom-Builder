import bcrypt from 'bcrypt';
import { randomBytes, scrypt, timingSafeEqual } from 'crypto';
import { promisify } from 'util';
import { logger } from '../utils/logger-factory';

const scryptAsync = promisify(scrypt);

export interface PasswordConfig {
  saltRounds: number; // For bcrypt
  scryptKeylen: number; // For scrypt key length
  scryptCost: number; // For scrypt CPU/memory cost
  scryptBlockSize: number; // For scrypt block size
  scryptParallelization: number; // For scrypt parallelization
  algorithm: 'bcrypt' | 'scrypt';
}

export interface PasswordValidationResult {
  isValid: boolean;
  strength: 'weak' | 'fair' | 'good' | 'strong' | 'very-strong';
  score: number; // 0-100
  feedback: string[];
  requirements: {
    minLength: boolean;
    hasUppercase: boolean;
    hasLowercase: boolean;
    hasNumbers: boolean;
    hasSymbols: boolean;
    noCommonPatterns: boolean;
    noSequential: boolean;
  };
}

export interface HashedPassword {
  hash: string;
  algorithm: string;
  saltRounds?: number;
  params?: string; // For scrypt parameters
}

export class PasswordManager {
  private config: PasswordConfig;

  constructor(config?: Partial<PasswordConfig>) {
    this.config = {
      saltRounds: 12,
      scryptKeylen: 64,
      scryptCost: 16384, // N parameter
      scryptBlockSize: 8, // r parameter
      scryptParallelization: 1, // p parameter
      algorithm: 'bcrypt',
      ...config
    };

    this.validateConfig();
  }

  private validateConfig(): void {
    if (this.config.saltRounds < 10) {
      throw new Error('Salt rounds must be at least 10 for security');
    }

    if (this.config.scryptKeylen < 32) {
      throw new Error('Scrypt key length must be at least 32 bytes');
    }

    if (this.config.scryptCost < 16384) {
      throw new Error('Scrypt cost parameter must be at least 16384');
    }
  }

  /**
   * Hash password using configured algorithm
   */
  public async hashPassword(password: string): Promise<HashedPassword> {
    if (!password || password.length === 0) {
      throw new Error('Password cannot be empty');
    }

    const startTime = Date.now();

    try {
      if (this.config.algorithm === 'bcrypt') {
        const hash = await bcrypt.hash(password, this.config.saltRounds);
        
        logger.debug('Password hashed with bcrypt', {
          algorithm: 'bcrypt',
          saltRounds: this.config.saltRounds,
          duration: Date.now() - startTime
        });

        return {
          hash,
          algorithm: 'bcrypt',
          saltRounds: this.config.saltRounds
        };
      } else {
        // Use scrypt
        const salt = randomBytes(32);
        const derivedKey = await scryptAsync(
          password,
          salt,
          this.config.scryptKeylen
        ) as Buffer;

        const hash = `${salt.toString('hex')}:${derivedKey.toString('hex')}`;
        const params = `${this.config.scryptCost}:${this.config.scryptBlockSize}:${this.config.scryptParallelization}:${this.config.scryptKeylen}`;

        logger.debug('Password hashed with scrypt', {
          algorithm: 'scrypt',
          params,
          duration: Date.now() - startTime
        });

        return {
          hash,
          algorithm: 'scrypt',
          params
        };
      }
    } catch (error) {
      logger.error('Password hashing failed', {
        algorithm: this.config.algorithm,
        error: error instanceof Error ? error.message : 'Unknown error'
      });
      throw new Error('Password hashing failed');
    }
  }

  /**
   * Verify password against hash
   */
  public async verifyPassword(password: string, hashedPassword: HashedPassword): Promise<boolean> {
    if (!password || !hashedPassword.hash) {
      return false;
    }

    const startTime = Date.now();

    try {
      let isValid = false;

      if (hashedPassword.algorithm === 'bcrypt') {
        isValid = await bcrypt.compare(password, hashedPassword.hash);
      } else if (hashedPassword.algorithm === 'scrypt') {
        // Parse scrypt hash
        const [saltHex, keyHex] = hashedPassword.hash.split(':');
        if (!saltHex || !keyHex) {
          throw new Error('Invalid scrypt hash format');
        }

        const salt = Buffer.from(saltHex, 'hex');
        const storedKey = Buffer.from(keyHex, 'hex');

        // Parse parameters
        const params = hashedPassword.params?.split(':');
        if (!params || params.length !== 4) {
          throw new Error('Invalid scrypt parameters');
        }

        const [N, r, p, keylen] = params.map(Number);

        // Derive key with same parameters
        const derivedKey = await scryptAsync(password, salt, keylen) as Buffer;

        // Constant-time comparison
        isValid = storedKey.length === derivedKey.length && 
                 timingSafeEqual(storedKey, derivedKey);
      } else {
        throw new Error(`Unsupported algorithm: ${hashedPassword.algorithm}`);
      }

      logger.debug('Password verification completed', {
        algorithm: hashedPassword.algorithm,
        isValid,
        duration: Date.now() - startTime
      });

      return isValid;
    } catch (error) {
      logger.error('Password verification failed', {
        algorithm: hashedPassword.algorithm,
        error: error instanceof Error ? error.message : 'Unknown error'
      });
      return false;
    }
  }

  /**
   * Validate password strength and requirements
   */
  public validatePassword(password: string): PasswordValidationResult {
    const requirements = {
      minLength: password.length >= 8,
      hasUppercase: /[A-Z]/.test(password),
      hasLowercase: /[a-z]/.test(password),
      hasNumbers: /\d/.test(password),
      hasSymbols: /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(password),
      noCommonPatterns: this.checkCommonPatterns(password),
      noSequential: this.checkSequentialChars(password)
    };

    const feedback: string[] = [];
    let score = 0;

    // Length scoring
    if (password.length < 8) {
      feedback.push('Password must be at least 8 characters long');
    } else if (password.length >= 8) {
      score += 10;
    }
    if (password.length >= 12) score += 10;
    if (password.length >= 16) score += 10;

    // Character type scoring
    if (requirements.hasUppercase) score += 15;
    else feedback.push('Include at least one uppercase letter');

    if (requirements.hasLowercase) score += 15;
    else feedback.push('Include at least one lowercase letter');

    if (requirements.hasNumbers) score += 15;
    else feedback.push('Include at least one number');

    if (requirements.hasSymbols) score += 15;
    else feedback.push('Include at least one special character');

    // Pattern checking
    if (!requirements.noCommonPatterns) {
      score -= 20;
      feedback.push('Avoid common passwords and patterns');
    } else {
      score += 10;
    }

    if (!requirements.noSequential) {
      score -= 15;
      feedback.push('Avoid sequential characters (e.g., 123, abc)');
    } else {
      score += 10;
    }

    // Ensure score is within bounds
    score = Math.max(0, Math.min(100, score));

    // Determine strength
    let strength: PasswordValidationResult['strength'];
    if (score >= 90) strength = 'very-strong';
    else if (score >= 75) strength = 'strong';
    else if (score >= 60) strength = 'good';
    else if (score >= 40) strength = 'fair';
    else strength = 'weak';

    const isValid = Object.values(requirements).every(req => req === true) && score >= 60;

    return {
      isValid,
      strength,
      score,
      feedback,
      requirements
    };
  }

  /**
   * Check for common password patterns
   */
  private checkCommonPatterns(password: string): boolean {
    const commonPatterns = [
      'password', 'Password', 'PASSWORD',
      '123456', '12345678', '123456789',
      'qwerty', 'QWERTY', 'qwertyuiop',
      'admin', 'Admin', 'ADMIN',
      'user', 'User', 'USER',
      'login', 'Login', 'LOGIN',
      'welcome', 'Welcome', 'WELCOME',
      'secret', 'Secret', 'SECRET',
      'letmein', 'Letmein', 'LETMEIN'
    ];

    const lowerPassword = password.toLowerCase();
    
    // Check exact matches
    if (commonPatterns.some(pattern => lowerPassword.includes(pattern.toLowerCase()))) {
      return false;
    }

    // Check keyboard patterns
    const keyboardPatterns = [
      'qwertyuiop', 'asdfghjkl', 'zxcvbnm',
      '1234567890', '0987654321'
    ];

    if (keyboardPatterns.some(pattern => 
      lowerPassword.includes(pattern) || lowerPassword.includes(pattern.split('').reverse().join(''))
    )) {
      return false;
    }

    return true;
  }

  /**
   * Check for sequential characters
   */
  private checkSequentialChars(password: string): boolean {
    const sequences = [
      'abcdefghijklmnopqrstuvwxyz',
      '0123456789',
      'qwertyuiopasdfghjklzxcvbnm'
    ];

    const lowerPassword = password.toLowerCase();

    for (const sequence of sequences) {
      // Check for 3+ consecutive characters
      for (let i = 0; i <= sequence.length - 3; i++) {
        const substr = sequence.substring(i, i + 3);
        const reverseSubstr = substr.split('').reverse().join('');
        
        if (lowerPassword.includes(substr) || lowerPassword.includes(reverseSubstr)) {
          return false;
        }
      }
    }

    return true;
  }

  /**
   * Generate secure random password
   */
  public generatePassword(length: number = 16): string {
    if (length < 8) {
      throw new Error('Generated password must be at least 8 characters');
    }

    const uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const lowercase = 'abcdefghijklmnopqrstuvwxyz';
    const numbers = '0123456789';
    const symbols = '!@#$%^&*()_+-=[]{}|;:,.<>?';

    // Ensure at least one character from each category
    let password = '';
    password += uppercase[Math.floor(Math.random() * uppercase.length)];
    password += lowercase[Math.floor(Math.random() * lowercase.length)];
    password += numbers[Math.floor(Math.random() * numbers.length)];
    password += symbols[Math.floor(Math.random() * symbols.length)];

    // Fill the rest randomly
    const allChars = uppercase + lowercase + numbers + symbols;
    for (let i = password.length; i < length; i++) {
      password += allChars[Math.floor(Math.random() * allChars.length)];
    }

    // Shuffle the password
    return password.split('').sort(() => Math.random() - 0.5).join('');
  }

  /**
   * Check if password needs rehashing (algorithm or cost changes)
   */
  public needsRehash(hashedPassword: HashedPassword): boolean {
    // Check if algorithm changed
    if (hashedPassword.algorithm !== this.config.algorithm) {
      return true;
    }

    // Check bcrypt salt rounds
    if (this.config.algorithm === 'bcrypt') {
      return (hashedPassword.saltRounds || 0) < this.config.saltRounds;
    }

    // For scrypt, check if parameters changed
    if (this.config.algorithm === 'scrypt' && hashedPassword.params) {
      const currentParams = `${this.config.scryptCost}:${this.config.scryptBlockSize}:${this.config.scryptParallelization}:${this.config.scryptKeylen}`;
      return hashedPassword.params !== currentParams;
    }

    return false;
  }

  /**
   * Health check for password manager
   */
  public async healthCheck(): Promise<{ status: string; message: string }> {
    try {
      const testPassword = 'TestPassword123!';
      const hashed = await this.hashPassword(testPassword);
      const isValid = await this.verifyPassword(testPassword, hashed);
      
      if (!isValid) {
        throw new Error('Hash verification failed');
      }

      return {
        status: 'healthy',
        message: 'Password manager operational'
      };
    } catch (error) {
      logger.error('Password manager health check failed', {
        error: error instanceof Error ? error.message : 'Unknown error'
      });
      return {
        status: 'unhealthy',
        message: 'Password manager not operational'
      };
    }
  }
}

/**
 * Create password manager with environment configuration
 */
export function createPasswordManager(): PasswordManager {
  const config: Partial<PasswordConfig> = {
    algorithm: (process.env.PASSWORD_ALGORITHM as 'bcrypt' | 'scrypt') || 'bcrypt',
    saltRounds: parseInt(process.env.PASSWORD_SALT_ROUNDS || '12'),
    scryptCost: parseInt(process.env.PASSWORD_SCRYPT_COST || '16384'),
    scryptKeylen: parseInt(process.env.PASSWORD_SCRYPT_KEYLEN || '64')
  };

  return new PasswordManager(config);
}