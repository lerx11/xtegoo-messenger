import { Request, Response, NextFunction } from 'express';
import { AnyZodObject, ZodError } from 'zod';

// Middleware для валидации тела запроса по Zod-схеме
export const validate = (schema: AnyZodObject) => {
  return async (req: Request, res: Response, next: NextFunction) => {
    try {
      // Валидируем и парсим req.body
      req.body = await schema.parseAsync(req.body);
      next();
    } catch (error) {
      if (error instanceof ZodError) {
        // Форматируем ошибки Zod в читаемый формат
        const errors = error.errors.map((err) => ({
          field: err.path.join('.'),
          message: err.message,
          code: err.code,
        }));

        return res.status(400).json({
          error: 'Ошибка валидации',
          details: errors,
        });
      }
      
      // Неожиданная ошибка
      return res.status(500).json({
        error: 'Внутренняя ошибка сервера при валидации',
      });
    }
  };
};

// Middleware для валидации query-параметров
export const validateQuery = (schema: AnyZodObject) => {
  return async (req: Request, res: Response, next: NextFunction) => {
    try {
      req.query = await schema.parseAsync(req.query) as typeof req.query;
      next();
    } catch (error) {
      if (error instanceof ZodError) {
        const errors = error.errors.map((err) => ({
          field: err.path.join('.'),
          message: err.message,
          code: err.code,
        }));

        return res.status(400).json({
          error: 'Ошибка валидации параметров',
          details: errors,
        });
      }
      
      return res.status(500).json({
        error: 'Внутренняя ошибка сервера при валидации',
      });
    }
  };
};

// Middleware для валидации параметров URL
export const validateParams = (schema: AnyZodObject) => {
  return async (req: Request, res: Response, next: NextFunction) => {
    try {
      req.params = await schema.parseAsync(req.params) as typeof req.params;
      next();
    } catch (error) {
      if (error instanceof ZodError) {
        const errors = error.errors.map((err) => ({
          field: err.path.join('.'),
          message: err.message,
          code: err.code,
        }));

        return res.status(400).json({
          error: 'Ошибка валидации параметров URL',
          details: errors,
        });
      }
      
      return res.status(500).json({
        error: 'Внутренняя ошибка сервера при валидации',
      });
    }
  };
};