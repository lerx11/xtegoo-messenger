import { Router, Request, Response } from 'express';
import { UserService } from '../services/userService';
import { authMiddleware } from '../middleware/auth';
import { validate, validateQuery } from '../middleware/validate';
import { asyncHandler } from '../utils/helpers';
import {
  updateProfileSchema,
  updateUsernameSchema,
  searchSchema,
} from '../validators';

const router = Router();

// Получение текущего пользователя
router.get(
  '/me',
  authMiddleware,
  asyncHandler(async (req: Request, res: Response) => {
    if (!req.user) return res.status(401).json({ error: 'Не авторизован' });
    const user = await UserService.getMe(req.user.id);
    res.json(user);
  })
);

// Получение пользователя по ID
router.get(
  '/:id',
  authMiddleware,
  asyncHandler(async (req: Request, res: Response) => {
    const user = await UserService.getById(req.params.id);
    if (!user) return res.status(404).json({ error: 'Пользователь не найден' });
    res.json(user);
  })
);

// Поиск пользователей
router.get(
  '/search',
  authMiddleware,
  validateQuery(searchSchema),
  asyncHandler(async (req: Request, res: Response) => {
    const q = req.query.q as string;
    const users = await UserService.search(q);
    res.json(users);
  })
);

// Проверка доступности username
router.get(
  '/check-username/:username',
  authMiddleware,
  asyncHandler(async (req: Request, res: Response) => {
    const result = await UserService.checkUsername(req.params.username);
    res.json(result);
  })
);

// Обновление username
router.put(
  '/update-username',
  authMiddleware,
  validate(updateUsernameSchema),
  asyncHandler(async (req: Request, res: Response) => {
    if (!req.user) return res.status(401).json({ error: 'Не авторизован' });
    const { username } = req.body;
    const user = await UserService.updateUsername(req.user.id, username);
    res.json(user);
  })
);

// Обновление профиля
router.put(
  '/update-profile',
  authMiddleware,
  validate(updateProfileSchema),
  asyncHandler(async (req: Request, res: Response) => {
    if (!req.user) return res.status(401).json({ error: 'Не авторизован' });
    const user = await UserService.updateProfile(req.user.id, req.body);
    res.json(user);
  })
);

export default router;