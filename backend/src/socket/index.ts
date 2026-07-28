import { Server as HTTPServer } from 'http';
import { Server, Socket } from 'socket.io';
import { verifyAccessToken } from '../config/jwt';
import prisma from '../config/database';
import redis from '../config/redis';
import { TranslateService } from '../services/translateService';

// Хранилище онлайн пользователей (socketId -> userId)
const onlineUsers = new Map<string, string>();
// Обратное отображение (userId -> socketId[])
const userSockets = new Map<string, string[]>();

export const setupSocket = (httpServer: HTTPServer) => {
  const io = new Server(httpServer, {
    cors: {
      origin: '*',
      methods: ['GET', 'POST'],
    },
  });

  // Middleware аутентификации для сокетов
  io.use(async (socket, next) => {
    try {
      const token = socket.handshake.auth.token;
      if (!token) {
        return next(new Error('Требуется авторизация'));
      }

      const payload = verifyAccessToken(token);
      if (!payload) {
        return next(new Error('Недействительный токен'));
      }

      const user = await prisma.user.findUnique({
        where: { id: payload.userId },
        select: { id: true },
      });

      if (!user) {
        return next(new Error('Пользователь не найден'));
      }

      (socket as any).userId = user.id;
      next();
    } catch (error) {
      next(new Error('Ошибка авторизации'));
    }
  });

  io.on('connection', (socket: Socket) => {
    const userId = (socket as any).userId;
    console.log(`Пользователь подключен: ${userId}, socket: ${socket.id}`);

    // Добавляем в онлайн
    onlineUsers.set(socket.id, userId);
    if (!userSockets.has(userId)) {
      userSockets.set(userId, []);
    }
    userSockets.get(userId)!.push(socket.id);

    // Уведомляем о статусе онлайн
    broadcastUserStatus(userId, true);

    // Обработка сообщений
    socket.on('message', async (data: { chatId: string; content: string; type?: string; fileUrl?: string; replyToId?: string }) => {
      try {
        const { chatId, content, type, fileUrl, replyToId } = data;

        // Создаем сообщение
        const message = await prisma.message.create({
          data: {
            chatId,
            senderId: userId,
            type: type || 'text',
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

        // Создаем статусы
        const members = await prisma.chatMember.findMany({
          where: { chatId },
          select: { userId: true },
        });

        await prisma.messageStatus.createMany({
          data: members.map((m) => ({
            messageId: message.id,
            userId: m.userId,
            status: m.userId === userId ? 'read' : 'sent',
          })),
        });

        // Обновляем время чата
        await prisma.chat.update({
          where: { id: chatId },
          data: { updatedAt: new Date() },
        });

        // Отправляем сообщение всем участникам чата
        for (const member of members) {
          const sockets = userSockets.get(member.userId);
          if (sockets) {
            sockets.forEach((sid) => {
              io.to(sid).emit('message', { ...message, chatId });
            });
          }
        }
      } catch (error) {
        console.error('Ошибка отправки сообщения:', error);
      }
    });

    // Печатает...
    socket.on('typing', (data: { chatId: string; isTyping: boolean }) => {
      const { chatId, isTyping } = data;

      // Отправляем событие другим участникам чата
      prisma.chatMember.findMany({
        where: { chatId, userId: { not: userId } },
        select: { userId: true },
      }).then((members) => {
        members.forEach((member) => {
          const sockets = userSockets.get(member.userId);
          if (sockets) {
            sockets.forEach((sid) => {
              io.to(sid).emit('typing', { chatId, userId, isTyping });
            });
          }
        });
      });
    });

    // Прочитано
    socket.on('read', async (data: { chatId: string; messageId: string }) => {
      const { chatId, messageId } = data;

      await prisma.messageStatus.updateMany({
        where: {
          messageId,
          userId,
          status: { in: ['sent', 'delivered'] },
        },
        data: { status: 'read' },
      });

      // Уведомляем отправителя
      const message = await prisma.message.findUnique({
        where: { id: messageId },
        select: { senderId: true },
      });

      if (message && message.senderId !== userId) {
        const sockets = userSockets.get(message.senderId);
        if (sockets) {
          sockets.forEach((sid) => {
            io.to(sid).emit('read', { chatId, messageId, userId });
          });
        }
      }
    });

    // Входящий звонок
    socket.on('incoming_call', async (data: { receiverId: string; callId: string; type: string; callerName: string }) => {
      const { receiverId, callId, type, callerName } = data;

      const sockets = userSockets.get(receiverId);
      if (sockets) {
        sockets.forEach((sid) => {
          io.to(sid).emit('incoming_call', {
            callId,
            callerId: userId,
            callerName,
            type,
          });
        });
      }
    });

    // Звонок принят
    socket.on('call_answered', (data: { callId: string; callerId: string }) => {
      const { callId, callerId } = data;

      const sockets = userSockets.get(callerId);
      if (sockets) {
        sockets.forEach((sid) => {
          io.to(sid).emit('call_answered', { callId });
        });
      }
    });

    // Звонок завершен
    socket.on('call_ended', (data: { callId: string; userId: string }) => {
      const { callId, userId: targetUserId } = data;

      const sockets = userSockets.get(targetUserId);
      if (sockets) {
        sockets.forEach((sid) => {
          io.to(sid).emit('call_ended', { callId });
        });
      }
    });

    // Новый сторис
    socket.on('story_added', (data: { storyId: string; userId: string }) => {
      // Отправляем всем подписчикам (упрощенно - всем онлайн)
      socket.broadcast.emit('story_added', data);
    });

    // Перевод сообщения в реальном времени
    socket.on('translate_message', async (data: { messageId: string; text: string; targetLang: string }) => {
      try {
        const { messageId, text, targetLang } = data;

        const result = await TranslateService.translate(text, targetLang);

        // Отправляем перевод обратно
        socket.emit('translate_message_result', {
          messageId,
          translatedText: result.translatedText,
          sourceLang: result.sourceLang,
          targetLang,
        });
      } catch (error) {
        socket.emit('translate_message_error', {
          messageId: data.messageId,
          error: 'Ошибка перевода',
        });
      }
    });

    // Отключение
    socket.on('disconnect', () => {
      console.log(`Пользователь отключен: ${userId}, socket: ${socket.id}`);

      onlineUsers.delete(socket.id);

      const sockets = userSockets.get(userId);
      if (sockets) {
        const index = sockets.indexOf(socket.id);
        if (index > -1) {
          sockets.splice(index, 1);
        }
        if (sockets.length === 0) {
          userSockets.delete(userId);
          broadcastUserStatus(userId, false);
        }
      }
    });
  });

  // Отправка статуса пользователя всем
  const broadcastUserStatus = (userId: string, isOnline: boolean) => {
    io.emit('user_online', { userId, isOnline });
  };

  return io;
};

// Проверка, онлайн ли пользователь
export const isUserOnline = (userId: string): boolean => {
  return userSockets.has(userId);
};

// Получение всех онлайн пользователей
export const getOnlineUsers = (): string[] => {
  return Array.from(userSockets.keys());
};
