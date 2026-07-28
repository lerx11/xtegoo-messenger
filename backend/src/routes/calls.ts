import { Router } from 'express';
import { CallService } from '../services/callService';
import { authMiddleware } from '../middleware/auth';
import { asyncHandler } from '../utils/helpers';

const router = Router();

// История звонков
router.get(
  '/history',
  authMiddleware,
  asyncHandler(async (req, res) => {
    if (!req.user) return res.status(401).json({ error: 'Не авторизован' });
    const calls = await CallService.getHistory(req.user.id);
    res.json(calls);
  })
);

// Создание звонка
router.post(
  '/create',
  authMiddleware,
  asyncHandler(async (req, res) => {
    if (!req.user) return res.status(401).json({ error: 'Не авторизован' });
    const { receiverId, type } = req.body;
    const call = await CallService.createCall(req.user.id, receiverId, type);
    res.json(call);
  })
);

// Получение LiveKit токена
router.post(
  '/livekit-token',
  authMiddleware,
  asyncHandler(async (req, res) => {
    if (!req.user) return res.status(401).json({ error: 'Не авторизован' });
    const { roomName, participantName } = req.body;
    const result = await CallService.getToken(req.user.id, roomName, participantName);
    res.json(result);
  })
);

// Обновление статуса звонка
router.put(
  '/:id/status',
  authMiddleware,
  asyncHandler(async (req, res) => {
    const { status, duration } = req.body;
    const call = await CallService.updateStatus(req.params.id, status, duration);
    res.json(call);
  })
);

export default router;
