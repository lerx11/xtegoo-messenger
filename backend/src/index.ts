import express from 'express';
import cors from 'cors';
import http from 'http';
import { config } from './config';
import { rateLimiter } from './middleware/rateLimiter';
import { setupSocket } from './socket';

// Импорт роутов
import authRoutes from './routes/auth';
import userRoutes from './routes/users';
import chatRoutes from './routes/chats';
import callRoutes from './routes/calls';
import storyRoutes from './routes/stories';
import marketplaceRoutes from './routes/marketplace';
import calendarRoutes from './routes/calendar';
import esimRoutes from './routes/esim';
import translateRoutes from './routes/translate';

const app = express();
const server = http.createServer(app);

// Middleware
app.use(cors());
app.use(express.json({ limit: '50mb' }));
app.use(rateLimiter);

// Подключение Socket.io
setupSocket(server);

// Роуты
app.get('/health', (_req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/chats', chatRoutes);
app.use('/api/calls', callRoutes);
app.use('/api/stories', storyRoutes);
app.use('/api/marketplace', marketplaceRoutes);
app.use('/api/calendar', calendarRoutes);
app.use('/api/esim', esimRoutes);
app.use('/api/translate', translateRoutes);

// Обработка ошибок
app.use((err: any, _req: any, res: any, _next: any) => {
  console.error('Ошибка:', err.message);
  res.status(err.status || 500).json({
    error: err.message || 'Внутренняя ошибка сервера',
  });
});

// Запуск сервера
server.listen(config.port, () => {
  console.log(`🚀 Сервер запущен на порту ${config.port}`);
  console.log(`📱 Окружение: ${config.nodeEnv}`);
  console.log(`🔌 Socket.io подключен`);
});

export default app;
