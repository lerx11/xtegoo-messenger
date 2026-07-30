import jwt from 'jsonwebtoken';
import { config } from '../config';

export const generateAccessToken = (userId: string): string => {
  return jwt.sign({ userId }, config.jwt.secret, {
    expiresIn: config.jwt.accessExpiresIn,
  } as jwt.SignOptions);
};

export const generateRefreshToken = (userId: string): string => {
  return jwt.sign({ userId }, config.jwt.refreshSecret, {
    expiresIn: config.jwt.refreshExpiresIn,
  } as jwt.SignOptions);
};

export const verifyAccessToken = (token: string) => {
  try {
    return jwt.verify(token, config.jwt.secret) as { userId: string };
  } catch {
    return null;
  }
};

export const verifyRefreshToken = (token: string) => {
  try {
    return jwt.verify(token, config.jwt.refreshSecret) as { userId: string };
  } catch {
    return null;
  }
};
