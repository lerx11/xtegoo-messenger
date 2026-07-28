import prisma from '../config/database';
import { generateLiveKitToken } from '../config/livekit';

export class CallService {
  // Получение истории звонков
  static async getHistory(userId: string) {
    return prisma.call.findMany({
      where: {
        OR: [{ callerId: userId }, { receiverId: userId }],
      },
      include: {
        caller: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            avatar: true,
            username: true,
          },
        },
        receiver: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            avatar: true,
            username: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
      take: 50,
    });
  }

  // Создание звонка
  static async createCall(callerId: string, receiverId: string, type: 'audio' | 'video') {
    const roomName = `call_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

    const call = await prisma.call.create({
      data: {
        callerId,
        receiverId,
        type,
        status: 'incoming',
        roomName,
      },
      include: {
        caller: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            avatar: true,
            username: true,
          },
        },
        receiver: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            avatar: true,
            username: true,
          },
        },
      },
    });

    return call;
  }

  // Получение токена LiveKit
  static async getToken(userId: string, roomName: string, participantName: string) {
    const token = generateLiveKitToken(roomName, participantName, userId);
    return { token };
  }

  // Обновление статуса звонка
  static async updateStatus(callId: string, status: string, duration?: number) {
    return prisma.call.update({
      where: { id: callId },
      data: {
        status,
        ...(duration !== undefined && { duration }),
      },
    });
  }
}
