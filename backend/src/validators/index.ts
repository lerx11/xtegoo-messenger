import { z } from 'zod';

// ============================================
// АВТОРИЗАЦИЯ
// ============================================

export const sendCodeSchema = z.object({
  phone: z.string().min(10).max(15),
});

export const verifyCodeSchema = z.object({
  phone: z.string().min(10).max(15),
  code: z.string().length(6),
});

export const refreshTokenSchema = z.object({
  refreshToken: z.string().min(1),
});

// ============================================
// ПОЛЬЗОВАТЕЛИ
// ============================================

export const updateProfileSchema = z.object({
  firstName: z.string().min(1).max(50).optional(),
  lastName: z.string().min(1).max(50).optional(),
  bio: z.string().max(500).optional(),
  avatar: z.string().url().optional(),
  language: z.string().length(2).optional(),
});

export const updateUsernameSchema = z.object({
  username: z.string().min(3).max(30).regex(/^@[a-zA-Z0-9_]+$/, 'Username должен начинаться с @ и содержать только буквы, цифры и подчёркивания'),
});

export const searchSchema = z.object({
  q: z.string().min(1),
});

// ============================================
// ЧАТЫ
// ============================================

export const createChatSchema = z.object({
  targetUserId: z.string().min(1),
  isGroup: z.boolean().optional(),
  name: z.string().max(100).optional(),
});

export const sendMessageSchema = z.object({
  content: z.string().optional(),
  type: z.enum(['text', 'image', 'video', 'audio', 'document', 'location', 'voice']).default('text'),
  fileUrl: z.string().url().optional(),
  replyToId: z.string().optional(),
});

// ============================================
// ЗВОНКИ
// ============================================

export const createCallSchema = z.object({
  receiverId: z.string().min(1),
  type: z.enum(['audio', 'video']),
});

export const livekitTokenSchema = z.object({
  roomName: z.string().min(1),
  participantName: z.string().min(1).optional(),
});

export const updateCallStatusSchema = z.object({
  status: z.enum(['answered', 'ended', 'missed']),
  duration: z.number().int().min(0).optional(),
});

// ============================================
// СТОРИС
// ============================================

export const createStorySchema = z.object({
  mediaUrl: z.string().url(),
  type: z.enum(['image', 'video']),
});

// ============================================
// МАРКЕТПЛЕЙС - УСЛУГИ
// ============================================

export const createServiceSchema = z.object({
  name: z.string().min(1).max(100),
  description: z.string().max(1000).optional(),
  price: z.number().positive(),
  duration: z.number().int().positive(), // в минутах
  category: z.string().optional(),
});

export const updateServiceSchema = z.object({
  name: z.string().min(1).max(100).optional(),
  description: z.string().max(1000).optional(),
  price: z.number().positive().optional(),
  duration: z.number().int().positive().optional(),
  category: z.string().optional(),
});

// ============================================
// МАРКЕТПЛЕЙС - ТОВАРЫ
// ============================================

export const createProductSchema = z.object({
  name: z.string().min(1).max(100),
  description: z.string().max(2000).optional(),
  price: z.number().positive(),
  images: z.array(z.string().url()).min(1),
  category: z.string().optional(),
});

export const updateProductSchema = z.object({
  name: z.string().min(1).max(100).optional(),
  description: z.string().max(2000).optional(),
  price: z.number().positive().optional(),
  images: z.array(z.string().url()).optional(),
  category: z.string().optional(),
});

// ============================================
// ЗАКАЗЫ
// ============================================

export const createOrderSchema = z.object({
  productId: z.string().min(1),
});

// ============================================
// КАЛЕНДАРЬ - СОБЫТИЯ
// ============================================

export const createCalendarEventSchema = z.object({
  title: z.string().min(1).max(100),
  description: z.string().max(1000).optional(),
  date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'Дата должна быть в формате YYYY-MM-DD'),
  time: z.string().regex(/^\d{2}:\d{2}$/, 'Время должно быть в формате HH:MM').optional(),
  color: z.string().regex(/^#[0-9A-Fa-f]{6}$/, 'Цвет должен быть в формате #RRGGBB').optional(),
  reminder: z.boolean().optional(),
});

export const updateCalendarEventSchema = z.object({
  title: z.string().min(1).max(100).optional(),
  description: z.string().max(1000).optional(),
  date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/).optional(),
  time: z.string().regex(/^\d{2}:\d{2}$/).optional(),
  color: z.string().regex(/^#[0-9A-Fa-f]{6}$/).optional(),
  reminder: z.boolean().optional(),
});

// ============================================
// БРОНИРОВАНИЕ
// ============================================

export const createBookingSchema = z.object({
  serviceId: z.string().min(1),
  date: z.string().regex(/^\d{4}-\d{2}-\d{2}(T\d{2}:\d{2}(:\d{2})?)?$/, 'Неверный формат даты'),
});

// ============================================
// E-SIM
// ============================================

export const purchaseEsimSchema = z.object({
  provider: z.string().min(1),
  plan: z.string().min(1),
});

// ============================================
// ПЕРЕВОД
// ============================================

export const translateSchema = z.object({
  text: z.string().min(1).max(5000),
  targetLang: z.string().length(2),
  sourceLang: z.string().length(2).optional(),
});

export const translateBatchSchema = z.object({
  texts: z.array(z.string().min(1)).min(1).max(100),
  targetLang: z.string().length(2),
  sourceLang: z.string().length(2).optional(),
});

export const detectLanguageSchema = z.object({
  text: z.string().min(1).max(5000),
});

// ============================================
// ТИПЫ
// ============================================

export type SendCodeInput = z.infer<typeof sendCodeSchema>;
export type VerifyCodeInput = z.infer<typeof verifyCodeSchema>;
export type UpdateProfileInput = z.infer<typeof updateProfileSchema>;
export type UpdateUsernameInput = z.infer<typeof updateUsernameSchema>;
export type CreateChatInput = z.infer<typeof createChatSchema>;
export type SendMessageInput = z.infer<typeof sendMessageSchema>;
export type CreateCallInput = z.infer<typeof createCallSchema>;
export type CreateStoryInput = z.infer<typeof createStorySchema>;
export type CreateServiceInput = z.infer<typeof createServiceSchema>;
export type CreateProductInput = z.infer<typeof createProductSchema>;
export type CreateCalendarEventInput = z.infer<typeof createCalendarEventSchema>;
export type CreateBookingInput = z.infer<typeof createBookingSchema>;
export type CreateOrderInput = z.infer<typeof createOrderSchema>;
export type PurchaseEsimInput = z.infer<typeof purchaseEsimSchema>;
export type TranslateInput = z.infer<typeof translateSchema>;