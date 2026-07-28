import prisma from '../config/database';

export class ChatService {
  // Получение списка чатов пользователя
  static async getChats(userId: string) {
    const chatMembers = await prisma.chatMember.findMany({
      where: { userId },
      include: {
        chat: {
          include: {
            members: {
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
            },
            messages: {
              orderBy: { createdAt: 'desc' },
              take: 1,
              include: {
                sender: {
                  select: {
                    id: true,
                    firstName: true,
                    lastName: true,
                  },
                },
              },
            },
          },
        },
      },
      orderBy: { chat: { updatedAt: 'desc' } },
    });

    return chatMembers.map((cm) => cm.chat);
  }

  // Создание чата
  static async createChat(userId: string, targetUserId: string, isGroup = false, name?: string) {
    if (!isGroup) {
      // Проверяем, есть ли уже чат между этими пользователями
      const existingChats = await prisma.chat.findMany({
        where: {
          isGroup: false,
          members: {
            every: {
              userId: { in: [userId, targetUserId] },
            },
          },
        },
        include: { members: true },
      });

      const existing = existingChats.find(
        (chat) => chat.members.length === 2
      );

      if (existing) {
        return existing;
      }
    }

    const chat = await prisma.chat.create({
      data: {
        isGroup,
        name,
        members: {
          create: isGroup
            ? [{ userId, isAdmin: true }]
            : [
                { userId, isAdmin: true },
                { userId: targetUserId },
              ],
        },
      },
      include: { members: true },
    });

    return chat;
  }

  // Получение сообщений чата
  static async getMessages(chatId: string, cursor?: string, limit = 50) {
    const messages = await prisma.message.findMany({
      where: { chatId },
      orderBy: { createdAt: 'desc' },
      take: limit,
      ...(cursor && { cursor: { id: cursor }, skip: 1 }),
      include: {
        sender: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            avatar: true,
          },
        },
        replyTo: {
          include: {
            sender: {
              select: {
                id: true,
                firstName: true,
                lastName: true,
              },
            },
          },
        },
      },
    });

    return messages.reverse();
  }

  // Отправка сообщения
  static async sendMessage(
    chatId: string,
    senderId: string,
    content: string,
    type = 'text',
    fileUrl?: string,
    replyToId?: string
  ) {
    const message = await prisma.message.create({
      data: {
        chatId,
        senderId,
        type,
        content,
        fileUrl,
        replyToId,
      },
      include: {
        sender: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            avatar: true,
          },
        },
      },
    });

    // Создаем статусы сообщения для всех участников
    const members = await prisma.chatMember.findMany({
      where: { chatId },
      select: { userId: true },
    });

    await prisma.messageStatus.createMany({
      data: members.map((m) => ({
        messageId: message.id,
        userId: m.userId,
        status: m.userId === senderId ? 'read' : 'sent',
      })),
    });

    // Обновляем время чата
    await prisma.chat.update({
      where: { id: chatId },
      data: { updatedAt: new Date() },
    });

    return message;
  }

  // Пометка сообщений как прочитанных
  static async markAsRead(chatId: string, userId: string) {
    await prisma.messageStatus.updateMany({
      where: {
        message: { chatId },
        userId,
        status: { in: ['sent', 'delivered'] },
      },
      data: { status: 'read' },
    });

    return { success: true };
  }
}
