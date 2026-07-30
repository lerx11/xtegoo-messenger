import prisma from '../config/database';

export class MarketplaceService {
  // Товары
  static async getProducts(category?: string, search?: string) {
    const where: any = {};
    if (category) where.category = category;
    if (search) where.name = { contains: search, mode: 'insensitive' };

    return prisma.product.findMany({
      where,
      include: {
        user: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            avatar: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  static async getProductById(productId: string) {
    return prisma.product.findUnique({
      where: { id: productId },
      include: {
        user: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            avatar: true,
            isBusiness: true,
            businessName: true,
          },
        },
      },
    });
  }

  static async createProduct(userId: string, data: any) {
    return prisma.product.create({
      data: { ...data, userId },
    });
  }

  static async updateProduct(productId: string, userId: string, data: any) {
    const product = await prisma.product.findUnique({
      where: { id: productId },
    });

    if (!product || product.userId !== userId) {
      throw new Error('Товар не найден или нет прав');
    }

    return prisma.product.update({
      where: { id: productId },
      data,
    });
  }

  static async deleteProduct(productId: string, userId: string) {
    const product = await prisma.product.findUnique({
      where: { id: productId },
    });

    if (!product || product.userId !== userId) {
      throw new Error('Товар не найден или нет прав');
    }

    await prisma.product.delete({ where: { id: productId } });
    return { success: true };
  }

  // Услуги
  static async getServices(category?: string) {
    const where: any = {};
    if (category) where.category = category;

    return prisma.service.findMany({
      where,
      include: {
        user: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            avatar: true,
            businessName: true,
          },
        },
      },
    });
  }

  static async getServiceById(serviceId: string) {
    return prisma.service.findUnique({
      where: { id: serviceId },
      include: {
        user: {
          select: {
            id: true,
            firstName: true,
            lastName: true,
            avatar: true,
            businessName: true,
          },
        },
      },
    });
  }

  static async createService(userId: string, data: any) {
    return prisma.service.create({
      data: { ...data, userId },
    });
  }

  static async updateService(serviceId: string, userId: string, data: any) {
    const service = await prisma.service.findUnique({
      where: { id: serviceId },
    });

    if (!service || service.userId !== userId) {
      throw new Error('Услуга не найдена или нет прав');
    }

    return prisma.service.update({
      where: { id: serviceId },
      data,
    });
  }

  static async deleteService(serviceId: string, userId: string) {
    const service = await prisma.service.findUnique({
      where: { id: serviceId },
    });

    if (!service || service.userId !== userId) {
      throw new Error('Услуга не найдена или нет прав');
    }

    await prisma.service.delete({ where: { id: serviceId } });
    return { success: true };
  }

  // Заказы
  static async createOrder(buyerId: string, productId: string) {
    return prisma.order.create({
      data: { buyerId, productId, status: 'pending' },
    });
  }

  static async getMyOrders(userId: string) {
    return prisma.order.findMany({
      where: { buyerId: userId },
      include: {
        product: true,
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  // Категории
  static async getCategories() {
    const products = await prisma.product.findMany({
      select: { category: true },
      distinct: ['category'],
    });
    return products.map((p) => p.category).filter(Boolean);
  }
}
