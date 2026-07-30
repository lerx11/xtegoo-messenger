import { Router, Request, Response } from 'express';
import { MarketplaceService } from '../services/marketplaceService';
import { authMiddleware } from '../middleware/auth';
import { validate } from '../middleware/validate';
import { asyncHandler } from '../utils/helpers';
import {
  createProductSchema,
  updateProductSchema,
  createServiceSchema,
  updateServiceSchema,
  createOrderSchema,
} from '../validators';

const router = Router();

// Категории
router.get(
  '/categories',
  asyncHandler(async (req: Request, res: Response) => {
    const categories = await MarketplaceService.getCategories();
    res.json(categories);
  })
);

// Поиск товаров
router.get(
  '/search',
  asyncHandler(async (req: Request, res: Response) => {
    const { q, category } = req.query;
    const products = await MarketplaceService.getProducts(
      category as string,
      q as string
    );
    res.json(products);
  })
);

// Товары CRUD
router.get(
  '/products',
  asyncHandler(async (req: Request, res: Response) => {
    const { category } = req.query;
    const products = await MarketplaceService.getProducts(category as string);
    res.json(products);
  })
);

router.get(
  '/products/:id',
  asyncHandler(async (req: Request, res: Response) => {
    const product = await MarketplaceService.getProductById(req.params.id);
    if (!product) return res.status(404).json({ error: 'Товар не найден' });
    res.json(product);
  })
);

router.post(
  '/products',
  authMiddleware,
  validate(createProductSchema),
  asyncHandler(async (req: Request, res: Response) => {
    if (!req.user) return res.status(401).json({ error: 'Не авторизован' });
    const product = await MarketplaceService.createProduct(req.user.id, req.body);
    res.json(product);
  })
);

router.put(
  '/products/:id',
  authMiddleware,
  validate(updateProductSchema),
  asyncHandler(async (req: Request, res: Response) => {
    if (!req.user) return res.status(401).json({ error: 'Не авторизован' });
    const product = await MarketplaceService.updateProduct(
      req.params.id,
      req.user.id,
      req.body
    );
    res.json(product);
  })
);

router.delete(
  '/products/:id',
  authMiddleware,
  asyncHandler(async (req: Request, res: Response) => {
    if (!req.user) return res.status(401).json({ error: 'Не авторизован' });
    const result = await MarketplaceService.deleteProduct(req.params.id, req.user.id);
    res.json(result);
  })
);

// Услуги
router.get(
  '/services',
  asyncHandler(async (req: Request, res: Response) => {
    const { category } = req.query;
    const services = await MarketplaceService.getServices(category as string);
    res.json(services);
  })
);

router.get(
  '/services/:id',
  asyncHandler(async (req: Request, res: Response) => {
    const service = await MarketplaceService.getServiceById(req.params.id);
    if (!service) return res.status(404).json({ error: 'Услуга не найдена' });
    res.json(service);
  })
);

router.post(
  '/services',
  authMiddleware,
  validate(createServiceSchema),
  asyncHandler(async (req: Request, res: Response) => {
    if (!req.user) return res.status(401).json({ error: 'Не авторизован' });
    const service = await MarketplaceService.createService(req.user.id, req.body);
    res.json(service);
  })
);

router.put(
  '/services/:id',
  authMiddleware,
  validate(updateServiceSchema),
  asyncHandler(async (req: Request, res: Response) => {
    if (!req.user) return res.status(401).json({ error: 'Не авторизован' });
    const service = await MarketplaceService.updateService(
      req.params.id,
      req.user.id,
      req.body
    );
    res.json(service);
  })
);

router.delete(
  '/services/:id',
  authMiddleware,
  asyncHandler(async (req: Request, res: Response) => {
    if (!req.user) return res.status(401).json({ error: 'Не авторизован' });
    const result = await MarketplaceService.deleteService(req.params.id, req.user.id);
    res.json(result);
  })
);

// Заказы
router.post(
  '/orders',
  authMiddleware,
  validate(createOrderSchema),
  asyncHandler(async (req: Request, res: Response) => {
    if (!req.user) return res.status(401).json({ error: 'Не авторизован' });
    const { productId } = req.body;
    const order = await MarketplaceService.createOrder(req.user.id, productId);
    res.json(order);
  })
);

router.get(
  '/orders/my',
  authMiddleware,
  asyncHandler(async (req: Request, res: Response) => {
    if (!req.user) return res.status(401).json({ error: 'Не авторизован' });
    const orders = await MarketplaceService.getMyOrders(req.user.id);
    res.json(orders);
  })
);

export default router;