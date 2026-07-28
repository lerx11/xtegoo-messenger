import { Request, Response, NextFunction } from 'express';
import { verifyAccessToken } from '../config/jwt';
import prisma from '../config/database';

// Расширение интерфейса Request для добавления пользователя
declare global {
  namespace Express {
    interface Request {
      user?: {
        id: string;
      };
    }
  }
}

// Middleware аутентификации
export const authMiddleware = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ error: 'Требуется авторизация' });
    }

    const token = authHeader.split(' ')[1];
    const payload = verifyAccessToken(token);

    if (!payload) {
      return res.status(401).json({ error: 'Недействительный токен' });
    }

    // Проверяем, существует ли пользователь
    const user = await prisma.user.findUnique({
      where: { id: payload.userId },
      select: { id: true },
    });

    if (!user) {
      return res.status(401).json({ error: 'Пользователь не найден' });
    }

    req.user = { id: user.id };
    next();
  } catch (error) {
    res.status(500).json({ error: 'Ошибка авторизации' });
  }
};

// Опциональная аутентификация (необязательна)
export const optionalAuthMiddleware = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return next();
    }

    const token = authHeader.split(' ')[1];
    const payload = verifyAccessToken(token);

    if (!payload) {
      return next();
    }

    const user = await prisma.user.findUnique({
      where: { id: payload.userId },
      select: { id: true },
    });

    if (user) {
      req.user = { id: user.id };
    }

    next();
  } catch (error) {
    next();
  }
};
