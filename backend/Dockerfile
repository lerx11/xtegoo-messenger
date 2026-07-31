FROM node:20

WORKDIR /app

RUN apt-get update && apt-get install -y openssl && rm -rf /var/lib/apt/lists/*

COPY package*.json ./
RUN npm install

COPY . .

# Генерируем Prisma client
RUN npx prisma generate

# Удаляем кеш TypeScript и dist перед сборкой
RUN rm -rf dist node_modules/.cache tsconfig.tsbuildinfo

# Компилируем TypeScript
RUN npx tsc --build --force

# Проверяем что всё скомпилировалось
RUN ls -la dist/validators/ && ls -la dist/services/authService.js

EXPOSE 3000

CMD ["sh", "-c", "npx prisma db push && node dist/index.js"]
