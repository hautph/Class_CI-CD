# Bước 1: Build stage (Cài đặt dependencies)
FROM node:20-alpine AS build

# Tạo thư mục làm việc
WORKDIR /app

# Copy package.json và package-lock.json trước để tận dụng Docker Cache
COPY package*.json ./

# Cài đặt dependencies (chỉ cài production nếu không cần build bước phụ)
RUN npm ci --only=production

# Copy toàn bộ mã nguồn (bao gồm thư mục src và file server.js)
COPY . .

# Bước 2: Production stage (Tạo image nhẹ nhất có thể)
FROM node:20-alpine

WORKDIR /app

# Chỉ copy những thứ cần thiết từ build stage sang
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/src ./src
COPY --from=build /app/server.js ./server.js
COPY --from=build /app/package.json ./package.json

# Cấu hình biến môi trường mặc định
ENV NODE_ENV=production
ENV PORT=3000

# Mở cổng 3000 (phải khớp với cổng app.listen trong server.js)
EXPOSE 3000

# Sử dụng dumb-init để xử lý các tín hiệu (SIGTERM, SIGINT) tốt hơn trên Docker
# (Tùy chọn: giúp Graceful Shutdown hoạt động chuẩn hơn)
RUN apk add --no-cache dumb-init
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

# Lệnh khởi chạy ứng dụng
CMD ["node", "server.js"]