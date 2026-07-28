import prisma from '../config/database';

export class ESIMService {
  // Получение списка провайдеров
  static async getProviders() {
    return [
      {
        id: 'zetexa',
        name: 'Zetexa',
        logo: 'https://zetexa.com/logo.png',
        description: 'Глобальные eSIM решения',
      },
      {
        id: 'airalo',
        name: 'Airalo',
        logo: 'https://www.airalo.com/logo.png',
        description: 'Первый eSIM маркетплейс',
      },
      {
        id: 'holafly',
        name: 'Holafly',
        logo: 'https://www.holafly.com/logo.png',
        description: 'eSIM для путешественников',
      },
    ];
  }

  // Получение тарифов
  static async getPlans(country?: string, dataAmount?: string) {
    // Пример данных - в реальности интеграция с API провайдеров
    const plans = [
      {
        id: 'plan_1',
        provider: 'zetexa',
        country: 'Китай',
        countryCode: 'CN',
        dataGb: 10,
        days: 7,
        price: 19.99,
      },
      {
        id: 'plan_2',
        provider: 'airalo',
        country: 'Китай',
        countryCode: 'CN',
        dataGb: 20,
        days: 15,
        price: 35.99,
      },
      {
        id: 'plan_3',
        provider: 'holafly',
        country: 'Китай',
        countryCode: 'CN',
        dataGb: 30,
        days: 30,
        price: 59.99,
      },
      {
        id: 'plan_4',
        provider: 'zetexa',
        country: 'США',
        countryCode: 'US',
        dataGb: 15,
        days: 10,
        price: 29.99,
      },
      {
        id: 'plan_5',
        provider: 'airalo',
        country: 'Европа',
        countryCode: 'EU',
        dataGb: 10,
        days: 7,
        price: 24.99,
      },
    ];

    let filtered = plans;
    if (country) {
      filtered = filtered.filter(
        (p) =>
          p.country.toLowerCase().includes(country.toLowerCase()) ||
          p.countryCode.toLowerCase() === country.toLowerCase()
      );
    }

    return filtered;
  }

  // Покупка eSIM
  static async purchaseESIM(userId: string, planId: string) {
    // В реальности - вызов API провайдера
    const iccid = `89860${Math.random().toString().substr(2, 16)}`;

    const esim = await prisma.eSIM.create({
      data: {
        userId,
        provider: 'zetexa',
        plan: planId,
        status: 'active',
        iccid,
      },
    });

    return esim;
  }

  // Получение моих eSIM
  static async getMyESIMs(userId: string) {
    return prisma.eSIM.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    });
  }
}
