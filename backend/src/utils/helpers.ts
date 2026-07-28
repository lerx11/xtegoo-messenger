// Вспомогательные функции

// Генерация кода подтверждения (6 цифр)
export const generateCode = (): string => {
  return Math.floor(100000 + Math.random() * 900000).toString();
};

// Форматирование номера телефона
export const formatPhone = (phone: string): string => {
  return phone.replace(/\D/g, '');
};

// Валидация username
export const isValidUsername = (username: string): boolean => {
  return /^@[a-zA-Z0-9_]{3,32}$/.test(username);
};

// Обработка асинхронных ошибок в роутах
export const asyncHandler = (fn: Function) => (req: any, res: any, next: any) => {
  Promise.resolve(fn(req, res, next)).catch(next);
};
