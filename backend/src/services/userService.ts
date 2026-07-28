import prisma from '../config/database';

export class UserService {
  // Получение текущего пользователя
  static async getMe(userId: string) {
    return prisma.user.findUnique({
      where: { id: userId },
    });
  }

  // Получение пользователя по ID
  static async getById(userId: string) {
    return prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        username: true,
        firstName: true,
        lastName: true,
        avatar: true,
        bio: true,
        isBusiness: true,
        businessName: true,
        businessDesc: true,
        createdAt: true,
      },
    });
  }

  // Поиск пользователей
  static async search(query: string) {
    return prisma.user.findMany({
      where: {
        OR: [
          { username: { contains: query, mode: 'insensitive' } },
          { firstName: { contains: query, mode: 'insensitive' } },
          { lastName: { contains: query, mode: 'insensitive' } },
          { phone: { contains: query } },
        ],
      },
      take: 20,
      select: {
        id: true,
        username: true,
        firstName: true,
        lastName: true,
        avatar: true,
        isBusiness: true,
        businessName: true,
      },
    });
  }

  // Обновление username
  static async updateUsername(userId: string, username: string) {
    // Проверяем, занят ли username
    const existing = await prisma.user.findUnique({
      where: { username: username.startsWith('@') ? username : `@${username}` },
    });

    if (existing && existing.id !== userId) {
      throw new Error('Этот ник уже занят');
    }

    const formattedUsername = username.startsWith('@') ? username : `@${username}`;

    return prisma.user.update({
      where: { id: userId },
      data: { username: formattedUsername },
    });
  }

  // Обновление профиля
  static async updateProfile(
    userId: string,
    data: {
      firstName?: string;
      lastName?: string;
      bio?: string;
      avatar?: string;
      language?: string;
      isBusiness?: boolean;
      businessName?: string;
      businessDesc?: string;
    }
  ) {
    return prisma.user.update({
      where: { id: userId },
      data,
    });
  }

  // Проверка доступности username
  static async checkUsername(username: string) {
    const formattedUsername = username.startsWith('@') ? username : `@${username}`;
    const existing = await prisma.user.findUnique({
      where: { username: formattedUsername },
    });
    return { available: !existing, username: formattedUsername };
  }
}
