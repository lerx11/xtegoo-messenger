import { Router, Request, Response } from 'express';
import { ESIMService } from '../services/esimService';
import { authMiddleware } from '../middleware/auth';
import { validate } from '../middleware/validate';
import { asyncHandler } from '../utils/helpers';
import { purchaseEsimSchema } from '../validators';

const router = Router();

// Провайдеры
router.get(
  '/providers',
  asyncHandler(async (req: Request, res: Response) => {
    const providers = await ESIMService.getProviders();
    res.json(providers);
  })
);

// Тарифы
router.get(
  '/plans',
  asyncHandler(async (req: Request, res: Response) => {
    const { country, dataAmount } = req.query;
    const plans = await ESIMService.getPlans(country as string, dataAmount as string);
    res.json(plans);
  })
);

// Покупка eSIM
router.post(
  '/purchase',
  authMiddleware,
  validate(purchaseEsimSchema),
  asyncHandler(async (req: Request, res: Response) => {
    if (!req.user) return res.status(401).json({ error: 'Не авторизован' });
    const { provider, plan } = req.body;
    const esim = await ESIMService.purchaseESIM(req.user.id, provider, plan);
    res.json(esim);
  })
);

// Мои eSIM
router.get(
  '/my',
  authMiddleware,
  asyncHandler(async (req: Request, res: Response) => {
    if (!req.user) return res.status(401).json({ error: 'Не авторизован' });
    const esims = await ESIMService.getMyESIMs(req.user.id);
    res.json(esims);
  })
);

export default router;