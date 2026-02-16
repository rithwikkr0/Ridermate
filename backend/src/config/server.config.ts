import dotenv from 'dotenv';

dotenv.config();

interface Config {
  port: number;
  nodeEnv: string;
  jwt: {
    secret: string;
    expiresIn: string | number;
  };
  cors: {
    origin: string[];
  };
  logLevel: string;
}

export const config: Config = {
  port: parseInt(process.env.PORT || '3000', 10),
  nodeEnv: process.env.NODE_ENV || 'development',
  jwt: {
    secret: process.env.JWT_SECRET || 'change-this-secret-key',
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  },
  cors: {
    origin: process.env.CORS_ORIGIN?.split(',') || ['http://localhost:3001'],
  },
  logLevel: process.env.LOG_LEVEL || 'info',
};

export default config;
