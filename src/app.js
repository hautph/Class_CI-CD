const express = require('express');
const app = express();
const helmet = require('helmet');
app.use(helmet());

// Giới hạn số lượng request (Rate Limiting) để chống tấn công DOS
const rateLimit = require('express-rate-limit');
const limiter = rateLimit({
	windowMs: 15 * 60 * 1000, // 15 phút
	max: 100 // Tối đa 100 request/IP
});
app.use(limiter);

// Middleware đọc dữ liệu JSON từ Request
app.use(express.json());

// Middleware Logging đơn giản
app.use((req, res, next) => {
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.url}`);
    next();
});

// Route Health Check (Dùng cho Docker/CI-CD kiểm tra tình trạng app)
app.get('/health', (req, res) => {
    res.status(200).json({ status: 'UP', uptime: process.uptime() });
});

// Import Routes thực tế
app.get('/', (req, res) => {
    res.json({ message: 'Welcome to Advanced CI/CD App', version: '1.1.0' });
});

// Xử lý lỗi 404 (Not Found)
app.use((req, res) => {
    res.status(404).json({ error: 'Route not found' });
});

module.exports = app;
