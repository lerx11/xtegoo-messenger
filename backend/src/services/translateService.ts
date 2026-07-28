import axios from 'axios';
import prisma from '../config/database';
import { translateConfig } from '../config/translate';

// Сервис перевода с кешированием
export class TranslateService {
  // Перевод текста
  static async translate(
    text: string,
    targetLang: string,
    sourceLang?: string
  ): Promise<{ translatedText: string; sourceLang: string }> {
    // Проверка кеша
    if (!sourceLang) {
      // Если исходный язык не указан, ищем в кеше только по тексту и целевому языку
      const cached = await prisma.translationCache.findFirst({
        where: {
          sourceText: text,
          targetLang,
        },
      });

      if (cached) {
        return {
          translatedText: cached.translatedText,
          sourceLang: cached.sourceLang,
        };
      }
    } else {
      const cached = await prisma.translationCache.findUnique({
        where: {
          sourceText_targetLang: {
            sourceText: text,
            targetLang,
          },
        },
      });

      if (cached) {
        return {
          translatedText: cached.translatedText,
          sourceLang: cached.sourceLang,
        };
      }
    }

    // Запрос к LibreTranslate
    try {
      const response = await axios.post(
        `${translateConfig.baseUrl}/translate`,
        {
          q: text,
          source: sourceLang || 'auto',
          target: targetLang,
          format: 'text',
        }
      );

      const translatedText = response.data.translatedText;
      const detectedSourceLang = sourceLang || response.data.detectedLanguage?.language || 'en';

      // Сохраняем в кеш
      await prisma.translationCache.create({
        data: {
          sourceText: text,
          translatedText,
          sourceLang: detectedSourceLang,
          targetLang,
        },
      });

      return {
        translatedText,
        sourceLang: detectedSourceLang,
      };
    } catch (error) {
      throw new Error('Ошибка перевода');
    }
  }

  // Получение списка поддерживаемых языков
  static async getLanguages() {
    try {
      const response = await axios.get(`${translateConfig.baseUrl}/languages`);
      return response.data;
    } catch (error) {
      return translateConfig.supportedLanguages;
    }
  }

  // Обнаружение языка
  static async detectLanguage(text: string): Promise<string> {
    try {
      const response = await axios.post(
        `${translateConfig.baseUrl}/detect`,
        {
          q: text,
        }
      );
      return response.data[0]?.language || 'en';
    } catch (error) {
      return 'en';
    }
  }

  // Массовый перевод
  static async translateBatch(
    texts: string[],
    targetLang: string,
    sourceLang?: string
  ): Promise<{ translatedText: string; sourceLang: string }[]> {
    const results: { translatedText: string; sourceLang: string }[] = [];

    for (const text of texts) {
      const result = await this.translate(text, targetLang, sourceLang);
      results.push(result);
    }

    return results;
  }
}
