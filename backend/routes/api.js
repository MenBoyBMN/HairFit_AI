// ============================================================================
// File: backend/routes/api.js
// Description: RESTful API Endpoints cho HairFit AI Node.js Express Server
// ============================================================================

const express = require('express');
const router = express.Router();

const hairstylesData = require('../data/hairstyles');
let barbersData = require('../data/barbers');
const usersData = require('../data/users');
const reviewsData = require('../data/reviews');

// 1. Health check Endpoint
router.get('/health', (req, res) => {
  res.json({
    status: 'success',
    message: 'HairFit AI RESTful Web API Server is running smoothly!',
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

// 2. HAIRSTYLES ENDPOINTS (50 kiểu tóc)
router.get('/hairstyles', (req, res) => {
  const { faceShape, q } = req.query;
  let results = [...hairstylesData];

  if (faceShape) {
    const cleanShape = faceShape.toLowerCase().trim();
    results = results.filter(h => h.faceShapes.includes(cleanShape));
  }

  if (q) {
    const query = q.toLowerCase().trim();
    results = results.filter(h =>
      h.name.toLowerCase().includes(query) ||
      h.description.toLowerCase().includes(query) ||
      h.tags.some(t => t.toLowerCase().includes(query))
    );
  }

  res.json({ status: 'success', count: results.length, data: results });
});

router.get('/hairstyles/:id', (req, res) => {
  const item = hairstylesData.find(h => h.id === req.params.id);
  if (!item) {
    return res.status(404).json({ status: 'error', message: 'Không tìm thấy kiểu tóc' });
  }
  res.json({ status: 'success', data: item });
});

// 3. BARBERS ENDPOINTS (CRUD 150 thợ)
router.get('/barbers', (req, res) => {
  const { q, maxPrice, minRating } = req.query;
  let results = [...barbersData];

  if (q) {
    const query = q.toLowerCase().trim();
    results = results.filter(b =>
      b.displayName.toLowerCase().includes(query) ||
      b.address.toLowerCase().includes(query)
    );
  }

  if (maxPrice) {
    results = results.filter(b => b.priceMin <= parseInt(maxPrice));
  }

  if (minRating) {
    results = results.filter(b => b.ratingAvg >= parseFloat(minRating));
  }

  res.json({ status: 'success', count: results.length, data: results });
});

router.get('/barbers/:id', (req, res) => {
  const barber = barbersData.find(b => b.uid === req.params.id);
  if (!barber) {
    return res.status(404).json({ status: 'error', message: 'Không tìm thấy thợ' });
  }
  res.json({ status: 'success', data: barber });
});

// POST /barbers (Create Barber)
router.post('/barbers', (req, res) => {
  const newBarber = {
    uid: `barber_api_${Date.now()}`,
    displayName: req.body.displayName || 'Barber Mới',
    address: req.body.address || 'Đà Nẵng',
    priceMin: req.body.priceMin || 80000,
    priceMax: req.body.priceMax || 150000,
    ratingAvg: 5.0,
    ratingCount: 1,
    approvalStatus: 'approved',
    isAcceptingBookingsToday: true,
    services: req.body.services || []
  };

  barbersData.unshift(newBarber);
  res.status(201).json({ status: 'success', message: 'Thêm thợ mới thành công!', data: newBarber });
});

// PUT /barbers/:id (Update Barber)
router.put('/barbers/:id', (req, res) => {
  const idx = barbersData.findIndex(b => b.uid === req.params.id);
  if (idx === -1) {
    return res.status(404).json({ status: 'error', message: 'Không tìm thấy thợ' });
  }

  barbersData[idx] = { ...barbersData[idx], ...req.body, updatedAt: new Date().toISOString() };
  res.json({ status: 'success', message: 'Cập nhật hồ sơ thợ thành công!', data: barbersData[idx] });
});

// DELETE /barbers/:id (Delete Barber)
router.delete('/barbers/:id', (req, res) => {
  const initialLen = barbersData.length;
  barbersData = barbersData.filter(b => b.uid !== req.params.id);

  if (barbersData.length === initialLen) {
    return res.status(404).json({ status: 'error', message: 'Không tìm thấy thợ để xóa' });
  }

  res.json({ status: 'success', message: 'Đã xóa thợ cắt tóc khỏi hệ thống' });
});

// 4. USERS ENDPOINTS (50 Khách hàng)
router.get('/users', (req, res) => {
  res.json({ status: 'success', count: usersData.length, data: usersData });
});

// 5. REVIEWS ENDPOINTS (100 Đánh giá)
router.get('/reviews', (req, res) => {
  res.json({ status: 'success', count: reviewsData.length, data: reviewsData });
});

// 6. AI CONSULT ENDPOINT
router.post('/ai-consult', (req, res) => {
  const { faceShape } = req.body;
  if (!faceShape) {
    return res.status(400).json({ status: 'error', message: 'Thiếu tham số faceShape' });
  }

  const cleanShape = faceShape.toLowerCase().trim();
  const matching = hairstylesData.filter(h => h.faceShapes.includes(cleanShape));

  res.json({
    status: 'success',
    faceShape: cleanShape,
    count: matching.length,
    recommendations: matching.map(style => ({
      style,
      suitabilityScore: 92,
      aiStylingTip: `Kiểu ${style.name} rất phù hợp với dáng mặt ${cleanShape} của bạn!`
    }))
  });
});

// 7. BOOKING ENDPOINT
router.post('/booking', (req, res) => {
  const { customerId, barberId, serviceId, date, startTime } = req.body;
  if (!customerId || !barberId || !serviceId || !date || !startTime) {
    return res.status(400).json({ status: 'error', message: 'Thiếu thông tin đặt lịch bắt buộc' });
  }

  res.status(201).json({
    status: 'success',
    message: 'Đặt lịch thành công qua REST Web API!',
    booking: {
      id: `app_api_${Date.now()}`,
      customerId, barberId, serviceId, date, startTime, status: 'pending'
    }
  });
});

module.exports = router;
