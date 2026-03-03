# Bước 1: Build stage
FROM node:slim AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .

# Bước 2: Production stage
FROM node:slim
WORKDIR /app

# --- CẤU HÌNH GIỜ VIỆT NAM (ICT) ---
# Cài đặt tzdata để có dữ liệu múi giờ
RUN apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime && \
    echo "Asia/Ho_Chi_Minh" > /etc/timezone
# ----------------------------------

COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/src ./src
COPY --from=build /app/server.js ./server.js
COPY --from=build /app/package.json ./package.json

# --- FIX BẢO MẬT ---
RUN rm -rf /usr/local/lib/node_modules/npm && \
    rm -rf /usr/local/lib/node_modules/corepack && \
    rm -rf /usr/local/bin/npm
# -------------------

ENV NODE_ENV=production
ENV PORT=3000
# Thiết lập biến môi trường TZ để Node.js nhận diện múi giờ hệ thống
ENV TZ=Asia/Ho_Chi_Minh

EXPOSE 3000

RUN apk add --no-cache dumb-init
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD ["node", "server.js"]
