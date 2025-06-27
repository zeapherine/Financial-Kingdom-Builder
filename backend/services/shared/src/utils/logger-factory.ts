import winston from 'winston';

export interface LoggerConfig {
  service: string;
  level?: string;
  format?: 'json' | 'simple';
  enableFileLogging?: boolean;
  logDir?: string;
}

export const createLogger = (config: LoggerConfig): winston.Logger => {
  const {
    service,
    level = process.env.LOG_LEVEL || 'info',
    format = process.env.LOG_FORMAT === 'simple' ? 'simple' : 'json',
    enableFileLogging = process.env.NODE_ENV === 'production',
    logDir = 'logs',
  } = config;

  const transports: winston.transport[] = [
    new winston.transports.Console({
      handleExceptions: true,
      handleRejections: true,
    }),
  ];

  if (enableFileLogging) {
    transports.push(
      new winston.transports.File({
        filename: `${logDir}/error.log`,
        level: 'error',
        maxsize: 5242880, // 5MB
        maxFiles: 5,
      }),
      new winston.transports.File({
        filename: `${logDir}/combined.log`,
        maxsize: 5242880, // 5MB
        maxFiles: 5,
      })
    );
  }

  return winston.createLogger({
    level,
    format: winston.format.combine(
      winston.format.timestamp(),
      winston.format.errors({ stack: true }),
      format === 'json'
        ? winston.format.json()
        : winston.format.combine(
            winston.format.colorize(),
            winston.format.simple()
          )
    ),
    defaultMeta: { service },
    transports,
  });
};

// Default logger for shared utilities
export const logger = createLogger({ 
  service: 'shared',
  level: process.env.LOG_LEVEL || 'info'
});