// ============================================================================
// File: backend/data/users.js
// Description: Danh sách 50 Khách hàng cho Web API Backend
// ============================================================================

const users = [];
const names = ['Nguyễn Văn An', 'Trần Hoàng Nam', 'Lê Quốc Bảo', 'Phạm Đức Anh', 'Vũ Tấn Tài', 'Bùi Tuấn Khoa'];

for (let i = 1; i <= 50; i++) {
  const name = `${names[(i - 1) % names.length]} #${i}`;
  users.push({
    uid: `customer_seed_${String(i).padStart(3, '0')}`,
    email: `khachhang${String(i).padStart(2, '0')}@hairfit.ai`,
    displayName: name,
    role: 'customer',
    phone: `0905${(100000 + i * 1234) % 900000}`,
    savedFaceShape: ['oval', 'round', 'square', 'heart', 'oblong'][i % 5]
  });
}

module.exports = users;
