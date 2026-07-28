import { Router } from 'express';
import { ChatService } from '../services/chatService';
import { authMiddleware } from '../middleware/auth';
import { asyncHandler } from '../utils/helpers';

const router = Router();

// Получение списка чатов
router.get(
  '/list',
  authMiddleware,
  asyncHandler(async (req, res) => {
    if (!req.user) return res.status(401).json({ error: 'Не авторизован' });
    const chats = await ChatService.getChats(req.user.id);
    res.json(chats);
  })
);

// Создание чата
router.post(
  '/create',
  authMiddleware,
  asyncHandler(async (req, res) => {
    if (!req.user) return res.status(401).json({ error: 'Не авторизован' });
    const { targetUserId, isGroup, name } = req.body;
    const chat = await ChatService.createChat(req.user.id, targetUserId, isGroup, name);
    res.json(chat);
  })
);

// Получение сообщений чата
router.get(
  '/:id/messages',
  authMiddleware,
  asyncHandler(async (req, res) => {
    const { cursor, limit } = req.query;
    const messages = await ChatService.getMessages(
      req.params.id,
      cursor as string,
      limit ? parseInt(limit as string) : undefined
    );
    res.json(messages);
  })
);

// Отправка сообщения
router.post(
  '/:id/messages',
  authMiddleware,
  asyncHandler(async (req, res) => {
    if (!req.user) return res.status(401).json({ error: 'Не авторизован' });
    const { content, type, fileUrl, replyToId } = req.body;
    const message = await ChatService.sendMessage(
      req.params.id,
      req.user.id,
      content,
      type,
      fileUrl,
      replyToId
    );
    res.json(message);
  })
);

// Пометить как прочитанное
router.post(
  '/:id/read',
  authMiddleware,
  asyncHandler(async (req, res) => {
    if (!req.user) return res.status(401).json({ error: 'Не авторизован' });
    const result = await ChatService.markAsRead(req.params.id, req.user.id);
    res.json(result);
  })
);

export default router;
