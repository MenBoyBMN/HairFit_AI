// ============================================================================
// File: backend/data/barbers.js
// Description: Danh sách 150 Thợ cắt tóc toàn quốc cho Web API Backend
// ============================================================================

const cityConfigs = [
  { city: 'Đà Nẵng', lat: 16.0544, lng: 108.2022, districts: ['Hải Châu', 'Sơn Trà', 'Thanh Khê', 'Ngũ Hành Sơn', 'Cẩm Lệ'] },
  { city: 'Hà Nội', lat: 21.0285, lng: 105.8542, districts: ['Hoàn Kiếm', 'Cầu Giấy', 'Ba Đình', 'Đống Đa', 'Hai Bà Trưng', 'Thanh Xuân', 'Hà Đông'] },
  { city: 'TP. Hồ Chí Minh', lat: 10.7769, lng: 106.7009, districts: ['Quận 1', 'Quận 3', 'Quận 7', 'Tân Bình', 'Phú Nhuận', 'Bình Thạnh', 'Thủ Đức'] },
  { city: 'Cần Thơ', lat: 10.0452, lng: 105.7469, districts: ['Ninh Kiều', 'Bình Thủy', 'Cái Răng'] },
  { city: 'Hải Phòng', lat: 20.8449, lng: 106.6881, districts: ['Hồng Bàng', 'Ngô Quyền', 'Lê Chân'] }
];

const shopPrefixes = [
  'HairFit Studio', '30Shine', 'Gentleman Barber Shop', 'Phong Bụi Barber',
  'Liêm Barber Shop', '1990 Barber Club', 'Sài Gòn Vintage Barber',
  'Barber House', 'The Brother Barber', 'K-Style Hair Studio'
];

const barbers = [];

for (let i = 1; i <= 150; i++) {
  const cityConfig = cityConfigs[(i - 1) % cityConfigs.length];
  const district = cityConfig.districts[(i * 3) % cityConfig.districts.length];
  const namePrefix = shopPrefixes[(i - 1) % shopPrefixes.length];

  barbers.push({
    uid: `barber_seed_${String(i).padStart(3, '0')}`,
    displayName: `${namePrefix} ${district}`,
    avatarUrl: 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=500&auto=format&fit=crop',
    address: `${10 + (i * 12) % 350} đường Nguyễn Văn Linh, ${district}, ${cityConfig.city}`,
    location: {
      latitude: cityConfig.lat + ((i * 13) % 40 - 20) * 0.0012,
      longitude: cityConfig.lng + ((i * 17) % 40 - 20) * 0.0012
    },
    priceMin: 70000 + (i % 4) * 10000,
    priceMax: 140000 + (i % 5) * 20000,
    ratingAvg: Number((4.2 + (i % 8) * 0.1).toFixed(2)),
    ratingCount: 35 + (i * 11) % 180,
    approvalStatus: 'approved',
    isAcceptingBookingsToday: true,
    services: [
      { id: 'svc_standard', name: 'Cắt tạo kiểu tiêu chuẩn', price: 80000, durationMinutes: 30 },
      { id: 'svc_combo', name: 'Combo Cắt + Gội massage + Sấy vuốt', price: 120000, durationMinutes: 60 }
    ]
  });
}

module.exports = barbers;
