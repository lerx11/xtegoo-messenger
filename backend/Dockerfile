FROM node:20

WORKDIR /app

RUN apt-get update && apt-get install -y openssl && rm -rf /var/lib/apt/lists/*

COPY package*.json ./
RUN npm install

COPY . .
RUN npx prisma generate
RUN npm run build

# Проверяем что dist создался
RUN ls -la dist/

EXPOSE 3000

CMD ["sh", "-c", "npx prisma db push && node dist/index.js"]
