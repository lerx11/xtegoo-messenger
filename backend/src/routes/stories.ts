import { Router, Request, Response } from 'express';
import { StoryService } from '../services/storyService';
import { authMiddleware } from '../middleware/auth';
import { validate } from '../middleware/validate';
import { asyncHandler } from '../utils/helpers';
import { createStorySchema } from '../validators';

const router = Router();

// Получение списка сторис
router.get(
  '/list',
  authMiddleware,
  asyncHandler(async (req: Request, res: Response) => {
    const stories = await StoryService.getStories();
    res.json(stories);
  })
);

// Получение сторис пользователя
router.get(
  '/user/:userId',
  authMiddleware,
  asyncHandler(async (req: Request, res: Response) => {
    const stories = await StoryService.getUserStories(req.params.userId);
    res.json(stories);
  })
);

// Создание сторис
router.post(
  '/create',
  authMiddleware,
  validate(createStorySchema),
  asyncHandler(async (req: Request, res: Response) => {
    if (!req.user) return res.status(401).json({ error: 'Не авторизован' });
    const { mediaUrl, type } = req.body;
    const story = await StoryService.createStory(req.user.id, mediaUrl, type);
    res.json(story);
  })
);

// Удаление сторис
router.delete(
  '/:id',
  authMiddleware,
  asyncHandler(async (req: Request, res: Response) => {
    if (!req.user) return res.status(401).json({ error: 'Не авторизован' });
    const result = await StoryService.deleteStory(req.params.id, req.user.id);
    res.json(result);
  })
);

export default router;