require('dotenv').config();
const express = require('express');
const app = express();

const PORT = process.env.PORT || 3000;

app.use(express.json());

// Route chính
app.get('/', (req, res) => {
    res.json({ message: 'Hello CI/CD with Docker Compose!', timestamp: new Date() });
});

// Route Healthcheck - Quan trọng cho Docker Compose & Verify Script
app.get('/health', (req, res) => {
    res.status(200).json({ 
        status: 'UP', 
        uptime: process.uptime(),
        memory: process.memoryUsage().heapUsed 
    });
});

const server = app.listen(PORT, () => {
    console.log(`🚀 Server is running on port ${PORT}`);
});

// Xử lý Graceful Shutdown khi Docker stop/restart
process.on('SIGTERM', () => {
    console.log('SIGTERM received. Cleaning up...');
    server.close(() => {
        console.log('Server closed safely.');
        process.exit(0);
    });
});
