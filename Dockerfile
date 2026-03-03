# --- Bước 1: Build stage ---
FROM node:25-slim AS build
WORKDIR /app
# Chỉ copy file package để tận dụng cache layer
COPY package*.json ./
# Cài đặt và dọn dẹp npm cache ngay lập tức
RUN npm ci --only=production && npm cache clean --force
COPY . .

# --- Bước 2: Production stage ---
FROM node:25-slim
WORKDIR /app

# 1. Tối ưu cài đặt: Gộp lệnh, dùng --no-install-recommends và xóa cache apt
RUN apt-get update && \
    apt-get install -y --no-install-recommends tzdata dumb-init && \
    ln -fs /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata && \
    # Xóa toàn bộ file tạm của apt để giảm dung lượng image
    apt-get purge -y --auto-remove && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 2. Copy chọn lọc từ build stage (Chỉ lấy những gì thực sự cần để chạy)
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/src ./src
COPY --from=build /app/server.js ./server.js
COPY --from=build /app/package.json ./package.json

# 3. Hardening & Slimming: Xóa các công cụ quản lý package không cần thiết ở Prod
RUN rm -rf /usr/local/lib/node_modules/npm \
           /usr/local/lib/node_modules/corepack \
           /usr/local/bin/npm \
           /usr/local/bin/npx \
           /opt /root/.npm

# Biến môi trường
ENV NODE_ENV=production \
    PORT=3000 \
    TZ=Asia/Ho_Chi_Minh

EXPOSE 3000

# Sử dụng dumb-init để quản lý process tốt hơn
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD ["node", "server.js"]
