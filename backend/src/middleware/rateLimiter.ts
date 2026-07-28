import rateLimit from 'express-rate-limit';

// Общий лимит запросов
export const rateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 минут
  max: 1000, // максимум 1000 запросов
  message: { error: 'Слишком много запросов, попробуйте позже' },
  standardHeaders: true,
  legacyHeaders: false,
});

// Строгий лимит для авторизации
export const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10, // максимум 10 запросов
  message: { error: 'Слишком много попыток, попробуйте позже' },
  standardHeaders: true,
  legacyHeaders: false,
});

// Лимит для перевода
export const translateLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 минута
  max: 100,
  message: { error: 'Слишком много запросов на перевод' },
  standardHeaders: true,
  legacyHeaders: false,
});
