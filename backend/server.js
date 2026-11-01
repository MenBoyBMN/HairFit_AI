// ============================================================================
// File: backend/server.js
// Description: Main Entrypoint cho HairFit AI Node.js Express RESTful Web API
// ============================================================================

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
require('dotenv').config();

const apiRoutes = require('./routes/api');

const app = express();
const PORT = process.env.PORT || 3000;

// Security & Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Welcome root
app.get('/', (req, res) => {
  res.json({
    name: 'HairFit AI RESTful Web API',
    description: 'Backend Web API Server cho Đồ Án Môn Học HairFit AI Flutter',
    status: 'ONLINE 🚀',
    documentation: '/api/v1/health',
    endpoints: {
      health: 'GET /api/v1/health',
      hairstyles: 'GET /api/v1/hairstyles',
      aiConsult: 'POST /api/v1/ai-consult',
      booking: 'POST /api/v1/booking'
    }
  });
});

// API Routes
app.use('/api/v1', apiRoutes);

// 404 Handler
app.use((req, res) => {
  res.status(404).json({
    status: 'error',
    message: 'Endpoint không tồn tại'
  });
});

// Start Server
if (process.env.NODE_ENV !== 'test') {
  app.listen(PORT, () => {
    console.log(`==================================================`);
    console.log(`🚀 HairFit AI Web API đang chạy tại: http://localhost:${PORT}`);
    console.log(`📡 Health Endpoint: http://localhost:${PORT}/api/v1/health`);
    console.log(`==================================================`);
  });
}

module.exports = app;
