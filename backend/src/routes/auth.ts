import { Router, Request, Response } from 'express';
import { AuthService } from '../services/authService';
import { authLimiter } from '../middleware/rateLimiter';
import { authMiddleware } from '../middleware/auth';
import { asyncHandler } from '../utils/helpers';

const router = Router();

// Отправка кода подтверждения
router.post(
  '/send-code',
  authLimiter,
  asyncHandler(async (req: Request, res: Response) => {
    const { phone } = req.body;
    const result = await AuthService.sendCode(phone);
    res.json(result);
  })
);

// Проверка кода
router.post(
  '/verify-code',
  authLimiter,
  asyncHandler(async (req: Request, res: Response) => {
    const { phone, code } = req.body;
    const result = await AuthService.verifyCode(phone, code);
    res.json(result);
  })
);

// Обновление токенов
router.post(
  '/refresh-token',
  asyncHandler(async (req: Request, res: Response) => {
    const { refreshToken } = req.body;
    const result = await AuthService.refreshToken(refreshToken);
    res.json(result);
  })
);

// Выход
router.post(
  '/logout',
  authMiddleware,
  asyncHandler(async (req: Request, res: Response) => {
    if (!req.user) return res.status(401).json({ error: 'Не авторизован' });
    const result = await AuthService.logout(req.user.id);
    res.json(result);
  })
);

export default router;
