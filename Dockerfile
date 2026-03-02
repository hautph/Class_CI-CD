# Bước 1: Build stage (Cài đặt dependencies)
FROM node:20-alpine AS build

# Tạo thư mục làm việc
WORKDIR /app

# Copy package.json và package-lock.json trước để tận dụng Docker Cache
COPY package*.json ./

# Cài đặt dependencies
RUN npm ci --only=production

# Copy toàn bộ mã nguồn
COPY . .

# Bước 2: Production stage (Tạo image nhẹ nhất có thể)
FROM node:20-alpine

WORKDIR /app

# Chỉ copy những thứ cần thiết từ build stage sang
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/src ./src
COPY --from=build /app/server.js ./server.js
COPY --from=build /app/package.json ./package.json

# --- FIX START ---
# Loại bỏ npm và corepack khỏi image cuối cùng.
# Ứng dụng production không cần công cụ quản lý gói (package manager) để chạy.
# Việc này xóa các thư mục chứa lỗ hổng bảo mật mà Trivy đã phát hiện.
RUN rm -rf /usr/local/lib/node_modules/npm && \
    rm -rf /usr/local/lib/node_modules/corepack && \
    rm -rf /usr/local/bin/npm
# --- FIX END ---

# 2. Tạo user mới và cấp quyền (Alpine đã có sẵn user 'node')
# USER node

# Cấu hình biến môi trường mặc định
ENV NODE_ENV=production
ENV PORT=3000

# Mở cổng 3000
EXPOSE 3000

# Cài đặt dumb-init
RUN apk add --no-cache dumb-init
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

# Lệnh khởi chạy ứng dụng
CMD ["node", "server.js"]