require('dotenv').config();
const express = require('express');
const app = express();

// Thiết lập múi giờ mặc định cho toàn bộ ứng dụng Node.js
process.env.TZ = 'Asia/Ho_Chi_Minh'; 

const PORT = process.env.PORT || 3000;

app.use(express.json());

// Hàm tiện ích để lấy thời gian Việt Nam định dạng đẹp
const getVNTime = () => {
    return new Date().toLocaleString('vi-VN', {
        timeZone: 'Asia/Ho_Chi_Minh',
        dateStyle: 'full',
        timeStyle: 'medium'
    });
};

// Route chính
app.get('/', (req, res) => {
    res.json({ 
        message: 'Hello CI/CD with Docker Compose!', 
        timestamp: new Date(), // Giờ chuẩn ISO
        local_time: getVNTime() // Giờ Việt Nam dễ đọc
    });
});

// Route Healthcheck
app.get('/health', (req, res) => {
    res.status(200).json({ 
        status: 'UP', 
        uptime: `${Math.floor(process.uptime())} seconds`,
        server_time: getVNTime(), // Giúp bạn check log xem server có đang chạy đúng giờ không
        memory: `${Math.round(process.memoryUsage().heapUsed / 1024 / 1024)} MB`
    });
});

const server = app.listen(PORT, () => {
    console.log(`🚀 Server is running on port ${PORT}`);
    console.log(`⏰ Current Time (VN): ${getVNTime()}`);
});

// Xử lý Graceful Shutdown
process.on('SIGTERM', () => {
    console.log(`[${getVNTime()}] SIGTERM received. Cleaning up...`);
    server.close(() => {
        console.log(`[${getVNTime()}] Server closed safely.`);
        process.exit(0);
    });
});
