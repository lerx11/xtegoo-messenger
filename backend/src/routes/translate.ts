import { Router, Request, Response } from 'express';
import { TranslateService } from '../services/translateService';
import { authMiddleware, optionalAuthMiddleware } from '../middleware/auth';
import { translateLimiter } from '../middleware/rateLimiter';
import { asyncHandler } from '../utils/helpers';
import prisma from '../config/database';

const router = Router();

// Перевод текста
router.post(
  '/translate',
  translateLimiter,
  optionalAuthMiddleware,
  asyncHandler(async (req: Request, res: Response) => {
    const { text, targetLang, sourceLang } = req.body;

    if (!text || !targetLang) {
      return res.status(400).json({ error: 'Текст и целевой язык обязательны' });
    }

    const result = await TranslateService.translate(text, targetLang, sourceLang);
    res.json(result);
  })
);

// Массовый перевод
router.post(
  '/translate-batch',
  translateLimiter,
  optionalAuthMiddleware,
  asyncHandler(async (req: Request, res: Response) => {
    const { texts, targetLang, sourceLang } = req.body;

    if (!texts || !targetLang) {
      return res.status(400).json({ error: 'Тексты и целевой язык обязательны' });
    }

    const result = await TranslateService.translateBatch(texts, targetLang, sourceLang);
    res.json(result);
  })
);

// Список поддерживаемых языков
router.get(
  '/languages',
  asyncHandler(async (req: Request, res: Response) => {
    const languages = await TranslateService.getLanguages();
    res.json(languages);
  })
);

// Обнаружение языка
router.post(
  '/detect',
  translateLimiter,
  asyncHandler(async (req: Request, res: Response) => {
    const { text } = req.body;
    if (!text) return res.status(400).json({ error: 'Текст обязателен' });

    const language = await TranslateService.detectLanguage(text);
    res.json({ language });
  })
);

// История переводов (только для авторизованных)
router.get(
  '/history',
  authMiddleware,
  asyncHandler(async (req: Request, res: Response) => {
    if (!req.user) return res.status(401).json({ error: 'Не авторизован' });

    // Возвращаем недавние переводы из кеша
    const history = await prisma.translationCache.findMany({
      orderBy: { createdAt: 'desc' },
      take: 50,
    });

    res.json(history);
  })
);

export default router;
