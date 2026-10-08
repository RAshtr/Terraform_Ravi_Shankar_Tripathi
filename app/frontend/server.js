const express = require('express');
const axios = require('axios');
const path = require('path');

const app = express();
const PORT = 3000;
const BACKEND_URL = process.env.BACKEND_URL || 'http://backend:5000';

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, 'public')));

app.post('/api/submit', async (req, res) => {
    try {
        const response = await axios.post(`${BACKEND_URL}/submit`, req.body);
        res.status(200).json(response.data);
    } catch (error) {
        console.error('Backend connection error:', error.message);
        res.status(500).json({ status: 'error', message: 'Unable to connect to Flask backend' });
    }
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Frontend running on port ${PORT}`);
});