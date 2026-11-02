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
app.use(helmet({
  crossOriginResourcePolicy: false,
}));
app.use(cors({
  origin: true,
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'Accept', 'ngrok-skip-browser-warning', 'x-requested-with']
}));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Health Check Endpoints
app.get(['/health', '/api/health'], (req, res) => {
  res.json({
    status: 'healthy',
    service: 'HairFit.Api.Node',
    timestamp: new Date().toISOString()
  });
});

// Welcome root
app.get('/', (req, res) => {
  res.json({
    name: 'HairFit AI RESTful Web API',
    description: 'Backend Web API Server cho Đồ Án Môn Học HairFit AI Flutter',
    status: 'ONLINE 🚀',
    documentation: '/api/v1/health',
    endpoints: {
      health: 'GET /api/health hoặc /api/v1/health',
      hairstyles: 'GET /api/hairstyles hoặc /api/v1/hairstyles',
      barbersApproved: 'GET /api/barbers/approved',
      barbersFeatured: 'GET /api/barbers/featured',
      aiConsult: 'POST /api/ai-consult hoặc /api/v1/ai-consult',
      booking: 'POST /api/booking hoặc /api/v1/booking'
    }
  });
});

// API Routes: Hỗ trợ cả 2 tiền tố /api và /api/v1 cho Flutter Frontend & Vercel
app.use('/api', apiRoutes);
app.use('/api/v1', apiRoutes);

// 404 Handler
app.use((req, res) => {
  res.status(404).json({
    status: 'error',
    code: 'ROUTE_NOT_FOUND',
    message: `Endpoint ${req.method} ${req.originalUrl} không tồn tại trên hệ thống.`
  });
});

// Global Error Handler
app.use((err, req, res, next) => {
  console.error('⚠️ [Server Error]:', err);
  const status = err.status || err.statusCode || 500;
  res.status(status).json({
    status: 'error',
    code: err.code || 'INTERNAL_SERVER_ERROR',
    message: err.message || 'Lỗi hệ thống máy chủ'
  });
});

// Process Safety Listeners
process.on('unhandledRejection', (reason, promise) => {
  console.error('⚠️ [HairFit Backend] Unhandled Rejection:', reason);
});

process.on('uncaughtException', (err) => {
  console.error('⚠️ [HairFit Backend] Uncaught Exception:', err);
});

// Start Server
if (process.env.NODE_ENV !== 'test') {
  app.listen(PORT, '0.0.0.0', () => {
    console.log(`==================================================`);
    console.log(`🚀 HairFit AI Web API đang chạy tại: http://localhost:${PORT}`);
    console.log(`📡 Health Endpoint: http://localhost:${PORT}/api/health`);
    console.log(`📡 Swagger/V1 Health: http://localhost:${PORT}/api/v1/health`);
    console.log(`==================================================`);
  });
}

module.exports = app;
// CreBy: MenBoyBMN
