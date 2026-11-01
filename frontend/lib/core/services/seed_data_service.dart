// ============================================================================
// File: lib/core/services/seed_data_service.dart
// Mục đích: Cung cấp dịch vụ hạ tầng (seed_data).
// Kết cấu:
//  - Lớp Service xử lý giao tiếp với các hệ thống bên ngoài hoặc phần cứng (Firebase, Location, API).
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../../models/appointment_model.dart';
import '../../models/barber_profile_model.dart';
import '../../models/hairstyle_model.dart';
import '../../models/promotion_model.dart';
import '../../models/service_model.dart';
import '../../models/user_model.dart';

/// Dịch vụ khởi tạo dữ liệu mẫu (Seed Data) cho 10 kiểu tóc và 5 thợ cắt tóc
class SeedDataService {
  final FirebaseFirestore _firestore;

  SeedDataService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// 50 kiểu tóc chuẩn trong catalog của hệ thống
  static final List<HairstyleModel> sampleHairstyles = [
    const HairstyleModel(
      id: 'undercut',
      name: 'Undercut Cổ Điển',
      description: 'Cắt ngắn gọn gàng hai bên và sau gáy, phần mái để dài vuốt ngược, giúp khuôn mặt trông thon gọn và góc cạnh hơn.',
      imageUrl: 'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=500&auto=format&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=500&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=500&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=500&auto=format&fit=crop',
      ],
      faceShapes: ['round', 'square', 'oval'],
      tags: ['nam', 'gọn gàng', 'hiện đại', 'công sở'],
      active: true,
    ),
    const HairstyleModel(
      id: 'side_part',
      name: 'Side Part 7/3 Lịch Lãm',
      description: 'Kiểu tóc rẽ ngôi 7/3 hoặc 8/2 kinh điển, tôn lên đường nét tri thức, hài hoà cho người mặt dài hoặc trái xoan.',
      imageUrl: 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=500&auto=format&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=500&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=500&auto=format&fit=crop',
      ],
      faceShapes: ['oval', 'oblong', 'heart'],
      tags: ['nam', 'lịch lãm', 'cổ điển', 'công sở'],
      active: true,
    ),
    const HairstyleModel(
      id: 'pompadour',
      name: 'Pompadour Phồng',
      description: 'Phần tóc mái được sấy phồng và vuốt ngược ra sau tạo độ bồng bềnh, tăng thêm chiều cao biểu kiến cho người mặt tròn.',
      imageUrl: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=500&auto=format&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=500&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=500&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=500&auto=format&fit=crop',
      ],
      faceShapes: ['round', 'oval', 'square'],
      tags: ['nam', 'quý ông', 'bồng bềnh', 'tiệc'],
      active: true,
    ),
    const HairstyleModel(
      id: 'layer_male',
      name: 'Tóc Layer Nam Hàn Quốc',
      description: 'Các lọn tóc được cắt tỉa so le tạo tầng lớp tự nhiên, che khuyết điểm trán cao và làm mềm các góc cạnh khuôn mặt.',
      imageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500&auto=format&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=500&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=500&auto=format&fit=crop',
      ],
      faceShapes: ['oval', 'oblong', 'heart'],
      tags: ['nam', 'trẻ trung', 'hàn quốc', 'tự nhiên'],
      active: true,
    ),
    const HairstyleModel(
      id: 'two_block',
      name: 'Two Block Học Đường',
      description: 'Đặc trưng với 2 khối rõ rệt: phần dưới cắt sát, phần trên để layer tự nhiên, phù hợp mọi độ tuổi học sinh và sinh viên.',
      imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500&auto=format&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500&auto=format&fit=crop',
      ],
      faceShapes: ['oval', 'heart', 'round'],
      tags: ['nam', 'học sinh', 'sinh viên', 'dễ chăm'],
      active: true,
    ),
    const HairstyleModel(
      id: 'french_crop',
      name: 'French Crop Cá Tính',
      description: 'Mái bằng ngắn ngang trán kết hợp fade sát hai bên, cực kỳ thoáng mát và tôn lên xương hàm góc cạnh.',
      imageUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=500&auto=format&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=500&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=500&auto=format&fit=crop',
      ],
      faceShapes: ['square', 'oval', 'oblong'],
      tags: ['nam', 'cá tính', 'ngắn', 'mát mẻ'],
      active: true,
    ),
    const HairstyleModel(
      id: 'buzz_cut',
      name: 'Buzz Cut Nam Tính',
      description: 'Húi cua quân đội siêu ngắn, làm nổi bật đường nét nam tính, không tốn công tạo kiểu hay sấy tóc mỗi ngày.',
      imageUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=500&auto=format&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=500&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=500&auto=format&fit=crop',
      ],
      faceShapes: ['oval', 'square'],
      tags: ['nam', 'thể thao', 'quân đội', 'siêu ngắn'],
      active: true,
    ),
    const HairstyleModel(
      id: 'mullet_modern',
      name: 'Mullet Hiện Đại',
      description: 'Ngắn phía trước và hai bên, dài dần về phía gáy, mang phong cách đường phố phá cách và phóng khoáng.',
      imageUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=500&auto=format&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=500&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=500&auto=format&fit=crop',
      ],
      faceShapes: ['oval', 'heart', 'oblong'],
      tags: ['nam', 'phá cách', 'streetwear', 'nghệ thuật'],
      active: true,
    ),
    const HairstyleModel(
      id: 'quiff',
      name: 'Textured Quiff',
      description: 'Tóc mái vuốt chếch lên trên với các thớ tóc lọn rõ ràng, tạo cảm giác năng động và cực kỳ thu hút.',
      imageUrl: 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=500&auto=format&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=500&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=500&auto=format&fit=crop',
      ],
      faceShapes: ['round', 'square', 'oval'],
      tags: ['nam', 'năng động', 'hiện đại', 'hẹn hò'],
      active: true,
    ),
    const HairstyleModel(
      id: 'slicked_back',
      name: 'Slicked Back Vuốt Ngược',
      description: 'Toàn bộ tóc vuốt ngược bóng bẩy về sau, tạo thần thái quyền lực và sang trọng của quý ông.',
      imageUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=500&auto=format&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=500&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=500&auto=format&fit=crop',
      ],
      faceShapes: ['oval', 'square', 'oblong'],
      tags: ['nam', 'sang trọng', 'quý ông', 'sự kiện'],
      active: true,
    ),
    const HairstyleModel(
      id: 'comma_hair',
      name: 'Tóc Dấu Phẩy (Comma Hair)',
      description: 'Phong cách mái xoắn cong hình dấu phẩy cá tính K-Pop, tạo điểm nhấn thu hút cho vùng trán và mắt.',
      imageUrl: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=500&auto=format&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=500&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500&auto=format&fit=crop',
      ],
      faceShapes: ['oval', 'heart', 'round'],
      tags: ['nam', 'k-pop', 'hàn quốc', 'sành điệu'],
      active: true,
    ),
    const HairstyleModel(
      id: 'ivy_league',
      name: 'Ivy League Tri Thức',
      description: 'Kiểu tóc nam cổ điển xuất phát từ sinh viên các trường đại học Mỹ, cực kỳ gọn gàng và trí thức.',
      imageUrl: 'https://images.unsplash.com/photo-1513956589380-bad6acb9b9d4?w=500&auto=format&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1513956589380-bad6acb9b9d4?w=500&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500&auto=format&fit=crop',
      ],
      faceShapes: ['oval', 'square', 'oblong'],
      tags: ['nam', 'tri thức', 'gọn gàng', 'công sở'],
      active: true,
    ),
    const HairstyleModel(
      id: 'crew_cut',
      name: 'Crew Cut Thanh Lịch',
      description: 'Tóc cắt ngắn đều hai bên và đỉnh đầu dài hơn một chút, dễ chăm sóc và vô cùng nam tính.',
      imageUrl: 'https://images.unsplash.com/photo-1501196354995-cbb51c65aaea?w=500&auto=format&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1501196354995-cbb51c65aaea?w=500&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=500&auto=format&fit=crop',
      ],
      faceShapes: ['oval', 'square', 'round'],
      tags: ['nam', 'thể thao', 'đơn giản', 'mát mẻ'],
      active: true,
    ),
    const HairstyleModel(
      id: 'drop_fade',
      name: 'Drop Fade Hiện Đại',
      description: 'Đường hiệu ứng mờ dần (fade) ôm sát độ cong tai và gáy, tạo phom tóc sắc nét sắc sảo.',
      imageUrl: 'https://images.unsplash.com/photo-1480429370139-e0132c086e2a?w=500&auto=format&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1480429370139-e0132c086e2a?w=500&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=500&auto=format&fit=crop',
      ],
      faceShapes: ['round', 'square', 'oval'],
      tags: ['nam', 'barber', 'sắc nét', 'hiện đại'],
      active: true,
    ),
    const HairstyleModel(
      id: 'taper_fade',
      name: 'Taper Fade Nhẹ Nhàng',
      description: 'Chỉ hiệu ứng mờ nhẹ ở phần mai và gáy, giữ trọn độ dày tóc hai bên, phù hợp môi trường học đường.',
      imageUrl: 'https://images.unsplash.com/photo-1519345182560-3f2917c472ef?w=500&auto=format&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1519345182560-3f2917c472ef?w=500&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=500&auto=format&fit=crop',
      ],
      faceShapes: ['oval', 'heart', 'oblong'],
      tags: ['nam', 'nhẹ nhàng', 'học sinh', 'tự nhiên'],
      active: true,
    ),
    const HairstyleModel(
      id: 'mohawk_modern',
      name: 'Modern Mohawk Phá Cách',
      description: 'Bản phối lại kiểu Mohawk với hai bên undercut nhẹ nhàng và đỉnh đầu vuốt dính cá tính.',
      imageUrl: 'https://images.unsplash.com/photo-1504257432389-52343af06ae3?w=500&auto=format&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1504257432389-52343af06ae3?w=500&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=500&auto=format&fit=crop',
      ],
      faceShapes: ['round', 'oval', 'square'],
      tags: ['nam', 'phá cách', 'nghệ sĩ', 'nổi bật'],
      active: true,
    ),
    const HairstyleModel(
      id: 'faux_hawk',
      name: 'Faux Hawk Năng Động',
      description: 'Giống Mohawk nhưng dốc nhẹ nhàng từ hai bên vào trung tâm, vừa trẻ trung vừa dễ chấp nhận.',
      imageUrl: 'https://images.unsplash.com/photo-1520341280432-4749d4d7bcf9?w=500&auto=format&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1520341280432-4749d4d7bcf9?w=500&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=500&auto=format&fit=crop',
      ],
      faceShapes: ['round', 'square', 'oval'],
      tags: ['nam', 'năng động', 'thể thao', 'trẻ trung'],
      active: true,
    ),
    const HairstyleModel(
      id: 'side_part_short',
      name: 'Short Side Part Tối Giản',
      description: 'Phiên bản Side Part ngắn gọn gàng không tốn sấy tạo kiểu, dành cho nam giới bận rộn.',
      imageUrl: 'https://images.unsplash.com/photo-1530268729831-4b0b9e170218?w=500&auto=format&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1530268729831-4b0b9e170218?w=500&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500&auto=format&fit=crop',
      ],
      faceShapes: ['oval', 'oblong', 'square'],
      tags: ['nam', 'tối giản', 'gọn gàng', 'công sở'],
      active: true,
    ),
    const HairstyleModel(
      id: 'textured_crop',
      name: 'Textured Crop Hiện Đại',
      description: 'Lớp tỉa tót lọn textured ở phần đỉnh đầu kết hợp sát hai bên, mang khí chất đường phố Châu Âu.',
      imageUrl: 'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=500&auto=format&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=500&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=500&auto=format&fit=crop',
      ],
      faceShapes: ['square', 'oval', 'oblong'],
      tags: ['nam', 'châu âu', 'textured', 'trẻ trung'],
      active: true,
    ),
    const HairstyleModel(
      id: 'curly_top_fade',
      name: 'Curly Top Fade Lọn Xoăn',
      description: 'Tóc xoăn bồng bềnh ở phần mái kết hợp fade sắc nét xung quanh, tạo độ tương phản cực kỳ cuốn hút.',
      imageUrl: 'https://images.unsplash.com/photo-1522529599102-193c0d76b5b6?w=500&auto=format&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1522529599102-193c0d76b5b6?w=500&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500&auto=format&fit=crop',
      ],
      faceShapes: ['oval', 'heart', 'oblong'],
      tags: ['nam', 'tóc xoăn', 'ấn tượng', 'phong cách'],
      active: true,
    ),
    const HairstyleModel(
      id: 'afro_fade',
      name: 'Afro Fade Cá Tính',
      description: 'Phần tóc xù bồng đặc trưng phối hợp dốc fade sát da đầu, biểu tượng thời trang Hip Hop.',
      imageUrl: 'https://images.unsplash.com/photo-1519764622345-23439dd774f7?w=500&auto=format&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1519764622345-23439dd774f7?w=500&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=500&auto=format&fit=crop',
      ],
      faceShapes: ['oval', 'square'],
      tags: ['nam', 'afro', 'hiphop', 'streetwear'],
      active: true,
    ),
    const HairstyleModel(
      id: 'burst_fade',
      name: 'Burst Fade Thể Thao',
      description: 'Mờ dạng hình ngôi sao tròn quanh vành tai, tạo điểm nhấn phá cách cho dân chơi thể thao.',
      imageUrl: 'https://images.unsplash.com/photo-1496345875659-11f7dd282d1d?w=500&auto=format&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1496345875659-11f7dd282d1d?w=500&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1480429370139-e0132c086e2a?w=500&auto=format&fit=crop',
      ],
      faceShapes: ['round', 'oval', 'square'],
      tags: ['nam', 'thể thao', 'độc đáo', 'barber'],
      active: true,
    ),
    const HairstyleModel(
      id: 'caesar_cut',
      name: 'Caesar Cut Hoàng Gia',
      description: 'Lấy cảm hứng từ hoàng đế La Mã với phần mái bằng siêu ngắn và các góc gọt phẳng phiu.',
      imageUrl: 'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?w=500&auto=format&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?w=500&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=500&auto=format&fit=crop',
      ],
      faceShapes: ['oval', 'square', 'oblong'],
      tags: ['nam', 'cổ điển', 'nam tính', 'ngắn'],
      active: true,
    ),
    const HairstyleModel(
      id: 'curtain_bangs',
      name: 'Curtain Bangs Mái Rủ 5/5',
      description: 'Mái rủ hai bên dạng rèm cửa mềm mại, che bớt gò má cao và tạo nét lãng tử chuẩn thần tượng.',
      imageUrl: 'https://images.unsplash.com/photo-1495366554757-a1373f94c8b8?w=500&auto=format&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1495366554757-a1373f94c8b8?w=500&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500&auto=format&fit=crop',
      ],
      faceShapes: ['oval', 'heart', 'oblong'],
      tags: ['nam', 'lãng tử', 'mái rủ', 'hàn quốc'],
      active: true,
    ),
    const HairstyleModel(
      id: 'wolf_cut_male',
      name: 'Wolf Cut Nam Lãng Tử',
      description: 'Sự kết hợp giữa Mullet và Shag layer tạo vẻ ngoài bụi bặm phong trần vô cùng nghệ sĩ.',
      imageUrl: 'https://images.unsplash.com/photo-1506277886164-e25aa3f4ef7f?w=500&auto=format&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1506277886164-e25aa3f4ef7f?w=500&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=500&auto=format&fit=crop',
      ],
      faceShapes: ['oval', 'heart', 'oblong'],
      tags: ['nam', 'wolfcut', 'bụi bặm', 'phong cách'],
      active: true,
    ),
    const HairstyleModel(
      id: 'comb_over',
      name: 'Comb Over Lịch Tự',
      description: 'Chải gạt toàn bộ tóc sang một bên gọn gàng, tăng cảm giác tin cậy và đĩnh đạc.',
      imageUrl: 'https://images.unsplash.com/photo-1513152697235-fe34c283646a?w=500&auto=format&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1513152697235-fe34c283646a?w=500&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=500&auto=format&fit=crop',
      ],
      faceShapes: ['oval', 'oblong', 'square'],
      tags: ['nam', 'lịch sự', 'doanh nhân', 'công sở'],
      active: true,
    ),
    const HairstyleModel(
      id: 'short_spiky',
      name: 'Short Spiky Vuốt Dựng',
      description: 'Các gai tóc ngắn được tạo kiểu vuốt nhọn hướng lên, tràn đầy sinh khí và năng lượng tuổi trẻ.',
      imageUrl: 'https://images.unsplash.com/photo-1501594907352-04cda38ebc29?w=500&auto=format&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1501594907352-04cda38ebc29?w=500&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=500&auto=format&fit=crop',
      ],
      faceShapes: ['round', 'square', 'oval'],
      tags: ['nam', 'vuốt dựng', 'năng động', 'học sinh'],
      active: true,
    ),
    const HairstyleModel(
      id: 'messy_fringe',
      name: 'Messy Fringe Tự Nhiên',
      description: 'Mái xù nhẹ đánh rối tự do không gò bó, mang đến vẻ đáng yêu và gần gũi.',
      imageUrl: 'https://images.unsplash.com/photo-1521119989659-a83eee488004?w=500&auto=format&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1521119989659-a83eee488004?w=500&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500&auto=format&fit=crop',
      ],
      faceShapes: ['oval', 'heart', 'round'],
      tags: ['nam', 'đánh rối', 'tự nhiên', 'trẻ trung'],
      active: true,
    ),
    const HairstyleModel(
      id: 'slicked_side_part',
      name: 'Slicked Side Part Quyến Rũ',
      description: 'Đường ngôi chia rõ ràng kết hợp xoa gel bóng bẩy, phong cách tiệc đêm sang trọng.',
      imageUrl: 'https://images.unsplash.com/photo-1492446845049-9c50cc313f00?w=500&auto=format&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1492446845049-9c50cc313f00?w=500&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=500&auto=format&fit=crop',
      ],
      faceShapes: ['oval', 'square', 'oblong'],
      tags: ['nam', 'quý ông', 'quyến rũ', 'tiệc đêm'],
      active: true,
    ),
    const HairstyleModel(
      id: 'low_fade_quiff',
      name: 'Low Fade Quiff Mềm Mại',
      description: 'Phần mai hạ thấp mờ nhẹ, đỉnh vuốt Quiff độ phồng tự nhiên không bị quá gắt.',
      imageUrl: 'https://images.unsplash.com/photo-1506634572416-48cdfe530110?w=500&auto=format&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1506634572416-48cdfe530110?w=500&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=500&auto=format&fit=crop',
      ],
      faceShapes: ['round', 'square', 'oval'],
      tags: ['nam', 'low fade', 'quiff', 'hàng ngày'],
      active: true,
    ),
    const HairstyleModel(
      id: 'mid_fade_crop',
      name: 'Mid Fade Crop Cân Bằng',
      description: 'Độ mờ bắt đầu từ khoảng giữa tai, kết hợp mái ngang ngắn cực kỳ cân đối.',
      imageUrl: 'https://images.unsplash.com/photo-1485217988980-11786ced9454?w=500&auto=format&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1485217988980-11786ced9454?w=500&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=500&auto=format&fit=crop',
      ],
      faceShapes: ['square', 'oval', 'oblong'],
      tags: ['nam', 'mid fade', 'gọn gàng', 'cá tính'],
      active: true,
    ),
    const HairstyleModel(
      id: 'high_top_fade',
      name: 'High Top Fade Cao Rút',
      description: 'Phần khối tóc đỉnh cao kết hợp hiệu ứng high fade nâng tầm chiều cao khuôn mặt.',
      imageUrl: 'https://images.unsplash.com/photo-1484515991647-c5760fcecfc7?w=500&auto=format&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1484515991647-c5760fcecfc7?w=500&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1519764622345-23439dd774f7?w=500&auto=format&fit=crop',
      ],
      faceShapes: ['round', 'oval'],
      tags: ['nam', 'high top', 'nổi bật', 'phong cách'],
      active: true,
    ),
    const HairstyleModel(
      id: 'bro_flow',
      name: 'Bro Flow Phong Trần',
      description: 'Tóc độ dài trung bình vuốt nhẹ ra sau ôm lấy gáy, mang phong cách nghệ sĩ tự do.',
      imageUrl: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=500&auto=format&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=500&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1506277886164-e25aa3f4ef7f?w=500&auto=format&fit=crop',
      ],
      faceShapes: ['oval', 'heart', 'oblong'],
      tags: ['nam', 'phong trần', 'tóc trung bình', 'lãng tử'],
      active: true,
    ),
    const HairstyleModel(
      id: 'shaggy_hair',
      name: 'Shaggy Hair Ngẫu Hứng',
      description: 'Tỉa tầng lớp dày mỏng sole ngẫu hứng, gợi nhớ thập niên 70 đầy cảm hứng rock.',
      imageUrl: 'https://images.unsplash.com/photo-1503443207922-dff7d543fd0e?w=500&auto=format&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1503443207922-dff7d543fd0e?w=500&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=500&auto=format&fit=crop',
      ],
      faceShapes: ['oval', 'heart', 'oblong'],
      tags: ['nam', 'shaggy', 'retro', 'nghệ thuật'],
      active: true,
    ),
    const HairstyleModel(
      id: 'bowl_cut_modern',
      name: 'Modern Bowl Cut Trẻ Trung',
      description: 'Đầu nấm cách tân tỉa texture mỏng nhẹ bớt cảm giác nặng nề, cực kỳ thịnh hành ở Châu Á.',
      imageUrl: 'https://images.unsplash.com/photo-1514543250559-83867827ecce?w=500&auto=format&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1514543250559-83867827ecce?w=500&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500&auto=format&fit=crop',
      ],
      faceShapes: ['oval', 'heart', 'round'],
      tags: ['nam', 'đầu nấm', 'châu á', 'dễ thương'],
      active: true,
    ),
    const HairstyleModel(
      id: 'waves_360',
      name: '360 Waves Độc Đáo',
      description: 'Các sóng tóc xoáy tròn 360 độ quanh đầu độc đáo đòi hỏi kỹ thuật chải chăm sóc đặc biệt.',
      imageUrl: 'https://images.unsplash.com/photo-1534030347209-467a5b0ad3e6?w=500&auto=format&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1534030347209-467a5b0ad3e6?w=500&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=500&auto=format&fit=crop',
      ],
      faceShapes: ['oval', 'square'],
      tags: ['nam', 'waves', 'độc đáo', 'barber'],
      active: true,
    ),
    const HairstyleModel(
      id: 'flat_top',
      name: 'Flat Top Góc Cạnh',
      description: 'Đỉnh đầu được gọt phẳng nằm ngang góc cạnh chuẩn cổ điển thập niên 90.',
      imageUrl: 'https://images.unsplash.com/photo-1501196354995-cbb51c65aaea?w=500&auto=format&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1501196354995-cbb51c65aaea?w=500&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=500&auto=format&fit=crop',
      ],
      faceShapes: ['oval', 'round'],
      tags: ['nam', 'flat top', 'góc cạnh', 'retro'],
      active: true,
    ),
    const HairstyleModel(
      id: 'hard_part_undercut',
      name: 'Hard Part Undercut Đường Kẻ',
      description: 'Bổ sung đường vạch cạo (line) sắc lẹm tạo điểm phân ranh cá tính cho Undercut.',
      imageUrl: 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=500&auto=format&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=500&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=500&auto=format&fit=crop',
      ],
      faceShapes: ['round', 'square', 'oval'],
      tags: ['nam', 'hard part', 'vạch kẻ', 'barber'],
      active: true,
    ),
    const HairstyleModel(
      id: 'military_cut',
      name: 'Military Cut Nghiêm Túc',
      description: 'Tóc ba phân cắt sát nghiêm túc chuẩn lực lượng vũ trang, mang tinh thần kỷ luật cao.',
      imageUrl: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=500&auto=format&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=500&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=500&auto=format&fit=crop',
      ],
      faceShapes: ['oval', 'square'],
      tags: ['nam', 'quân đội', 'nghiêm túc', 'siêu gọn'],
      active: true,
    ),
    const HairstyleModel(
      id: 'shoulder_length_wavy',
      name: 'Tóc Dài Sóng Ngang Vai',
      description:
          'Tóc nuôi dài đến vai uốn sóng bồng bềnh, chất nghệ sĩ phóng khoáng.',
      imageUrl: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=500&auto=format&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=500&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=500&auto=format&fit=crop',
      ],
      faceShapes: ['oval', 'heart', 'oblong'],
      tags: ['nam', 'tóc dài', 'uốn sóng', 'nghệ sĩ'],
      active: true,
    ),
    const HairstyleModel(
      id: 'disconnected_undercut',
      name: 'Disconnected Undercut',
      description: 'Đỉnh tóc và hai bên cắt cạo tách biệt hoàn toàn không hiệu ứng chuyển tiếp, sắc gọt cá tính.',
      imageUrl: 'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=500&auto=format&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=500&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=500&auto=format&fit=crop',
      ],
      faceShapes: ['round', 'square', 'oval'],
      tags: ['nam', 'disconnected', 'phá cách', 'nổi bật'],
      active: true,
    ),
    const HairstyleModel(
      id: 'skin_fade_pompadour',
      name: 'Skin Fade Pompadour',
      description: 'Hai bên cạo sát tới da đầu (skin fade) làm bệ đỡ nâng phần mái Pompadour phồng uy nghi.',
      imageUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=500&auto=format&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=500&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=500&auto=format&fit=crop',
      ],
      faceShapes: ['round', 'oval', 'square'],
      tags: ['nam', 'skin fade', 'pompadour', 'quý ông'],
      active: true,
    ),
    const HairstyleModel(
      id: 'textured_fringe',
      name: 'Textured Fringe Trẻ Trung',
      description: 'Phần mái phủ trán được tỉa răng cưa nhấp nhô sống động, tạo cảm giác thân thiện.',
      imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500&auto=format&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500&auto=format&fit=crop',
      ],
      faceShapes: ['oval', 'heart', 'oblong'],
      tags: ['nam', 'textured', 'mái phủ', 'trẻ trung'],
      active: true,
    ),
    const HairstyleModel(
      id: 'side_swept_undercut',
      name: 'Side Swept Undercut',
      description: 'Mái dài vuốt chéo sang một bên đầy lãng mạn kết hợp hai bên cắt sát sành điệu.',
      imageUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=500&auto=format&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=500&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=500&auto=format&fit=crop',
      ],
      faceShapes: ['oval', 'square', 'heart'],
      tags: ['nam', 'vuốt chéo', 'lãng mạn', 'thời trang'],
      active: true,
    ),
    const HairstyleModel(
      id: 'curly_fringe',
      name: 'Curly Fringe Xoăn Tròn',
      description: 'Mái xoăn tròn thả tự nhiên trước trán kết hợp fade sát mang lại nét tươi tắn trẻ trung.',
      imageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500&auto=format&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1522529599102-193c0d76b5b6?w=500&auto=format&fit=crop',
      ],
      faceShapes: ['oval', 'heart', 'oblong'],
      tags: ['nam', 'xoăn tròn', 'tươi tắn', 'hàn quốc'],
      active: true,
    ),
    const HairstyleModel(
      id: 'burst_fade_mullet',
      name: 'Burst Fade Mullet Đỉnh Cao',
      description: 'Sự pha trộn bùng nổ giữa vết mờ Burst Fade hai bên và đuôi tóc Mullet dài quyến rũ.',
      imageUrl: 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=500&auto=format&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=500&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=500&auto=format&fit=crop',
      ],
      faceShapes: ['oval', 'heart', 'oblong'],
      tags: ['nam', 'burst fade', 'mullet', 'cực ngầu'],
      active: true,
    ),
    const HairstyleModel(
      id: 'shadow_mullet',
      name: 'Shadow Mullet Nhẹ Nhàng',
      description: 'Mullet bóng mờ nhẹ nhàng dịu mắt hơn, thích hợp cho học sinh muốn thử phong cách mới.',
      imageUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=500&auto=format&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=500&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500&auto=format&fit=crop',
      ],
      faceShapes: ['oval', 'heart', 'round'],
      tags: ['nam', 'shadow mullet', 'nhẹ nhàng', 'học sinh'],
      active: true,
    ),
    const HairstyleModel(
      id: 'leaf_cut',
      name: 'Leaf Cut (Mái Lá) Hàn Quốc',
      description: 'Mái tỉa nhọn ôm hai bên gò má như chiếc lá, tạo góc nghiêng quyến rũ thần thánh.',
      imageUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=500&auto=format&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=500&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=500&auto=format&fit=crop',
      ],
      faceShapes: ['oval', 'heart', 'oblong'],
      tags: ['nam', 'mái lá', 'hàn quốc', 'góc nghiêng'],
      active: true,
    ),
    const HairstyleModel(
      id: 'dreadlocks_short',
      name: 'Short Dreadlocks Phá Cách',
      description: 'Các lọn tóc tết xù ngắn tự do rèn luyện tính kiên nhẫn, mang tinh thần Reggae.',
      imageUrl: 'https://images.unsplash.com/photo-1519345182560-3f2917c472ef?w=500&auto=format&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1519345182560-3f2917c472ef?w=500&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1519764622345-23439dd774f7?w=500&auto=format&fit=crop',
      ],
      faceShapes: ['oval', 'square'],
      tags: ['nam', 'dreadlocks', 'reggae', 'đường phố'],
      active: true,
    ),
    const HairstyleModel(
      id: 'man_bun',
      name: 'Man Bun Lãng Tử',
      description: 'Tóc dài búi cao gọn gàng đỉnh đầu, lộ rõ toàn bộ khuôn mặt góc cạnh nam tính.',
      imageUrl: 'https://images.unsplash.com/photo-1504257432389-52343af06ae3?w=500&auto=format&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1504257432389-52343af06ae3?w=500&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=500&auto=format&fit=crop',
      ],
      faceShapes: ['oval', 'square', 'heart'],
      tags: ['nam', 'man bun', 'búi tóc', 'lãng tử'],
      active: true,
    ),
  ];

  /// Mã giảm giá & Giờ vàng Happy Hour mẫu
  static final List<PromotionModel> samplePromotions = [
    const PromotionModel(
      id: 'promo_happyhour20',
      code: 'HAPPYHOUR20',
      title: 'Giờ Vàng Giảm 20%',
      description:
          'Áp dụng đặt lịch khung sáng 08:30 - 11:30 các ngày Thứ 2 đến Thứ 5.',
      type: PromotionType.percentage,
      discountValue: 20,
      minOrderPrice: 80000,
      maxDiscountAmount: 30000,
      applicableHoursStart: '08:30',
      applicableHoursEnd: '11:30',
      applicableDays: ['mon', 'tue', 'wed', 'thu'],
    ),
    const PromotionModel(
      id: 'promo_hairfit30',
      code: 'HAIRFIT30',
      title: 'Chào Bạn Mới Giảm 30K',
      description:
          'Giảm 30.000đ cho đơn đặt dịch vụ cắt tóc bất kỳ từ 100.000đ.',
      type: PromotionType.fixedAmount,
      discountValue: 30000,
      minOrderPrice: 100000,
      maxDiscountAmount: 30000,
    ),
    const PromotionModel(
      id: 'promo_weekend10',
      code: 'WEEKEND10',
      title: 'Ưu Đãi Cuối Tuần Giảm 10%',
      description: 'Giảm 10% cho mọi đơn hàng đặt vào Thứ 7 & Chủ Nhật.',
      type: PromotionType.percentage,
      discountValue: 10,
      minOrderPrice: 80000,
      maxDiscountAmount: 20000,
      applicableDays: ['sat', 'sun'],
    ),
  ];

  /// Danh sách 150 thợ cắt tóc mẫu trên toàn quốc
  static final List<BarberProfileModel> sampleBarbers = generate150Barbers();

  /// Danh sách 100 đánh giá nhận xét thực tế mẫu
  static final List<Map<String, dynamic>> sampleReviews = generate100Reviews();

  /// Danh sách 150 lịch hẹn & khách hàng mẫu (bao gồm lịch sử hoàn thành, pending, confirmed)
  static final List<AppointmentModel> sampleAppointments =
      generate150Appointments();

  /// Sinh ngẫu nhiên danh sách 150 thợ cắt tóc mẫu rải rác các tỉnh thành Việt Nam
  static List<BarberProfileModel> generate150Barbers() {
    final List<BarberProfileModel> list = [];

    final cityConfigs = [
      {
        'city': 'Đà Nẵng',
        'lat': 16.0544,
        'lng': 108.2022,
        'districts': [
          'Hải Châu',
          'Sơn Trà',
          'Thanh Khê',
          'Ngũ Hành Sơn',
          'Cẩm Lệ',
        ],
        'streets': [
          'Nguyễn Văn Linh',
          'Lê Duẩn',
          'Võ Văn Kiệt',
          'Trần Phú',
          'Hùng Vương',
          'Điện Biên Phủ',
        ],
      },
      {
        'city': 'Hà Nội',
        'lat': 21.0285,
        'lng': 105.8542,
        'districts': [
          'Hoàn Kiếm',
          'Cầu Giấy',
          'Ba Đình',
          'Đống Đa',
          'Hai Bà Trưng',
          'Thanh Xuân',
          'Hà Đông',
        ],
        'streets': [
          'Tràng Thi',
          'Cầu Giấy',
          'Kim Mã',
          'Chùa Bộc',
          'Giải Phóng',
          'Nguyễn Trãi',
          'Hoàng Quốc Việt',
        ],
      },
      {
        'city': 'TP. Hồ Chí Minh',
        'lat': 10.7769,
        'lng': 106.7009,
        'districts': [
          'Quận 1',
          'Quận 3',
          'Quận 7',
          'Tân Bình',
          'Phú Nhuận',
          'Bình Thạnh',
          'Thủ Đức',
        ],
        'streets': [
          'Lê Lợi',
          'Nguyễn Thị Minh Khai',
          'Cách Mạng Tháng 8',
          'Phan Xích Long',
          'Nguyễn Văn Cừ',
          'Điện Biên Phủ',
        ],
      },
      {
        'city': 'Cần Thơ',
        'lat': 10.0452,
        'lng': 105.7469,
        'districts': ['Ninh Kiều', 'Bình Thủy', 'Cái Răng'],
        'streets': ['3 Tháng 2', 'Nguyễn Trãi', 'Trần Hưng Đạo', 'Mậu Thân'],
      },
      {
        'city': 'Hải Phòng',
        'lat': 20.8449,
        'lng': 106.6881,
        'districts': ['Hồng Bàng', 'Ngô Quyền', 'Lê Chân'],
        'streets': ['Lạch Tray', 'Cầu Đất', 'Điện Biên Phủ', 'Trần Phú'],
      },
    ];

    final shopNamePrefixes = [
      'HairFit Studio',
      '30Shine',
      'Gentleman Barber Shop',
      'Phong Bụi Barber',
      'Liêm Barber Shop',
      '1990 Barber Club',
      'Sài Gòn Vintage Barber',
      'Barber House',
      'The Brother Barber',
      'K-Style Hair Studio',
      'Vũ Trí Barber Shop',
      'Cắt Tóc Nam Hoàng Gia',
      'Classic Barber Lounge',
      'Phong Cách Quý Ông Barber',
      'Tóc Nam Hàn Quốc Studio',
    ];

    final avatarUrls = [
      'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=500&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=500&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1517832606589-7157462b3df3?w=500&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1599351431202-1e0f0137899a?w=500&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1560066984-138dadb4c035?w=500&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=500&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=500&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=500&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500&auto=format&fit=crop',
    ];

    for (int i = 1; i <= 150; i++) {
      final cityConfig = cityConfigs[(i - 1) % cityConfigs.length];
      final city = cityConfig['city'] as String;
      final baseLat = cityConfig['lat'] as double;
      final baseLng = cityConfig['lng'] as double;
      final districts = cityConfig['districts'] as List<String>;
      final streets = cityConfig['streets'] as List<String>;

      final district = districts[(i * 3) % districts.length];
      final street = streets[(i * 7) % streets.length];
      final streetNum = 10 + (i * 12) % 350;
      final namePrefix = shopNamePrefixes[(i - 1) % shopNamePrefixes.length];

      final displayName = '$namePrefix $district';
      final address = '$streetNum $street, $district, $city';
      final avatarUrl = avatarUrls[(i - 1) % avatarUrls.length];

      final latOffset = ((i * 13) % 40 - 20) * 0.0012;
      final lngOffset = ((i * 17) % 40 - 20) * 0.0012;
      final lat = baseLat + latOffset;
      final lng = baseLng + lngOffset;

      final ratingAvg = 4.2 + (i % 8) * 0.1;
      final ratingCount = 35 + (i * 11) % 180;

      list.add(
        BarberProfileModel(
          uid: 'barber_seed_${i.toString().padLeft(3, '0')}',
          displayName: displayName,
          avatarUrl: avatarUrl,
          bio:
              'Chuyên tạo kiểu tóc nam hiện đại, cắt chuẩn phom, sấy tạo phồng phong cách $district.',
          address: address,
          location: GeoLocation(latitude: lat, longitude: lng),
          priceMin: 70000 + (i % 4) * 10000,
          priceMax: 140000 + (i % 5) * 20000,
          ratingAvg: double.parse(ratingAvg.toStringAsFixed(2)),
          ratingCount: ratingCount,
          approvalStatus: 'approved',
          hairstyleIds: const [
            'undercut',
            'side_part',
            'layer_male',
            'two_block',
            'quiff',
            'french_crop',
          ],
          services: const [
            ServiceModel(
              id: 'svc_standard',
              name: 'Cắt tạo kiểu tiêu chuẩn',
              price: 80000,
              durationMinutes: 30,
            ),
            ServiceModel(
              id: 'svc_combo',
              name: 'Combo Cắt + Gội massage + Sấy vuốt',
              price: 120000,
              durationMinutes: 60,
            ),
            ServiceModel(
              id: 'svc_perm',
              name: 'Uốn phồng Hàn Quốc / Textured',
              price: 180000,
              durationMinutes: 90,
            ),
          ],
          workingHours: {
            'mon': const DayWorkingHours(
              closed: false,
              open: '08:30',
              close: '20:30',
            ),
            'tue': const DayWorkingHours(
              closed: false,
              open: '08:30',
              close: '20:30',
            ),
            'wed': const DayWorkingHours(
              closed: false,
              open: '08:30',
              close: '20:30',
            ),
            'thu': const DayWorkingHours(
              closed: false,
              open: '08:30',
              close: '20:30',
            ),
            'fri': const DayWorkingHours(
              closed: false,
              open: '08:30',
              close: '20:30',
            ),
            'sat': const DayWorkingHours(
              closed: false,
              open: '08:30',
              close: '21:00',
            ),
            'sun': const DayWorkingHours(
              closed: false,
              open: '09:00',
              close: '19:00',
            ),
          },
        ),
      );
    }

    return list;
  }

  /// Sinh ngẫu nhiên danh sách 150 lịch hẹn & khách hàng mẫu với lịch sử cắt thực tế
  static List<AppointmentModel> generate150Appointments() {
    final List<AppointmentModel> list = [];
    final barbers = generate150Barbers();

    final customerFirstNames = [
      'Nguyễn',
      'Trần',
      'Lê',
      'Phạm',
      'Đặng',
      'Vũ',
      'Bùi',
      'Ngô',
      'Hoàng',
      'Dương',
      'Đỗ',
      'Lý',
      'Phan',
      'Trịnh',
      'Đinh',
      'Đoàn',
      'Mai',
    ];
    final customerMiddleNames = [
      'Văn',
      'Hoàng',
      'Quốc',
      'Đức',
      'Nhật',
      'Thành',
      'Tấn',
      'Kim',
      'Minh',
      'Thanh',
      'Tuấn',
      'Thái',
      'Đình',
      'Bảo',
      'Gia',
    ];
    final customerLastNames = [
      'An',
      'Nam',
      'Bảo',
      'Anh',
      'Long',
      'Tân',
      'Đạt',
      'Tài',
      'Sơn',
      'Trí',
      'Hùng',
      'Kiệt',
      'Hải',
      'Quân',
      'Khoa',
      'Duy',
      'Phú',
      'Lâm',
      'Việt',
      'Khánh',
    ];

    final reviews = [
      'Cắt rất ưng ý, anh thợ cắt kĩ và tư vấn dáng mặt nhiệt tình!',
      'Combo gội massage cực thoải mái, vuốt sáp tạo phóm chuẩn salon.',
      'Cắt đúng phom Layer Hàn Quốc mình chọn trên app HairFit AI, rất hợp mặt!',
      'Thợ nhiệt tình, tiệm sạch sẽ, không gian phong cách Barber Châu Âu ấn tượng.',
      'Đặt lịch trước trên app không phải chờ đợi chút nào, vô cùng hài lòng.',
      'Tạo kiểu Side Part 7/3 vuốt sáp rất giữ nếp, 5 sao chất lượng!',
      'Lần thứ 3 cắt ở đây, anh chủ vui tính, tay nghề cao!',
      'Phục vụ chu đáo, tư vấn kiểu tóc AI rất chuẩn dáng mặt của mình.',
      'Giá cả hợp lý, gội đầu thư giãn, lần sau sẽ ghé tiếp.',
      'Cắt sắc nét, uốn xoăn phồng rất tự nhiên!',
    ];

    final faceShapes = ['oval', 'round', 'square', 'heart', 'oblong'];
    final hairstyleIds = [
      'undercut',
      'side_part',
      'layer_male',
      'two_block',
      'quiff',
      'french_crop',
      'comma_hair',
      'ivy_league',
    ];

    final now = DateTime.now();

    for (int i = 1; i <= 150; i++) {
      final fName = customerFirstNames[(i * 3) % customerFirstNames.length];
      final mName = customerMiddleNames[(i * 5) % customerMiddleNames.length];
      final lName = customerLastNames[(i * 7) % customerLastNames.length];
      final customerName = '$fName $mName $lName';
      final customerId = 'customer_seed_${i.toString().padLeft(3, '0')}';

      final barber = barbers[(i * 11) % barbers.length];
      final hairstyleId = hairstyleIds[i % hairstyleIds.length];
      final faceShape = faceShapes[i % faceShapes.length];

      AppointmentStatus status;
      DateTime appDate;
      int? rating;
      String? reviewComment;

      if (i <= 100) {
        status = AppointmentStatus.completed;
        appDate = now.subtract(Duration(days: (i % 45) + 1));
        rating = (i % 10 == 0) ? 4 : 5;
        reviewComment = reviews[(i - 1) % reviews.length];
      } else if (i <= 130) {
        status = AppointmentStatus.confirmed;
        appDate = now.add(Duration(days: (i % 7)));
      } else if (i <= 142) {
        status = AppointmentStatus.pending;
        appDate = now.add(Duration(days: (i % 5) + 1));
      } else {
        status = AppointmentStatus.cancelled;
        appDate = now.subtract(Duration(days: (i % 15) + 2));
      }

      final dateStr = DateFormat('yyyy-MM-dd').format(appDate);
      final hour = 8 + (i % 10);
      final minute = (i % 2 == 0) ? '00' : '30';
      final startTime = '${hour.toString().padLeft(2, '0')}:$minute';
      final endHour = (minute == '30') ? hour + 1 : hour;
      final endMinute = (minute == '30') ? '00' : '30';
      final endTime = '${endHour.toString().padLeft(2, '0')}:$endMinute';

      final startTimestamp = DateTime(
        appDate.year,
        appDate.month,
        appDate.day,
        hour,
        int.parse(minute),
      );
      final endTimestamp = startTimestamp.add(const Duration(minutes: 30));

      final service = barber.services.first;
      final slotId =
          '${barber.uid}_${dateStr}_${startTime.replaceAll(':', '-')}';

      list.add(
        AppointmentModel(
          id: 'app_seed_${i.toString().padLeft(3, '0')}',
          customerId: customerId,
          customerName: customerName,
          barberId: barber.uid,
          barberName: barber.displayName,
          serviceId: service.id,
          serviceName: service.name,
          price: service.price,
          durationMinutes: service.durationMinutes,
          date: dateStr,
          startTime: startTime,
          endTime: endTime,
          startTimestamp: startTimestamp,
          endTimestamp: endTimestamp,
          slotIds: [slotId],
          hairstyleId: hairstyleId,
          customerFaceShape: faceShape,
          aiStylingTip: 'Nên sấy phồng chân tóc và dùng sáp vuốt giữ nếp',
          customerPhone: '0905${(100000 + i * 1234) % 900000}',
          barberPhone: '0988${(200000 + i * 5678) % 900000}',
          note: 'Đặt qua ứng dụng HairFit AI',
          status: status,
          rating: rating,
          reviewComment: reviewComment,
          promoCode: (i % 5 == 0) ? 'HAPPYHOUR20' : '',
          discountAmount: (i % 5 == 0) ? 16000 : 0,
        ),
      );
    }

    return list;
  }

  /// Danh sách 50 khách hàng mẫu
  static final List<UserModel> sampleCustomers = generate50Customers();

  /// Sinh 50 khách hàng mẫu đầy đủ thông tin hồ sơ
  static List<UserModel> generate50Customers() {
    final List<UserModel> list = [];

    final customerFirstNames = [
      'Nguyễn',
      'Trần',
      'Lê',
      'Phạm',
      'Đặng',
      'Vũ',
      'Bùi',
      'Ngô',
      'Hoàng',
      'Dương',
      'Đỗ',
      'Lý',
      'Phan',
      'Trịnh',
      'Đinh',
      'Đoàn',
      'Mai',
    ];
    final customerMiddleNames = [
      'Văn',
      'Hoàng',
      'Quốc',
      'Đức',
      'Nhật',
      'Thành',
      'Tấn',
      'Kim',
      'Minh',
      'Thanh',
      'Tuấn',
      'Thái',
      'Đình',
      'Bảo',
      'Gia',
    ];
    final customerLastNames = [
      'An',
      'Nam',
      'Bảo',
      'Anh',
      'Long',
      'Tân',
      'Đạt',
      'Tài',
      'Sơn',
      'Trí',
      'Hùng',
      'Kiệt',
      'Hải',
      'Quân',
      'Khoa',
      'Duy',
      'Phú',
      'Lâm',
      'Việt',
      'Khánh',
    ];

    final faceShapes = ['oval', 'round', 'square', 'heart', 'oblong'];
    final avatarUrls = [
      'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=500&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=500&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1527980965255-d3b416303d12?w=500&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=500&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=500&auto=format&fit=crop',
    ];

    final now = DateTime.now();

    for (int i = 1; i <= 50; i++) {
      final fName = customerFirstNames[(i * 3) % customerFirstNames.length];
      final mName = customerMiddleNames[(i * 5) % customerMiddleNames.length];
      final lName = customerLastNames[(i * 7) % customerLastNames.length];
      final displayName = '$fName $mName $lName';
      final uid = 'customer_seed_${i.toString().padLeft(3, '0')}';
      final email = 'khachhang${i.toString().padLeft(2, '0')}@hairfit.ai';
      final phone = '0905${(100000 + i * 1234) % 900000}';
      final avatarUrl = avatarUrls[(i - 1) % avatarUrls.length];
      final faceShape = faceShapes[i % faceShapes.length];

      list.add(
        UserModel(
          uid: uid,
          email: email,
          displayName: displayName,
          avatarUrl: avatarUrl,
          role: UserRole.customer,
          isBlocked: false,
          phone: phone,
          savedFaceShape: faceShape,
          favoriteBarberIds: [
            'barber_seed_${((i * 3) % 100 + 1).toString().padLeft(3, '0')}',
            'barber_seed_${((i * 7) % 100 + 1).toString().padLeft(3, '0')}',
          ],
          createdAt: now.subtract(Duration(days: i * 3)),
          updatedAt: now,
        ),
      );
    }

    return list;
  }

  /// Sinh 100 đánh giá nhận xét mẫu cho các thợ cắt tóc
  static List<Map<String, dynamic>> generate100Reviews() {
    final List<Map<String, dynamic>> list = [];
    final barbers = sampleBarbers;
    final customers = sampleCustomers;

    final reviewComments = [
      'Cắt rất ưng ý, anh thợ cắt kĩ và tư vấn dáng mặt nhiệt tình!',
      'Combo gội massage cực thoải mái, vuốt sáp tạo phom chuẩn salon.',
      'Cắt đúng phom Layer Hàn Quốc mình chọn trên app HairFit AI, rất hợp mặt!',
      'Thợ nhiệt tình, tiệm sạch sẽ, không gian phong cách Barber Châu Âu ấn tượng.',
      'Đặt lịch trước trên app không phải chờ đợi chút nào, vô cùng hài lòng.',
      'Tạo kiểu Side Part 7/3 vuốt sáp rất giữ nếp, 5 sao chất lượng!',
      'Lần thứ 3 cắt ở đây, anh chủ vui tính, tay nghề cao!',
      'Phục vụ chu đáo, tư vấn kiểu tóc AI rất chuẩn dáng mặt của mình.',
      'Giá cả hợp lý, gội đầu thư giãn, lần sau sẽ ghé tiếp.',
      'Cắt sắc nét, uốn xoăn phồng rất tự nhiên!',
      'Tay nghề đỉnh cao, tư vấn kiểu tóc vuốt sáp giữ phom rất bền.',
      'Không gian sạch sẽ, dụng cụ tiệt trùng cẩn thận, rất yên tâm.',
      'Anh thợ vui tính, cắt đúng ý 100%, sẽ giới thiệu thêm bạn bè.',
      'Cắt phom Undercut nét căng, gội đầu thư giãn dễ chịu.',
      'App gợi ý kiểu tóc chuẩn dáng mặt thật, ra tiệm cắt y hệt!',
    ];

    final now = DateTime.now();

    for (int i = 1; i <= 100; i++) {
      final barber = barbers[(i * 3) % barbers.length];
      final customer = customers[(i * 5) % customers.length];
      final comment = reviewComments[(i - 1) % reviewComments.length];
      final rating = (i % 8 == 0) ? 4 : 5;
      final createdAt = now.subtract(Duration(days: (i % 60) + 1));

      list.add({
        'id': 'review_seed_${i.toString().padLeft(3, '0')}',
        'appointmentId': 'app_seed_${i.toString().padLeft(3, '0')}',
        'barberId': barber.uid,
        'customerId': customer.uid,
        'customerName': customer.displayName,
        'rating': rating,
        'reviewComment': comment,
        'createdAt': Timestamp.fromDate(createdAt),
      });
    }

    return list;
  }

  /// Nạp toàn bộ dữ liệu 50 kiểu tóc vào Firestore
  Future<void> seedHairstyles({bool overwrite = false}) async {
    final collection = _firestore.collection('hairstyleCatalog');

    for (final hairstyle in sampleHairstyles) {
      final docRef = collection.doc(hairstyle.id);
      if (!overwrite) {
        final existing = await docRef.get();
        if (existing.exists) {
          debugPrint('⏭️ Bỏ qua kiểu tóc đã tồn tại: ${hairstyle.name}');
          continue;
        }
      }
      await docRef.set(hairstyle.toMap());
      debugPrint('✅ Đã nạp kiểu tóc: ${hairstyle.name}');
    }
  }

  /// Nạp toàn bộ dữ liệu 150 thợ cắt tóc vào Firestore
  Future<void> seedBarbers({bool overwrite = false}) async {
    final collection = _firestore.collection('barberProfiles');

    for (final barber in sampleBarbers) {
      final docRef = collection.doc(barber.uid);
      if (!overwrite) {
        final existing = await docRef.get();
        if (existing.exists) {
          debugPrint('⏭️ Bỏ qua thợ đã tồn tại: ${barber.displayName}');
          continue;
        }
      }
      await docRef.set(barber.toMap());
      debugPrint('✅ Đã nạp hồ sơ thợ: ${barber.displayName}');
    }
  }

  /// Nạp 50 tài khoản khách hàng mẫu vào Firestore collection 'users'
  Future<void> seedCustomers({bool overwrite = false}) async {
    final collection = _firestore.collection('users');

    for (final customer in sampleCustomers) {
      final docRef = collection.doc(customer.uid);
      if (!overwrite) {
        final existing = await docRef.get();
        if (existing.exists) {
          debugPrint('⏭️ Bỏ qua khách hàng đã tồn tại: ${customer.displayName}');
          continue;
        }
      }
      await docRef.set(customer.toMap());
      debugPrint('✅ Đã nạp tài khoản khách hàng: ${customer.displayName}');
    }
  }

  /// Nạp 100 bản ghi đánh giá vào Firestore collection 'reviews'
  Future<void> seedReviews({bool overwrite = false}) async {
    final collection = _firestore.collection('reviews');

    for (final review in sampleReviews) {
      final id = review['id'] as String;
      final docRef = collection.doc(id);
      if (!overwrite) {
        final existing = await docRef.get();
        if (existing.exists) {
          debugPrint('⏭️ Bỏ qua đánh giá đã tồn tại: $id');
          continue;
        }
      }
      await docRef.set(review);
      debugPrint('✅ Đã nạp đánh giá: $id (${review['customerName']} -> ${review['rating']}★)');
    }
  }

  /// Nạp 150 lịch hẹn & lịch sử cắt tóc mẫu vào Firestore
  Future<void> seedSampleAppointments({bool overwrite = false}) async {
    final collection = _firestore.collection('appointments');

    for (final app in sampleAppointments) {
      final docRef = collection.doc(app.id);
      if (!overwrite) {
        final existing = await docRef.get();
        if (existing.exists) {
          debugPrint('⏭️ Bỏ qua lịch hẹn đã tồn tại: ${app.id}');
          continue;
        }
      }
      await docRef.set(app.toMap());
      debugPrint('✅ Đã nạp lịch hẹn: ${app.id} (${app.customerName})');
    }
  }

  /// Nạp tất cả dữ liệu seed cùng lúc (50 kiểu tóc, 150 thợ, 50 khách hàng, 100 đánh giá, 150 lịch hẹn)
  Future<void> seedAll({bool overwrite = false}) async {
    debugPrint('🚀 Bắt đầu quá trình nạp dữ liệu Seed Data...');
    await seedHairstyles(overwrite: overwrite);
    await seedBarbers(overwrite: overwrite);
    await seedCustomers(overwrite: overwrite);
    await seedReviews(overwrite: overwrite);
    await seedSampleAppointments(overwrite: overwrite);
    debugPrint('🎉 Đã hoàn tất nạp toàn bộ Seed Data thành công!');
  }

  /// Xoá toàn bộ thợ mẫu Seed Data khỏi Firestore
  Future<void> clearSampleBarbers() async {
    final collection = _firestore.collection('barberProfiles');
    for (final barber in sampleBarbers) {
      try {
        await collection.doc(barber.uid).delete();
        debugPrint('🗑️ Đã xoá thợ mẫu: ${barber.displayName}');
      } catch (e) {
        debugPrint('⚠️ Không thể xoá ${barber.uid}: $e');
      }
    }
  }

  /// Xóa các lịch hẹn mẫu thử nghiệm
  Future<void> clearSampleAppointments() async {
    final collection = _firestore.collection('appointments');
    for (final app in sampleAppointments) {
      try {
        await collection.doc(app.id).delete();
        debugPrint('🗑️ Đã xoá lịch hẹn mẫu: ${app.id}');
      } catch (_) {}
    }
  }
}

// CreBy: MenBoyBMN
