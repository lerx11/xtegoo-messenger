import { Router } from 'express';
import { CalendarService } from '../services/calendarService';
import { authMiddleware } from '../middleware/auth';
import { asyncHandler } from '../utils/helpers';

const router = Router();

// События календаря CRUD
router.get(
  '/events',
  authMiddleware,
  asyncHandler(async (req, res) => {
    if (!req.user) return res.status(401).json({ error: 'Не авторизован' });
    const { startDate, endDate } = req.query;
    const events = await CalendarService.getEvents(
      req.user.id,
      startDate ? new Date(startDate as string) : undefined,
      endDate ? new Date(endDate as string) : undefined
    );
    res.json(events);
  })
);

router.get(
  '/events/:id',
  authMiddleware,
  asyncHandler(async (req, res) => {
    if (!req.user) return res.status(401).json({ error: 'Не авторизован' });
    const event = await CalendarService.getEventById(req.params.id, req.user.id);
    res.json(event);
  })
);

router.post(
  '/events',
  authMiddleware,
  asyncHandler(async (req, res) => {
    if (!req.user) return res.status(401).json({ error: 'Не авторизован' });
    const event = await CalendarService.createEvent(req.user.id, {
      ...req.body,
      date: new Date(req.body.date),
    });
    res.json(event);
  })
);

router.put(
  '/events/:id',
  authMiddleware,
  asyncHandler(async (req, res) => {
    if (!req.user) return res.status(401).json({ error: 'Не авторизован' });
    const data = { ...req.body };
    if (data.date) data.date = new Date(data.date);
    const event = await CalendarService.updateEvent(req.params.id, req.user.id, data);
    res.json(event);
  })
);

router.delete(
  '/events/:id',
  authMiddleware,
  asyncHandler(async (req, res) => {
    if (!req.user) return res.status(401).json({ error: 'Не авторизован' });
    const result = await CalendarService.deleteEvent(req.params.id, req.user.id);
    res.json(result);
  })
);

// Записи на услуги
router.post(
  '/bookings',
  authMiddleware,
  asyncHandler(async (req, res) => {
    if (!req.user) return res.status(401).json({ error: 'Не авторизован' });
    const { serviceId, date } = req.body;
    const booking = await CalendarService.createBooking(
      serviceId,
      req.user.id,
      new Date(date)
    );
    res.json(booking);
  })
);

router.get(
  '/bookings/my',
  authMiddleware,
  asyncHandler(async (req, res) => {
    if (!req.user) return res.status(401).json({ error: 'Не авторизован' });
    const bookings = await CalendarService.getClientBookings(req.user.id);
    res.json(bookings);
  })
);

router.get(
  '/bookings/business',
  authMiddleware,
  asyncHandler(async (req, res) => {
    if (!req.user) return res.status(401).json({ error: 'Не авторизован' });
    const bookings = await CalendarService.getBusinessBookings(req.user.id);
    res.json(bookings);
  })
);

export default router;
