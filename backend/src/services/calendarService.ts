import prisma from '../config/database';

export class CalendarService {
  // Получение событий
  static async getEvents(userId: string, startDate?: Date, endDate?: Date) {
    const where: any = { userId };
    if (startDate && endDate) {
      where.date = {
        gte: startDate,
        lte: endDate,
      };
    }

    return prisma.calendarEvent.findMany({
      where,
      orderBy: { date: 'asc' },
    });
  }

  // Получение события по ID
  static async getEventById(eventId: string, userId: string) {
    const event = await prisma.calendarEvent.findUnique({
      where: { id: eventId },
    });

    if (!event || event.userId !== userId) {
      throw new Error('Событие не найдено');
    }

    return event;
  }

  // Создание события
  static async createEvent(userId: string, data: any) {
    return prisma.calendarEvent.create({
      data: { ...data, userId },
    });
  }

  // Обновление события
  static async updateEvent(eventId: string, userId: string, data: any) {
    const event = await prisma.calendarEvent.findUnique({
      where: { id: eventId },
    });

    if (!event || event.userId !== userId) {
      throw new Error('Событие не найдено или нет прав');
    }

    return prisma.calendarEvent.update({
      where: { id: eventId },
      data,
    });
  }

  // Удаление события
  static async deleteEvent(eventId: string, userId: string) {
    const event = await prisma.calendarEvent.findUnique({
      where: { id: eventId },
    });

    if (!event || event.userId !== userId) {
      throw new Error('Событие не найдено или нет прав');
    }

    await prisma.calendarEvent.delete({ where: { id: eventId } });
    return { success: true };
  }

  // Записи на услуги
  static async createBooking(serviceId: string, clientId: string, date: Date) {
    return prisma.booking.create({
      data: {
        serviceId,
        clientId,
        date,
        status: 'pending',
      },
      include: {
        service: true,
        client: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            phone: true,
          },
        },
      },
    });
  }

  static async getClientBookings(clientId: string) {
    return prisma.booking.findMany({
      where: { clientId },
      include: {
        service: {
          include: {
            user: {
              select: {
                id: true,
                businessName: true,
                avatar: true,
              },
            },
          },
        },
      },
      orderBy: { date: 'asc' },
    });
  }

  static async getBusinessBookings(userId: string) {
    return prisma.booking.findMany({
      where: {
        service: { userId },
      },
      include: {
        service: true,
        client: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            phone: true,
            avatar: true,
          },
        },
      },
      orderBy: { date: 'asc' },
    });
  }
}
