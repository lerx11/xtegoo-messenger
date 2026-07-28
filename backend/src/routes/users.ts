import { Router } from 'express';
import { UserService } from '../services/userService';
import { authMiddleware } from '../middleware/auth';
import { asyncHandler } from '../utils/helpers';

const router = Router();

// Получение текущего пользователя
router.get(
  '/me',
  authMiddleware,
  asyncHandler(async (req, res) => {
    if (!req.user) return res.status(401).json({ error: 'Не авторизован' });
    const user = await UserService.getMe(req.user.id);
    res.json(user);
  })
);

// Получение пользователя по ID
router.get(
  '/:id',
  authMiddleware,
  asyncHandler(async (req, res) => {
    const user = await UserService.getById(req.params.id);
    if (!user) return res.status(404).json({ error: 'Пользователь не найден' });
    res.json(user);
  })
);

// Поиск пользователей
router.get(
  '/search',
  authMiddleware,
  asyncHandler(async (req, res) => {
    const q = req.query.q as string;
    if (!q) return res.json([]);
    const users = await UserService.search(q);
    res.json(users);
  })
);

// Проверка доступности username
router.get(
  '/check-username/:username',
  authMiddleware,
  asyncHandler(async (req, res) => {
    const result = await UserService.checkUsername(req.params.username);
    res.json(result);
  })
);

// Обновление username
router.put(
  '/update-username',
  authMiddleware,
  asyncHandler(async (req, res) => {
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
  asyncHandler(async (req, res) => {
    if (!req.user) return res.status(401).json({ error: 'Не авторизован' });
    const user = await UserService.updateProfile(req.user.id, req.body);
    res.json(user);
  })
);

export default router;
