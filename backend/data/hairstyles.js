// ============================================================================
// File: backend/data/hairstyles.js
// Description: Danh mục 50 kiểu tóc chuẩn AI cho Web API Backend
// ============================================================================

const hairstyles = [
  {
    id: 'undercut',
    name: 'Undercut Cổ Điển',
    description: 'Cắt ngắn gọn gàng hai bên và sau gáy, phần mái để dài vuốt ngược, giúp khuôn mặt trông thon gọn và góc cạnh hơn.',
    imageUrl: 'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=500&auto=format&fit=crop',
    faceShapes: ['round', 'square', 'oval'],
    tags: ['nam', 'gọn gàng', 'hiện đại', 'công sở'],
    active: true
  },
  {
    id: 'side_part',
    name: 'Side Part 7/3 Lịch Lãm',
    description: 'Kiểu tóc rẽ ngôi 7/3 hoặc 8/2 kinh điển, tôn lên đường nét tri thức, hài hoà cho người mặt dài hoặc trái xoan.',
    imageUrl: 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=500&auto=format&fit=crop',
    faceShapes: ['oval', 'oblong', 'heart'],
    tags: ['nam', 'lịch lãm', 'cổ điển', 'công sở'],
    active: true
  },
  {
    id: 'pompadour',
    name: 'Pompadour Phồng',
    description: 'Phần tóc mái được sấy phồng và vuốt ngược ra sau tạo độ bồng bềnh, tăng thêm chiều cao biểu kiến cho người mặt tròn.',
    imageUrl: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=500&auto=format&fit=crop',
    faceShapes: ['round', 'oval', 'square'],
    tags: ['nam', 'quý ông', 'bồng bềnh', 'tiệc'],
    active: true
  },
  {
    id: 'layer_male',
    name: 'Tóc Layer Nam Hàn Quốc',
    description: 'Các lọn tóc được cắt tỉa so le tạo tầng lớp tự nhiên, che khuyết điểm trán cao và làm mềm các góc cạnh khuôn mặt.',
    imageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500&auto=format&fit=crop',
    faceShapes: ['oval', 'oblong', 'heart'],
    tags: ['nam', 'trẻ trung', 'hàn quốc', 'tự nhiên'],
    active: true
  },
  {
    id: 'two_block',
    name: 'Two Block Học Đường',
    description: 'Đặc trưng với 2 khối rõ rệt: phần dưới cắt sát, phần trên để layer tự nhiên, phù hợp mọi độ tuổi học sinh và sinh viên.',
    imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500&auto=format&fit=crop',
    faceShapes: ['oval', 'heart', 'round'],
    tags: ['nam', 'học sinh', 'sinh viên', 'dễ chăm'],
    active: true
  },
  {
    id: 'french_crop',
    name: 'French Crop Cá Tính',
    description: 'Mái bằng ngắn ngang trán kết hợp fade sát hai bên, cực kỳ thoáng mát và tôn lên xương hàm góc cạnh.',
    imageUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=500&auto=format&fit=crop',
    faceShapes: ['square', 'oval', 'oblong'],
    tags: ['nam', 'cá tính', 'ngắn', 'mát mẻ'],
    active: true
  },
  {
    id: 'buzz_cut',
    name: 'Buzz Cut Nam Tính',
    description: 'Húi cua quân đội siêu ngắn, làm nổi bật đường nét nam tính, không tốn công tạo kiểu hay sấy tóc mỗi ngày.',
    imageUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=500&auto=format&fit=crop',
    faceShapes: ['oval', 'square'],
    tags: ['nam', 'thể thao', 'quân đội', 'siêu ngắn'],
    active: true
  },
  {
    id: 'mullet_modern',
    name: 'Mullet Hiện Đại',
    description: 'Ngắn phía trước và hai bên, dài dần về phía gáy, mang phong cách đường phố phá cách và phóng khoáng.',
    imageUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=500&auto=format&fit=crop',
    faceShapes: ['oval', 'heart', 'oblong'],
    tags: ['nam', 'phá cách', 'streetwear', 'nghệ thuật'],
    active: true
  },
  {
    id: 'quiff',
    name: 'Textured Quiff',
    description: 'Tóc mái vuốt chếch lên trên với các thớ tóc lọn rõ ràng, tạo cảm giác năng động và cực kỳ thu hút.',
    imageUrl: 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=500&auto=format&fit=crop',
    faceShapes: ['round', 'square', 'oval'],
    tags: ['nam', 'năng động', 'hiện đại', 'hẹn hò'],
    active: true
  },
  {
    id: 'slicked_back',
    name: 'Slicked Back Vuốt Ngược',
    description: 'Toàn bộ tóc vuốt ngược bóng bẩy về sau, tạo thần thái quyền lực và sang trọng của quý ông.',
    imageUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=500&auto=format&fit=crop',
    faceShapes: ['oval', 'square', 'oblong'],
    tags: ['nam', 'sang trọng', 'quý ông', 'sự kiện'],
    active: true
  },
  {
    id: 'comma_hair',
    name: 'Tóc Dấu Phẩy (Comma Hair)',
    description: 'Phong cách mái xoắn cong hình dấu phẩy cá tính K-Pop, tạo điểm nhấn thu hút cho vùng trán và mắt.',
    imageUrl: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=500&auto=format&fit=crop',
    faceShapes: ['oval', 'heart', 'round'],
    tags: ['nam', 'k-pop', 'hàn quốc', 'sành điệu'],
    active: true
  },
  {
    id: 'ivy_league',
    name: 'Ivy League Tri Thức',
    description: 'Kiểu tóc nam cổ điển xuất phát từ sinh viên các trường đại học Mỹ, cực kỳ gọn gàng và trí thức.',
    imageUrl: 'https://images.unsplash.com/photo-1513956589380-bad6acb9b9d4?w=500&auto=format&fit=crop',
    faceShapes: ['oval', 'square', 'oblong'],
    tags: ['nam', 'tri thức', 'gọn gàng', 'công sở'],
    active: true
  },
  {
    id: 'crew_cut',
    name: 'Crew Cut Thanh Lịch',
    description: 'Tóc cắt ngắn đều hai bên và đỉnh đầu dài hơn một chút, dễ chăm sóc và vô cùng nam tính.',
    imageUrl: 'https://images.unsplash.com/photo-1501196354995-cbb51c65aaea?w=500&auto=format&fit=crop',
    faceShapes: ['oval', 'square', 'round'],
    tags: ['nam', 'thể thao', 'đơn giản', 'mát mẻ'],
    active: true
  },
  {
    id: 'drop_fade',
    name: 'Drop Fade Hiện Đại',
    description: 'Đường hiệu ứng mờ dần (fade) ôm sát độ cong tai và gáy, tạo phom tóc sắc nét sắc sảo.',
    imageUrl: 'https://images.unsplash.com/photo-1480429370139-e0132c086e2a?w=500&auto=format&fit=crop',
    faceShapes: ['round', 'square', 'oval'],
    tags: ['nam', 'barber', 'sắc nét', 'hiện đại'],
    active: true
  },
  {
    id: 'taper_fade',
    name: 'Taper Fade Nhẹ Nhàng',
    description: 'Chỉ hiệu ứng mờ nhẹ ở phần mai và gáy, giữ trọn độ dày tóc hai bên, phù hợp môi trường học đường.',
    imageUrl: 'https://images.unsplash.com/photo-1519345182560-3f2917c472ef?w=500&auto=format&fit=crop',
    faceShapes: ['oval', 'heart', 'oblong'],
    tags: ['nam', 'nhẹ nhàng', 'học sinh', 'tự nhiên'],
    active: true
  }
];

module.exports = hairstyles;
