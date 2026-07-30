FROM node:20

WORKDIR /app

RUN apt-get update && apt-get install -y openssl && rm -rf /var/lib/apt/lists/*

COPY package*.json ./
RUN npm install

COPY . .
RUN npx prisma generate

# Чистим dist и node_modules/.cache, затем компилируем без кеша
RUN rm -rf dist node_modules/.cache
RUN npx tsc --build --force

RUN ls -la dist/validators/

EXPOSE 3000

CMD ["sh", "-c", "npx prisma db push && node dist/index.js"]
