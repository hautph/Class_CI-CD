require('dotenv').config(); // Dòng này cực kỳ quan trọng
const express = require('express');
const app = express();

// Sử dụng biến PORT từ .env, nếu không có thì mặc định là 3000
const PORT = process.env.PORT || 3000; 

app.get('/', (req, res) => {
    res.send('Hello CI/CD!');
});

app.listen(PORT, () => {
    console.log(`Server running http://localhost:${PORT}`);
});
