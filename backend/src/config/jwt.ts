import jwt from 'jsonwebtoken';
import { config } from '../config';

// Генерация access токена
export const generateAccessToken = (userId: string) => {
  return jwt.sign({ userId }, config.jwt.secret, {
    expiresIn: config.jwt.accessExpiresIn,
  });
};

// Генерация refresh токена
export const generateRefreshToken = (userId: string) => {
  return jwt.sign({ userId }, config.jwt.refreshSecret, {
    expiresIn: config.jwt.refreshExpiresIn,
  });
};

// Верификация access токена
export const verifyAccessToken = (token: string) => {
  try {
    return jwt.verify(token, config.jwt.secret) as { userId: string };
  } catch {
    return null;
  }
};

// Верификация refresh токена
export const verifyRefreshToken = (token: string) => {
  try {
    return jwt.verify(token, config.jwt.refreshSecret) as { userId: string };
  } catch {
    return null;
  }
};
