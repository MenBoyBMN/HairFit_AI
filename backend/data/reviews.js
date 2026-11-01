// ============================================================================
// File: backend/data/reviews.js
// Description: Danh sách 100 Đánh giá cho Web API Backend
// ============================================================================

const reviews = [];
const comments = [
  'Cắt rất ưng ý, anh thợ cắt kĩ và tư vấn dáng mặt nhiệt tình!',
  'Combo gội massage cực thoải mái, vuốt sáp tạo phom chuẩn salon.',
  'Cắt đúng phom Layer Hàn Quốc mình chọn trên app HairFit AI, rất hợp mặt!',
  'Thợ nhiệt tình, tiệm sạch sẽ, không gian phong cách Barber Châu Âu ấn tượng.',
  'Đặt lịch trước trên app không phải chờ đợi chút nào, vô cùng hài lòng.'
];

for (let i = 1; i <= 100; i++) {
  reviews.push({
    id: `review_seed_${String(i).padStart(3, '0')}`,
    barberId: `barber_seed_${String((i * 3) % 150 + 1).padStart(3, '0')}`,
    customerId: `customer_seed_${String((i * 5) % 50 + 1).padStart(3, '0')}`,
    customerName: `Khách Hàng #${i}`,
    rating: (i % 8 === 0) ? 4 : 5,
    reviewComment: comments[(i - 1) % comments.length],
    createdAt: new Date().toISOString()
  });
}

module.exports = reviews;
