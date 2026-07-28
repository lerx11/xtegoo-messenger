import dotenv from 'dotenv';

dotenv.config();

export const config = {
  port: parseInt(process.env.PORT || '3000', 10),
  nodeEnv: process.env.NODE_ENV || 'development',
  databaseUrl: process.env.DATABASE_URL || '',
  redisUrl: process.env.REDIS_URL || 'redis://localhost:6379',
  jwt: {
    secret: process.env.JWT_SECRET || 'default_secret',
    refreshSecret: process.env.JWT_REFRESH_SECRET || 'default_refresh_secret',
    accessExpiresIn: '15m',
    refreshExpiresIn: '30d',
  },
  livekit: {
    url: process.env.LIVEKIT_URL || '',
    apiKey: process.env.LIVEKIT_API_KEY || '',
    apiSecret: process.env.LIVEKIT_API_SECRET || '',
  },
  libretranslate: {
    url: process.env.LIBRETRANSLATE_URL || 'http://localhost:5000',
  },
  minio: {
    user: process.env.MINIO_ROOT_USER || 'xtegoo_admin',
    password: process.env.MINIO_ROOT_PASSWORD || 'xtegoo_minio_2024',
    endPoint: 'minio',
    port: 9000,
    useSSL: false,
  },
};
