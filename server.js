require('dotenv').config();
const app = require('./src/app');

const PORT = process.env.PORT || 3000;
const NODE_ENV = process.env.NODE_ENV || 'development';

const server = app.listen(PORT, () => {
    console.log(`🚀 Server is running in ${NODE_ENV} mode`);
    console.log(`🔗 Local: http://localhost:${PORT}`);
});

// Xử lý đóng ứng dụng an toàn (Graceful Shutdown) - Rất quan trọng cho Docker/PM2
process.on('SIGTERM', () => {
    console.log('SIGTERM signal received: closing HTTP server');
    server.close(() => {
        console.log('HTTP server closed');
    });
});
