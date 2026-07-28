import prisma from '../config/database';
import { generateCode, formatPhone } from '../utils/helpers';
import redis from '../config/redis';
import { generateAccessToken, generateRefreshToken, verifyRefreshToken } from '../config/jwt';

export class AuthService {
  // Отправка кода подтверждения
  static async sendCode(phone: string) {
    const formattedPhone = formatPhone(phone);
    const code = generateCode();

    // Сохраняем код в Redis на 5 минут
    await redis.set(`auth:code:${formattedPhone}`, code, 'EX', 300);

    // В реальном приложении здесь была бы отправка SMS
    console.log(`Код подтверждения для ${formattedPhone}: ${code}`);

    return { success: true, phone: formattedPhone };
  }

  // Проверка кода и авторизация
  static async verifyCode(phone: string, code: string) {
    const formattedPhone = formatPhone(phone);
    const storedCode = await redis.get(`auth:code:${formattedPhone}`);

    if (!storedCode || storedCode !== code) {
      throw new Error('Неверный код подтверждения');
    }

    // Удаляем код из Redis
    await redis.del(`auth:code:${formattedPhone}`);

    // Находим или создаем пользователя
    let user = await prisma.user.findUnique({
      where: { phone: formattedPhone },
    });

    const isNewUser = !user;

    if (!user) {
      user = await prisma.user.create({
        data: {
          phone: formattedPhone,
        },
      });
    }

    // Генерируем токены
    const accessToken = generateAccessToken(user.id);
    const refreshToken = generateRefreshToken(user.id);

    // Сохраняем refresh токен
    await redis.set(`auth:refresh:${user.id}`, refreshToken, 'EX', 30 * 24 * 60 * 60);

    return {
      accessToken,
      refreshToken,
      user,
      isNewUser,
    };
  }

  // Обновление токенов
  static async refreshToken(token: string) {
    const payload = verifyRefreshToken(token);

    if (!payload) {
      throw new Error('Недействительный refresh токен');
    }

    const storedToken = await redis.get(`auth:refresh:${payload.userId}`);

    if (!storedToken || storedToken !== token) {
      throw new Error('Токен устарел');
    }

    const accessToken = generateAccessToken(payload.userId);
    const refreshToken = generateRefreshToken(payload.userId);

    await redis.set(`auth:refresh:${payload.userId}`, refreshToken, 'EX', 30 * 24 * 60 * 60);

    return { accessToken, refreshToken };
  }

  // Выход
  static async logout(userId: string) {
    await redis.del(`auth:refresh:${userId}`);
    return { success: true };
  }
}
