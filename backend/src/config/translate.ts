import { config } from '../config';

export const translateConfig = {
  baseUrl: config.libretranslate.url,
  defaultTargetLang: 'ru',
  supportedLanguages: [
    { code: 'ru', name: 'Русский' },
    { code: 'en', name: 'English' },
    { code: 'zh', name: '中文' },
    { code: 'es', name: 'Español' },
    { code: 'fr', name: 'Français' },
    { code: 'de', name: 'Deutsch' },
    { code: 'ar', name: 'العربية' },
    { code: 'hi', name: 'हिन्दी' },
    { code: 'pt', name: 'Português' },
    { code: 'ja', name: '日本語' },
  ],
};
