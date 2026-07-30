import { Router, Request, Response } from 'express';
import { CallService } from '../services/callService';
import { authMiddleware } from '../middleware/auth';
import { validate } from '../middleware/validate';
import { asyncHandler } from '../utils/helpers';
import {
  createCallSchema,
  livekitTokenSchema,
  updateCallStatusSchema,
} from '../validators';

const router = Router();

// История звонков
router.get(
  '/history',
  authMiddleware,
  asyncHandler(async (req: Request, res: Response) => {
    if (!req.user) return res.status(401).json({ error: 'Не авторизован' });
    const calls = await CallService.getHistory(req.user.id);
    res.json(calls);
  })
);

// Создание звонка
router.post(
  '/create',
  authMiddleware,
  validate(createCallSchema),
  asyncHandler(async (req: Request, res: Response) => {
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
  validate(livekitTokenSchema),
  asyncHandler(async (req: Request, res: Response) => {
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
  validate(updateCallStatusSchema),
  asyncHandler(async (req: Request, res: Response) => {
    const { status, duration } = req.body;
    const call = await CallService.updateStatus(req.params.id, status, duration);
    res.json(call);
  })
);

export default router;