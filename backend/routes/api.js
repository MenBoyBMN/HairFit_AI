// ============================================================================
// File: backend/routes/api.js
// Description: RESTful API Endpoints cho HairFit AI Node.js Express Server
// Tương thích 100% với các Route và DTO của ASP.NET Core & Flutter Client
// ============================================================================

const express = require('express');
const router = express.Router();

const hairstylesData = require('../data/hairstyles');
let barbersData = require('../data/barbers');
const usersData = require('../data/users');
const reviewsData = require('../data/reviews');

// Khởi tạo ngày hôm nay định dạng yyyy-MM-dd
const todayStr = new Date().toISOString().split('T')[0];

// In-Memory Database cho Appointments & BookedSlots phục vụ Mock & Vercel
let appointmentsData = [
  {
    id: 'app_sample_001',
    customerId: 'customer_seed_001',
    customerName: 'Nguyễn Văn An #1',
    customerPhone: '0905101234',
    barberId: 'barber_seed_001',
    barberName: 'HairFit Studio Đà Nẵng',
    barberPhone: '0905888999',
    serviceId: 'svc_combo',
    serviceName: 'Combo Cắt + Gội massage + Sấy vuốt',
    price: 120000,
    durationMinutes: 60,
    date: todayStr,
    startTime: '09:00',
    endTime: '10:00',
    startTimestamp: new Date(`${todayStr}T09:00:00Z`).toISOString(),
    endTimestamp: new Date(`${todayStr}T10:00:00Z`).toISOString(),
    timezone: 'Asia/Ho_Chi_Minh',
    slotIds: [`barber_seed_001_${todayStr}_09:00`, `barber_seed_001_${todayStr}_09:30`],
    hairstyleId: 'undercut',
    customerFaceShape: 'oval',
    aiStylingTip: 'Undercut cổ điển tôn góc cạnh và thon gọn khuôn mặt.',
    status: 'confirmed',
    note: 'Lần đầu cắt tại tiệm, vuốt sáp nhẹ nhàng.',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  }
];

let bookedSlotsData = [
  {
    slotId: `barber_seed_001_${todayStr}_09:00`,
    barberId: 'barber_seed_001',
    date: todayStr,
    startTime: '09:00',
    appointmentId: 'app_sample_001',
    isBlockedByBarber: false,
    createdAt: new Date().toISOString()
  },
  {
    slotId: `barber_seed_001_${todayStr}_09:30`,
    barberId: 'barber_seed_001',
    date: todayStr,
    startTime: '09:30',
    appointmentId: 'app_sample_001',
    isBlockedByBarber: false,
    createdAt: new Date().toISOString()
  }
];

let systemSettings = {
  key: 'global',
  searchRadiusKm: 10.0,
  cancelNoticeHours: 1,
  maintenanceMode: false,
  updatedAt: new Date().toISOString()
};

// Helper: Trả về kết quả phù hợp cho cả Flutter Client (mảng trực tiếp) và REST Legacy (vỏ bọc envelope)
function sendListResponse(req, res, list) {
  if (req.query.wrap === 'true') {
    return res.json({ status: 'success', count: list.length, data: list });
  }
  return res.json(list);
}

// ============================================================================
// 1. HEALTH CHECK ENDPOINT
// ============================================================================
router.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    service: 'HairFit.Api.Node',
    message: 'HairFit AI RESTful Web API Server is running smoothly!',
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

// ============================================================================
// 2. HAIRSTYLES ENDPOINTS
// ============================================================================
router.get('/hairstyles', (req, res) => {
  const { faceShape, q } = req.query;
  let results = [...hairstylesData];

  if (faceShape) {
    const cleanShape = faceShape.toLowerCase().trim();
    results = results.filter(h => h.faceShapes && h.faceShapes.includes(cleanShape));
  }

  if (q) {
    const query = q.toLowerCase().trim();
    results = results.filter(h =>
      (h.name && h.name.toLowerCase().includes(query)) ||
      (h.description && h.description.toLowerCase().includes(query)) ||
      (h.tags && h.tags.some(t => t.toLowerCase().includes(query)))
    );
  }

  sendListResponse(req, res, results);
});

router.get('/hairstyles/:id', (req, res) => {
  const item = hairstylesData.find(h => h.id === req.params.id);
  if (!item) {
    return res.status(404).json({ code: 'HAIRSTYLE_NOT_FOUND', message: 'Không tìm thấy kiểu tóc' });
  }
  res.json(item);
});

// ============================================================================
// 3. BARBERS ENDPOINTS
// ============================================================================

// GET /barbers/approved (Flutter tìm kiếm salon & thợ)
router.get('/barbers/approved', (req, res) => {
  const approved = barbersData.filter(b => b.approvalStatus === 'approved');
  sendListResponse(req, res, approved);
});

// GET /barbers/featured (Flutter trang chủ thợ nổi bật)
router.get('/barbers/featured', (req, res) => {
  const limit = parseInt(req.query.limit) || 5;
  const featured = [...barbersData]
    .filter(b => b.approvalStatus === 'approved')
    .sort((a, b) => (b.ratingAvg || 0) - (a.ratingAvg || 0))
    .slice(0, limit);
  sendListResponse(req, res, featured);
});

// GET /barbers/pending (Thợ đang chờ duyệt)
router.get('/barbers/pending', (req, res) => {
  const pending = barbersData.filter(b => b.approvalStatus === 'pending');
  sendListResponse(req, res, pending);
});

// GET /barbers (Danh sách chung với bộ lọc)
router.get('/barbers', (req, res) => {
  const { q, maxPrice, minRating } = req.query;
  let results = [...barbersData];

  if (q) {
    const query = q.toLowerCase().trim();
    results = results.filter(b =>
      (b.displayName && b.displayName.toLowerCase().includes(query)) ||
      (b.address && b.address.toLowerCase().includes(query))
    );
  }

  if (maxPrice) {
    results = results.filter(b => (b.priceMin || 0) <= parseInt(maxPrice));
  }

  if (minRating) {
    results = results.filter(b => (b.ratingAvg || 0) >= parseFloat(minRating));
  }

  sendListResponse(req, res, results);
});

// GET /barbers/:id/reviews
router.get('/barbers/:id/reviews', (req, res) => {
  const reviews = reviewsData.filter(r => r.barberId === req.params.id);
  sendListResponse(req, res, reviews);
});

// GET /barbers/:id (Chi tiết hồ sơ thợ)
router.get('/barbers/:id', (req, res) => {
  const barber = barbersData.find(b => b.uid === req.params.id);
  if (!barber) {
    return res.status(404).json({ code: 'BARBER_NOT_FOUND', message: 'Không tìm thấy hồ sơ thợ' });
  }
  res.json(barber);
});

// PUT /barbers/:id (Tạo mới hoặc cập nhật hồ sơ thợ)
router.put('/barbers/:id', (req, res) => {
  const idx = barbersData.findIndex(b => b.uid === req.params.id);
  const now = new Date().toISOString();

  if (idx === -1) {
    const newBarber = {
      uid: req.params.id,
      displayName: req.body.displayName || 'Barber Mới',
      avatarUrl: req.body.avatarUrl || '',
      coverUrl: req.body.coverUrl || '',
      bio: req.body.bio || '',
      address: req.body.address || 'Đà Nẵng',
      location: req.body.location || { latitude: 16.0544, longitude: 108.2022 },
      priceMin: req.body.priceMin || 80000,
      priceMax: req.body.priceMax || 150000,
      ratingAvg: 5.0,
      ratingCount: 1,
      approvalStatus: req.body.approvalStatus || 'pending',
      isAcceptingBookingsToday: req.body.isAcceptingBookingsToday !== undefined ? req.body.isAcceptingBookingsToday : true,
      services: req.body.services || [],
      workingHours: req.body.workingHours || {},
      exceptions: req.body.exceptions || [],
      createdAt: now,
      updatedAt: now
    };
    barbersData.unshift(newBarber);
    return res.status(201).json(newBarber);
  }

  barbersData[idx] = { ...barbersData[idx], ...req.body, updatedAt: now };
  res.json(barbersData[idx]);
});

// PATCH /barbers/:id/status (Duyệt hoặc tạm dừng thợ)
router.patch('/barbers/:id/status', (req, res) => {
  const { approvalStatus } = req.body;
  const barber = barbersData.find(b => b.uid === req.params.id);
  if (!barber) {
    return res.status(404).json({ code: 'BARBER_NOT_FOUND', message: 'Không tìm thấy thợ' });
  }
  barber.approvalStatus = approvalStatus || barber.approvalStatus;
  barber.updatedAt = new Date().toISOString();
  res.json({ message: 'Cập nhật trạng thái thành công', barber });
});

// PATCH /barbers/:id/accepting-bookings
router.patch('/barbers/:id/accepting-bookings', (req, res) => {
  const { isAcceptingBookingsToday } = req.body;
  const barber = barbersData.find(b => b.uid === req.params.id);
  if (!barber) {
    return res.status(404).json({ code: 'BARBER_NOT_FOUND', message: 'Không tìm thấy thợ' });
  }
  barber.isAcceptingBookingsToday = !!isAcceptingBookingsToday;
  barber.updatedAt = new Date().toISOString();
  res.json({ message: 'Cập nhật trạng thái nhận khách thành công', barber });
});

// POST /barbers (Thêm thợ mới)
router.post('/barbers', (req, res) => {
  const newBarber = {
    uid: req.body.uid || `barber_api_${Date.now()}`,
    displayName: req.body.displayName || 'Barber Mới',
    address: req.body.address || 'Đà Nẵng',
    location: req.body.location || { latitude: 16.0544, longitude: 108.2022 },
    priceMin: req.body.priceMin || 80000,
    priceMax: req.body.priceMax || 150000,
    ratingAvg: 5.0,
    ratingCount: 1,
    approvalStatus: 'approved',
    isAcceptingBookingsToday: true,
    services: req.body.services || [],
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  };

  barbersData.unshift(newBarber);
  res.status(201).json(newBarber);
});

// DELETE /barbers/:id
router.delete('/barbers/:id', (req, res) => {
  const initialLen = barbersData.length;
  barbersData = barbersData.filter(b => b.uid !== req.params.id);

  if (barbersData.length === initialLen) {
    return res.status(404).json({ code: 'BARBER_NOT_FOUND', message: 'Không tìm thấy thợ để xóa' });
  }

  res.json({ message: 'Đã xóa thợ cắt tóc khỏi hệ thống' });
});

// ============================================================================
// 4. USERS ENDPOINTS
// ============================================================================
router.get('/users', (req, res) => {
  sendListResponse(req, res, usersData);
});

router.get('/users/:id', (req, res) => {
  const user = usersData.find(u => u.uid === req.params.id);
  if (!user) {
    return res.status(404).json({ code: 'USER_NOT_FOUND', message: 'Không tìm thấy người dùng' });
  }
  if (user.isBlocked) {
    return res.status(403).json({ code: 'BLOCKED_ACCOUNT', message: 'Tài khoản của bạn đã bị khóa.' });
  }
  res.json(user);
});

router.post('/users/sync', (req, res) => {
  const { uid, email, displayName, role, avatarUrl, phone } = req.body;
  if (!uid) {
    return res.status(400).json({ code: 'INVALID_UID', message: 'UID không được để trống' });
  }

  let user = usersData.find(u => u.uid === uid);
  const now = new Date().toISOString();

  if (!user) {
    user = {
      uid,
      email: email || '',
      displayName: displayName || (email ? email.split('@')[0] : 'Người dùng'),
      avatarUrl: avatarUrl || '',
      role: role ? role.toLowerCase() : 'customer',
      phone: phone || null,
      savedFaceShape: null,
      savedHairstyleIds: [],
      favoriteBarberIds: [],
      isBlocked: false,
      createdAt: now,
      updatedAt: now
    };
    usersData.push(user);
  } else {
    if (displayName) user.displayName = displayName;
    if (avatarUrl) user.avatarUrl = avatarUrl;
    if (phone) user.phone = phone;
    user.updatedAt = now;
  }

  res.json(user);
});

router.put('/users/:id', (req, res) => {
  const user = usersData.find(u => u.uid === req.params.id);
  if (!user) {
    return res.status(404).json({ code: 'USER_NOT_FOUND', message: 'Không tìm thấy người dùng' });
  }

  if (req.body.displayName) user.displayName = req.body.displayName;
  if (req.body.avatarUrl) user.avatarUrl = req.body.avatarUrl;
  if (req.body.phone !== undefined) user.phone = req.body.phone;
  user.updatedAt = new Date().toISOString();

  res.json(user);
});

router.post('/users/:id/saved-face-shape', (req, res) => {
  const user = usersData.find(u => u.uid === req.params.id);
  if (!user) {
    return res.status(404).json({ code: 'USER_NOT_FOUND', message: 'Không tìm thấy người dùng' });
  }

  user.savedFaceShape = req.body.faceShape || user.savedFaceShape;
  user.updatedAt = new Date().toISOString();
  res.json({ message: 'Đã lưu dáng mặt', user });
});

router.post('/users/:id/favorite-barbers', (req, res) => {
  const user = usersData.find(u => u.uid === req.params.id);
  if (!user) {
    return res.status(404).json({ code: 'USER_NOT_FOUND', message: 'Không tìm thấy người dùng' });
  }

  const { barberId } = req.body;
  user.favoriteBarberIds = user.favoriteBarberIds || [];
  if (user.favoriteBarberIds.includes(barberId)) {
    user.favoriteBarberIds = user.favoriteBarberIds.filter(id => id !== barberId);
  } else if (barberId) {
    user.favoriteBarberIds.push(barberId);
  }

  user.updatedAt = new Date().toISOString();
  res.json({ message: 'Đã cập nhật thợ yêu thích', favoriteBarberIds: user.favoriteBarberIds });
});

// ============================================================================
// 5. APPOINTMENTS ENDPOINTS
// ============================================================================
router.get('/appointments/customer/:customerId', (req, res) => {
  const list = appointmentsData
    .filter(a => a.customerId === req.params.customerId)
    .sort((a, b) => new Date(b.startTimestamp) - new Date(a.startTimestamp));
  sendListResponse(req, res, list);
});

router.get('/appointments/barber/:barberId', (req, res) => {
  const list = appointmentsData
    .filter(a => a.barberId === req.params.barberId)
    .sort((a, b) => new Date(b.startTimestamp) - new Date(a.startTimestamp));
  sendListResponse(req, res, list);
});

router.get('/appointments/:id', (req, res) => {
  const app = appointmentsData.find(a => a.id === req.params.id);
  if (!app) {
    return res.status(404).json({ code: 'APPOINTMENT_NOT_FOUND', message: 'Lịch hẹn không tồn tại' });
  }
  res.json(app);
});

router.post('/appointments/:id/confirm', (req, res) => {
  const app = appointmentsData.find(a => a.id === req.params.id);
  if (!app) {
    return res.status(404).json({ code: 'BOOKING_ERROR', message: 'Lịch hẹn không tồn tại' });
  }
  if (app.status !== 'pending') {
    return res.status(400).json({ code: 'BOOKING_ERROR', message: 'Chỉ có thể xác nhận lịch hẹn ở trạng thái chờ duyệt' });
  }

  app.status = 'confirmed';
  app.updatedAt = new Date().toISOString();
  res.json(app);
});

router.post('/appointments/:id/reject', (req, res) => {
  const app = appointmentsData.find(a => a.id === req.params.id);
  if (!app) {
    return res.status(404).json({ code: 'BOOKING_ERROR', message: 'Lịch hẹn không tồn tại' });
  }

  app.status = 'rejected';
  app.rejectReason = req.body.reason || 'Thợ bận đột xuất';
  app.updatedAt = new Date().toISOString();

  // Giải phóng slot
  bookedSlotsData = bookedSlotsData.filter(s => s.appointmentId !== app.id);
  res.json(app);
});

router.post('/appointments/:id/complete', (req, res) => {
  const app = appointmentsData.find(a => a.id === req.params.id);
  if (!app) {
    return res.status(404).json({ code: 'BOOKING_ERROR', message: 'Lịch hẹn không tồn tại' });
  }

  app.status = 'completed';
  app.updatedAt = new Date().toISOString();
  res.json(app);
});

router.post('/appointments/:id/rate', (req, res) => {
  const app = appointmentsData.find(a => a.id === req.params.id);
  if (!app) {
    return res.status(404).json({ code: 'BOOKING_ERROR', message: 'Lịch hẹn không tồn tại' });
  }

  const { rating, comment, customerName } = req.body;
  app.rating = rating || 5;
  app.reviewComment = comment || '';
  app.updatedAt = new Date().toISOString();

  reviewsData.unshift({
    id: `rev_api_${Date.now()}`,
    barberId: app.barberId,
    customerId: app.customerId,
    customerName: customerName || app.customerName,
    rating: app.rating,
    reviewComment: app.reviewComment,
    createdAt: new Date().toISOString()
  });

  res.json({ message: 'Đánh giá thành công', appointment: app });
});

router.patch('/appointments/:id/private-note', (req, res) => {
  const app = appointmentsData.find(a => a.id === req.params.id);
  if (!app) {
    return res.status(404).json({ code: 'BOOKING_ERROR', message: 'Lịch hẹn không tồn tại' });
  }

  app.barberPrivateNote = req.body.note || '';
  app.updatedAt = new Date().toISOString();
  res.json(app);
});

// ============================================================================
// 6. BOOKINGS & SLOTS ENDPOINTS
// ============================================================================
router.get('/bookings/active-count/:customerId', (req, res) => {
  const count = appointmentsData.filter(
    a => a.customerId === req.params.customerId && (a.status === 'pending' || a.status === 'confirmed')
  ).length;
  res.json({ count });
});

router.get('/bookings/slots', (req, res) => {
  const { barberId, date } = req.query;
  if (!barberId || !date) {
    return res.json([]);
  }

  const slots = bookedSlotsData.filter(s => s.barberId === barberId && s.date === date);
  sendListResponse(req, res, slots);
});

router.post('/bookings', (req, res) => {
  const { customerId, barberId, serviceId, date, startTime, slotIds } = req.body;
  if (!customerId || !barberId || !serviceId || !date || !startTime) {
    return res.status(400).json({ code: 'VALIDATION_ERROR', message: 'Thiếu thông tin đặt lịch bắt buộc' });
  }

  // Kiểm tra trùng slot (Atomic Conflict Detection)
  const requestedSlots = Array.isArray(slotIds) && slotIds.length > 0 ? slotIds : [`${barberId}_${date}_${startTime}`];
  const conflict = bookedSlotsData.some(
    s => s.barberId === barberId && s.date === date && requestedSlots.includes(s.slotId)
  );

  if (conflict) {
    return res.status(409).json({ code: 'SLOT_ALREADY_BOOKED', message: 'Khung giờ bạn vừa chọn đã có khách khác giữ chỗ.' });
  }

  const newAppId = `app_api_${Date.now()}`;
  const now = new Date().toISOString();
  const barber = barbersData.find(b => b.uid === barberId);
  const user = usersData.find(u => u.uid === customerId);

  const newAppointment = {
    id: newAppId,
    customerId,
    customerName: user ? user.displayName : (req.body.customerName || 'Khách hàng'),
    customerPhone: user ? user.phone : (req.body.customerPhone || null),
    barberId,
    barberName: barber ? barber.displayName : (req.body.barberName || 'Barber Studio'),
    barberPhone: barber ? barber.phone : (req.body.barberPhone || null),
    serviceId,
    serviceName: req.body.serviceName || 'Cắt tóc tạo kiểu',
    price: req.body.price || 80000,
    durationMinutes: req.body.durationMinutes || 30,
    date,
    startTime,
    endTime: req.body.endTime || '09:30',
    startTimestamp: new Date(`${date}T${startTime}:00Z`).toISOString(),
    endTimestamp: new Date(`${date}T${req.body.endTime || '09:30'}:00Z`).toISOString(),
    timezone: 'Asia/Ho_Chi_Minh',
    slotIds: requestedSlots,
    hairstyleId: req.body.hairstyleId || '',
    customerFaceShape: req.body.customerFaceShape || null,
    aiStylingTip: req.body.aiStylingTip || null,
    hairstyleImageUrl: req.body.hairstyleImageUrl || null,
    status: 'pending',
    note: req.body.note || '',
    createdAt: now,
    updatedAt: now
  };

  appointmentsData.unshift(newAppointment);

  // Khóa slot
  for (const slotId of requestedSlots) {
    bookedSlotsData.push({
      slotId,
      barberId,
      date,
      startTime,
      appointmentId: newAppId,
      isBlockedByBarber: false,
      createdAt: now
    });
  }

  res.status(201).json({
    message: 'Đặt lịch thành công qua REST Web API!',
    appointmentId: newAppId,
    booking: newAppointment
  });
});

router.post('/bookings/:id/cancel', (req, res) => {
  const app = appointmentsData.find(a => a.id === req.params.id);
  if (!app) {
    return res.status(404).json({ code: 'BOOKING_ERROR', message: 'Lịch hẹn không tồn tại' });
  }

  app.status = 'cancelled';
  app.updatedAt = new Date().toISOString();
  bookedSlotsData = bookedSlotsData.filter(s => s.appointmentId !== app.id);

  res.json({ message: 'Hủy lịch hẹn thành công', appointment: app });
});

router.post('/bookings/:id/reschedule', (req, res) => {
  const app = appointmentsData.find(a => a.id === req.params.id);
  if (!app) {
    return res.status(404).json({ code: 'BOOKING_ERROR', message: 'Lịch hẹn không tồn tại' });
  }

  const { newDate, newStartTime, newEndTime, newSlotIds } = req.body;
  if (!newDate || !newStartTime) {
    return res.status(400).json({ code: 'VALIDATION_ERROR', message: 'Thiếu thông tin dời lịch' });
  }

  // Giải phóng slot cũ
  bookedSlotsData = bookedSlotsData.filter(s => s.appointmentId !== app.id);

  app.date = newDate;
  app.startTime = newStartTime;
  app.endTime = newEndTime || app.endTime;
  app.slotIds = newSlotIds || [`${app.barberId}_${newDate}_${newStartTime}`];
  app.startTimestamp = new Date(`${newDate}T${newStartTime}:00Z`).toISOString();
  app.endTimestamp = new Date(`${newDate}T${app.endTime}:00Z`).toISOString();
  app.updatedAt = new Date().toISOString();

  // Khóa slot mới
  for (const slotId of app.slotIds) {
    bookedSlotsData.push({
      slotId,
      barberId: app.barberId,
      date: newDate,
      startTime: newStartTime,
      appointmentId: app.id,
      isBlockedByBarber: false,
      createdAt: new Date().toISOString()
    });
  }

  res.json({ message: 'Dời lịch hẹn thành công', appointment: app });
});

// ============================================================================
// 7. ADMIN PORTAL ENDPOINTS
// ============================================================================
router.get('/admin/stats', (req, res) => {
  const todayApps = appointmentsData.filter(a => a.date === todayStr);
  const revenueToday = todayApps
    .filter(a => a.status === 'completed')
    .reduce((sum, a) => sum + (a.price || 0), 0);
  const expectedRevenueToday = todayApps
    .filter(a => a.status === 'confirmed' || a.status === 'completed')
    .reduce((sum, a) => sum + (a.price || 0), 0);
  const totalRevenue = appointmentsData
    .filter(a => a.status === 'completed')
    .reduce((sum, a) => sum + (a.price || 0), 0);

  res.json({
    totalUsers: usersData.length,
    totalCustomers: usersData.filter(u => u.role === 'customer').length,
    totalBarbers: barbersData.length,
    totalAdmins: usersData.filter(u => u.role === 'admin').length,
    blockedUsers: usersData.filter(u => u.isBlocked).length,
    pendingBarbers: barbersData.filter(b => b.approvalStatus === 'pending').length,
    approvedBarbers: barbersData.filter(b => b.approvalStatus === 'approved').length,
    suspendedBarbers: barbersData.filter(b => b.approvalStatus === 'suspended').length,
    totalAppointmentsToday: todayApps.length,
    pendingAppointmentsToday: todayApps.filter(a => a.status === 'pending').length,
    confirmedAppointmentsToday: todayApps.filter(a => a.status === 'confirmed').length,
    completedAppointmentsToday: todayApps.filter(a => a.status === 'completed').length,
    cancelledAppointmentsToday: todayApps.filter(a => a.status === 'cancelled' || a.status === 'rejected').length,
    revenueToday,
    expectedRevenueToday,
    totalRevenue,
    totalHairstyles: hairstylesData.length,
    totalReviews: reviewsData.length
  });
});

router.get('/admin/users', (req, res) => {
  sendListResponse(req, res, usersData);
});

router.get('/admin/barbers', (req, res) => {
  sendListResponse(req, res, barbersData);
});

router.get('/admin/hairstyles', (req, res) => {
  sendListResponse(req, res, hairstylesData);
});

router.post('/admin/hairstyles', (req, res) => {
  const item = { ...req.body, id: req.body.id || `style_${Date.now()}` };
  hairstylesData.unshift(item);
  res.status(201).json(item);
});

router.delete('/admin/hairstyles/:id', (req, res) => {
  const idx = hairstylesData.findIndex(h => h.id === req.params.id);
  if (idx !== -1) hairstylesData.splice(idx, 1);
  res.json({ message: 'Đã xóa kiểu tóc' });
});

router.get('/admin/reviews', (req, res) => {
  sendListResponse(req, res, reviewsData);
});

router.delete('/admin/reviews/:id', (req, res) => {
  const idx = reviewsData.findIndex(r => r.id === req.params.id);
  if (idx !== -1) reviewsData.splice(idx, 1);
  res.json({ message: 'Đã xóa đánh giá' });
});

router.get('/admin/settings', (req, res) => {
  res.json(systemSettings);
});

router.put('/admin/settings', (req, res) => {
  systemSettings = { ...systemSettings, ...req.body, updatedAt: new Date().toISOString() };
  res.json(systemSettings);
});

// ============================================================================
// 8. SEED DATA ENDPOINTS
// ============================================================================
router.post('/seed/hairstyles', (req, res) => {
  res.json({ message: 'Đã nạp danh mục kiểu tóc mẫu thành công.' });
});

router.post('/seed/barbers', (req, res) => {
  res.json({ message: 'Đã nạp danh sách hồ sơ thợ mẫu thành công.' });
});

router.post('/seed/all', (req, res) => {
  res.json({ message: 'Đã nạp toàn bộ Seed Data thành công.' });
});

router.delete('/seed/barbers', (req, res) => {
  res.json({ message: 'Đã làm mới dữ liệu thợ cắt tóc.' });
});

router.post('/seed/appointments', (req, res) => {
  res.json({ message: 'Đã nạp lịch hẹn mẫu hôm nay.' });
});

router.delete('/seed/appointments', (req, res) => {
  appointmentsData = [];
  bookedSlotsData = [];
  res.json({ message: 'Đã xoá lịch hẹn mẫu thử nghiệm.' });
});

// ============================================================================
// 9. AI CONSULT & LEGACY BOOKING
// ============================================================================
router.post('/ai-consult', (req, res) => {
  const { faceShape } = req.body;
  if (!faceShape) {
    return res.status(400).json({ status: 'error', message: 'Thiếu tham số faceShape' });
  }

  const cleanShape = faceShape.toLowerCase().trim();
  const matching = hairstylesData.filter(h => h.faceShapes && h.faceShapes.includes(cleanShape));

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
// CreBy: MenBoyBMN
