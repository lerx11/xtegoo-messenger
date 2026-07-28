import prisma from '../config/database';

export class StoryService {
  // Получение активных сторис
  static async getStories() {
    const now = new Date();

    // Группируем сторис по пользователям
    const stories = await prisma.story.findMany({
      where: {
        expiresAt: { gt: now },
      },
      include: {
        user: {
          select: {
            id: true,
            username: true,
            firstName: true,
            lastName: true,
            avatar: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });

    // Группируем по пользователям
    const grouped: Record<string, typeof stories> = {};
    stories.forEach((story) => {
      if (!grouped[story.userId]) {
        grouped[story.userId] = [];
      }
      grouped[story.userId].push(story);
    });

    return Object.values(grouped).map((userStories) => ({
      user: userStories[0].user,
      stories: userStories,
    }));
  }

  // Создание сторис
  static async createStory(userId: string, mediaUrl: string, type: 'image' | 'video') {
    const expiresAt = new Date();
    expiresAt.setHours(expiresAt.getHours() + 24);

    return prisma.story.create({
      data: {
        userId,
        mediaUrl,
        type,
        expiresAt,
      },
    });
  }

  // Удаление сторис
  static async deleteStory(storyId: string, userId: string) {
    const story = await prisma.story.findUnique({
      where: { id: storyId },
    });

    if (!story || story.userId !== userId) {
      throw new Error('Сторис не найден или нет прав');
    }

    await prisma.story.delete({
      where: { id: storyId },
    });

    return { success: true };
  }

  // Получение сторис пользователя
  static async getUserStories(userId: string) {
    const now = new Date();
    return prisma.story.findMany({
      where: {
        userId,
        expiresAt: { gt: now },
      },
      orderBy: { createdAt: 'asc' },
    });
  }
}
