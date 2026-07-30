import { Router, Request, Response } from 'express';
import { TranslateService } from '../services/translateService';
import { authMiddleware, optionalAuthMiddleware } from '../middleware/auth';
import { translateLimiter } from '../middleware/rateLimiter';
import { validate } from '../middleware/validate';
import { asyncHandler } from '../utils/helpers';
import prisma from '../config/database';
import {
  translateSchema,
  translateBatchSchema,
  detectLanguageSchema,
} from '../validators';

const router = Router();

// Перевод текста
router.post(
  '/translate',
  translateLimiter,
  optionalAuthMiddleware,
  validate(translateSchema),
  asyncHandler(async (req: Request, res: Response) => {
    const { text, targetLang, sourceLang } = req.body;
    const result = await TranslateService.translate(text, targetLang, sourceLang);
    res.json(result);
  })
);

// Массовый перевод
router.post(
  '/translate-batch',
  translateLimiter,
  optionalAuthMiddleware,
  validate(translateBatchSchema),
  asyncHandler(async (req: Request, res: Response) => {
    const { texts, targetLang, sourceLang } = req.body;
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
  validate(detectLanguageSchema),
  asyncHandler(async (req: Request, res: Response) => {
    const { text } = req.body;
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