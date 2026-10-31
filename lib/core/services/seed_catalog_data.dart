// ============================================================================
// File: lib/core/services/seed_catalog_data.dart
// Purpose: Provides expanded seed data for 50 hairstyles, 50 barbers/salons (Da Nang & HCMC), and 50 customers.
// ============================================================================

import '../../models/barber_profile_model.dart';
import '../../models/hairstyle_model.dart';
import '../../models/service_model.dart';
import '../../models/user_model.dart';

class SeedCatalogData {
  SeedCatalogData._();

  /// 50 Hairstyles (10 original + 40 new varieties: fade, korean, curly, retro, long, buzz, etc.)
  static final List<HairstyleModel> sampleHairstyles = [
    // --- 10 Original Hairstyles ---
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

    // --- 40 Additional Hairstyles (IDs: style_11 to style_50) ---
    ...List.generate(40, (index) {
      final idNum = index + 11;
      final names = [
        'Mid Fade Hiện Đại', 'Low Fade Gọn Gàng', 'High Fade Cá Tính', 'Drop Fade Phá Cách', 'Taper Fade Nam Tính',
        'Korean Perm Xoăn Lơi', 'Curly Fringe Phồng', 'Messy Fringe Tự Nhiên', 'Comma Hair Chữ Phẩy', 'Center Part 5/5',
        'Ivy League Tri Thức', 'Crew Cut Tiện Lợi', 'Induction Cut Sạch Sẽ', 'Burr Cut Thể Thao', 'Butch Cut Gọn Gàng',
        'Spiky Hair Gai Góc', 'Spike Modern Năng Động', 'Faux Hawk Phóng Khoáng', 'Mohawk Đường Phố', 'Afro Twist Độc Đáo',
        'Dreadlocks Nghệ Thuật', 'Man Bun Lãng Tử', 'Top Knot Gọn Gàng', 'Long Flow Lãng Mạn', 'Curtain Hair Thập Niên 90',
        'Comb Over Cổ Điển', 'Flat Top Cứng Cáp', 'High And Tight Quân Đội', 'Buzz Cut Fade', 'Side Swept Nam Tính',
        'Layer Texturized', 'Asymmetrical Crop', 'Blunt Fringe', 'Textured Fringe', 'Messy Quiff',
        'Classic Pompadour', 'Modern Pompadour', 'Slicked Undercut', 'Bro Flow Tự Nhiên', 'Shaggy Hair Phong Cách'
      ];
      final shapesList = [
        ['round', 'square'], ['oval', 'oblong'], ['heart', 'oval'], ['square', 'oblong'], ['round', 'oval']
      ];
      final tagsList = [
        ['nam', 'fade', 'gọn'], ['nam', 'xoăn', 'hàn quốc'], ['nam', 'cổ điển', 'lịch lãm'],
        ['nam', 'ngắn', 'mát'], ['nam', 'dài', 'lãng tử'], ['nam', 'cá tính', 'streetwear']
      ];
      final imgList = [
        'https://images.unsplash.com/photo-1622286342621-4bd786c2447c?w=500&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=500&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=500&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500&auto=format&fit=crop',
      ];

      return HairstyleModel(
        id: 'style_$idNum',
        name: names[index % names.length],
        description: 'Kiểu tóc ${names[index % names.length]} được thiết kế tối ưu hóa theo xu hướng mới nhất, mang lại vẻ ngoài ấn tượng và lịch lãm.',
        imageUrl: imgList[index % imgList.length],
        imageUrls: [
          imgList[index % imgList.length],
          imgList[(index + 1) % imgList.length],
        ],
        faceShapes: shapesList[index % shapesList.length],
        tags: tagsList[index % tagsList.length],
        active: true,
      );
    }),
  ];

  /// 50 Barbers/Salons (5 original Da Nang + 45 new: 24 in Da Nang, 21 in HCMC)
  static final List<BarberProfileModel> sampleBarbers = [
    // --- 5 Original Da Nang Barbers ---
    BarberProfileModel(
      uid: 'barber_danang_01',
      displayName: 'HairFit Studio Đà Nẵng',
      avatarUrl: 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?w=500&auto=format&fit=crop',
      bio: 'Tiệm cắt tóc chuẩn phong cách Barber Châu Âu, hơn 8 năm kinh nghiệm tạo kiểu cho các quý ông.',
      address: '123 Nguyễn Văn Linh, Quận Hải Châu, Đà Nẵng',
      location: const GeoLocation(latitude: 16.0544, longitude: 108.2022),
      priceMin: 80000,
      priceMax: 150000,
      ratingAvg: 4.9,
      ratingCount: 128,
      approvalStatus: 'approved',
      hairstyleIds: ['undercut', 'side_part', 'pompadour', 'quiff'],
      services: const [
        ServiceModel(id: 'svc_01', name: 'Cắt tạo kiểu cao cấp', price: 80000, durationMinutes: 30),
        ServiceModel(id: 'svc_02', name: 'Combo Cắt + Gội massage + Sấy vuốt sáp', price: 120000, durationMinutes: 60),
        ServiceModel(id: 'svc_03', name: 'Uốn tóc tạo phồng Textured', price: 150000, durationMinutes: 90),
      ],
      workingHours: {
        'mon': const DayWorkingHours(closed: false, open: '08:30', close: '20:00'),
        'tue': const DayWorkingHours(closed: false, open: '08:30', close: '20:00'),
        'wed': const DayWorkingHours(closed: false, open: '08:30', close: '20:00'),
        'thu': const DayWorkingHours(closed: false, open: '08:30', close: '20:00'),
        'fri': const DayWorkingHours(closed: false, open: '08:30', close: '20:00'),
        'sat': const DayWorkingHours(closed: false, open: '08:00', close: '20:30'),
        'sun': const DayWorkingHours(closed: false, open: '08:00', close: '20:30'),
      },
    ),
    BarberProfileModel(
      uid: 'barber_danang_02',
      displayName: 'Gentlemen Barber Shop DN',
      avatarUrl: 'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=500&auto=format&fit=crop',
      bio: 'Không gian đậm chất vintage, chuyên các dòng tóc Classic, Fade nghệ thuật và cạo mặt truyền thống.',
      address: '45 Lê Duẩn, Quận Hải Châu, Đà Nẵng',
      location: const GeoLocation(latitude: 16.0678, longitude: 108.2134),
      priceMin: 70000,
      priceMax: 140000,
      ratingAvg: 4.8,
      ratingCount: 96,
      approvalStatus: 'approved',
      hairstyleIds: ['french_crop', 'buzz_cut', 'slicked_back'],
      services: const [
        ServiceModel(id: 'svc_21', name: 'Cắt nam tiêu chuẩn', price: 70000, durationMinutes: 30),
        ServiceModel(id: 'svc_22', name: 'Cắt + Gội + Cạo mặt', price: 110000, durationMinutes: 60),
        ServiceModel(id: 'svc_23', name: 'Nhuộm thời trang', price: 140000, durationMinutes: 90),
      ],
      workingHours: {
        'mon': const DayWorkingHours(closed: false, open: '09:00', close: '19:30'),
        'tue': const DayWorkingHours(closed: false, open: '09:00', close: '19:30'),
        'wed': const DayWorkingHours(closed: false, open: '09:00', close: '19:30'),
        'thu': const DayWorkingHours(closed: false, open: '09:00', close: '19:30'),
        'fri': const DayWorkingHours(closed: false, open: '09:00', close: '19:30'),
        'sat': const DayWorkingHours(closed: false, open: '08:30', close: '20:00'),
        'sun': const DayWorkingHours(closed: false, open: '08:30', close: '20:00'),
      },
    ),
    BarberProfileModel(
      uid: 'barber_danang_03',
      displayName: 'King Salon & Academy',
      avatarUrl: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=500&auto=format&fit=crop',
      bio: 'Học viện tóc nam hàng đầu miền Trung, cập nhật liên tục xu hướng tóc Hàn Quốc và Châu Âu.',
      address: '88 Phạm Văn Đồng, Quận Sơn Trà, Đà Nẵng',
      location: const GeoLocation(latitude: 16.0712, longitude: 108.2345),
      priceMin: 90000,
      priceMax: 180000,
      ratingAvg: 4.9,
      ratingCount: 210,
      approvalStatus: 'approved',
      hairstyleIds: ['layer_male', 'two_block', 'mullet_modern'],
      services: const [
        ServiceModel(id: 'svc_31', name: 'Cắt tạo kiểu Master', price: 90000, durationMinutes: 30),
        ServiceModel(id: 'svc_32', name: 'Combo VIP King', price: 130000, durationMinutes: 60),
        ServiceModel(id: 'svc_33', name: 'Uốn/Duỗi Hàn Quốc', price: 180000, durationMinutes: 90),
      ],
      workingHours: {
        'mon': const DayWorkingHours(closed: false, open: '08:00', close: '21:00'),
        'tue': const DayWorkingHours(closed: false, open: '08:00', close: '21:00'),
        'wed': const DayWorkingHours(closed: false, open: '08:00', close: '21:00'),
        'thu': const DayWorkingHours(closed: false, open: '08:00', close: '21:00'),
        'fri': const DayWorkingHours(closed: false, open: '08:00', close: '21:00'),
        'sat': const DayWorkingHours(closed: false, open: '08:00', close: '21:30'),
        'sun': const DayWorkingHours(closed: false, open: '08:00', close: '21:30'),
      },
    ),
    BarberProfileModel(
      uid: 'barber_danang_04',
      displayName: 'Urban Cut Da Nang',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500&auto=format&fit=crop',
      bio: 'Không gian hiện đại, năng động dành cho giới trẻ và cộng đồng yêu thích Streetwear.',
      address: '12 Hoàng Diệu, Quận Hải Châu, Đà Nẵng',
      location: const GeoLocation(latitude: 16.0411, longitude: 108.2178),
      priceMin: 60000,
      priceMax: 130000,
      ratingAvg: 4.7,
      ratingCount: 84,
      approvalStatus: 'approved',
      hairstyleIds: ['undercut', 'french_crop', 'buzz_cut'],
      services: const [
        ServiceModel(id: 'svc_41', name: 'Cắt tóc nhanh gọn', price: 60000, durationMinutes: 30),
        ServiceModel(id: 'svc_42', name: 'Cắt + Gội dưỡng sinh', price: 100000, durationMinutes: 60),
        ServiceModel(id: 'svc_43', name: 'Nhuộm màu khói/Sáng', price: 130000, durationMinutes: 90),
      ],
      workingHours: {
        'mon': const DayWorkingHours(closed: false, open: '09:00', close: '20:00'),
        'tue': const DayWorkingHours(closed: false, open: '09:00', close: '20:00'),
        'wed': const DayWorkingHours(closed: false, open: '09:00', close: '20:00'),
        'thu': const DayWorkingHours(closed: false, open: '09:00', close: '20:00'),
        'fri': const DayWorkingHours(closed: false, open: '09:00', close: '20:00'),
        'sat': const DayWorkingHours(closed: false, open: '08:30', close: '20:30'),
        'sun': const DayWorkingHours(closed: false, open: '08:30', close: '20:30'),
      },
    ),
    BarberProfileModel(
      uid: 'barber_danang_05',
      displayName: 'Royal Men Salon',
      avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=500&auto=format&fit=crop',
      bio: 'Dịch vụ chăm sóc tóc nam hoàng gia, tư vấn tạo kiểu miễn phí dựa trên tỷ lệ khuôn mặt.',
      address: '210 Ông Ích Khiêm, Quận Thanh Khê, Đà Nẵng',
      location: const GeoLocation(latitude: 16.0623, longitude: 108.1892),
      priceMin: 75000,
      priceMax: 160000,
      ratingAvg: 4.8,
      ratingCount: 115,
      approvalStatus: 'approved',
      hairstyleIds: ['side_part', 'pompadour', 'quiff'],
      services: const [
        ServiceModel(id: 'svc_51', name: 'Cắt tạo kiểu hoàng gia', price: 75000, durationMinutes: 30),
        ServiceModel(id: 'svc_52', name: 'Combo Royal Full', price: 120000, durationMinutes: 60),
        ServiceModel(id: 'svc_53', name: 'Hấp phục hồi tóc hư tổn', price: 160000, durationMinutes: 90),
      ],
      workingHours: {
        'mon': const DayWorkingHours(closed: false, open: '08:30', close: '20:00'),
        'tue': const DayWorkingHours(closed: false, open: '08:30', close: '20:00'),
        'wed': const DayWorkingHours(closed: false, open: '08:30', close: '20:00'),
        'thu': const DayWorkingHours(closed: false, open: '08:30', close: '20:00'),
        'fri': const DayWorkingHours(closed: false, open: '08:30', close: '20:00'),
        'sat': const DayWorkingHours(closed: false, open: '08:00', close: '20:30'),
        'sun': const DayWorkingHours(closed: false, open: '08:00', close: '20:30'),
      },
    ),

    // --- 45 Additional Barbers (24 in Da Nang: barber_danang_06 to 29; 21 in HCMC: barber_hcm_01 to 21) ---
    ...List.generate(45, (index) {
      final isHcm = index >= 24;
      final cityPrefix = isHcm ? 'hcm' : 'danang';
      final localIndex = isHcm ? index - 24 + 1 : index + 6;
      final uid = 'barber_${cityPrefix}_${localIndex.toString().padLeft(2, '0')}';
      final cityName = isHcm ? 'TP. Hồ Chí Minh' : 'Đà Nẵng';
      final district = isHcm ? 'Quận ${index % 5 + 1}' : 'Quận Hải Châu';
      
      return BarberProfileModel(
        uid: uid,
        displayName: 'HairFit Salon $cityName $localIndex',
        avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500&auto=format&fit=crop',
        bio: 'Hệ thống salon chuyên nghiệp tại $cityName, phục vụ tận tâm với trang thiết bị hiện đại.',
        address: '${index * 10 + 5} Đường Số ${index + 1}, $district, $cityName',
        location: GeoLocation(
          latitude: isHcm ? 10.7769 + (index * 0.005) : 16.0544 + (index * 0.003),
          longitude: isHcm ? 106.7009 + (index * 0.005) : 108.2022 + (index * 0.003),
        ),
        priceMin: 70000,
        priceMax: 160000,
        ratingAvg: 4.7 + (index % 3) * 0.1,
        ratingCount: 50 + index * 3,
        approvalStatus: 'approved',
        hairstyleIds: ['undercut', 'side_part', 'layer_male', 'two_block'],
        services: const [
          ServiceModel(id: 'svc_a', name: 'Cắt tóc nam tiêu chuẩn', price: 70000, durationMinutes: 30),
          ServiceModel(id: 'svc_b', name: 'Combo Cắt Gội Massage', price: 110000, durationMinutes: 60),
          ServiceModel(id: 'svc_c', name: 'Uốn/Nhuộm thời trang', price: 160000, durationMinutes: 90),
        ],
        workingHours: {
          'mon': const DayWorkingHours(closed: false, open: '08:30', close: '20:30'),
          'tue': const DayWorkingHours(closed: false, open: '08:30', close: '20:30'),
          'wed': const DayWorkingHours(closed: false, open: '08:30', close: '20:30'),
          'thu': const DayWorkingHours(closed: false, open: '08:30', close: '20:30'),
          'fri': const DayWorkingHours(closed: false, open: '08:30', close: '20:30'),
          'sat': const DayWorkingHours(closed: false, open: '08:00', close: '21:00'),
          'sun': const DayWorkingHours(closed: false, open: '08:00', close: '21:00'),
        },
      );
    }),
  ];

  /// 50 Customers (seed_customer_01 to seed_customer_50)
  static final List<UserModel> sampleCustomers = List.generate(50, (index) {
    final numStr = (index + 1).toString().padLeft(2, '0');
    return UserModel(
      uid: 'seed_customer_$numStr',
      email: 'customer_$numStr@hairfit.demo',
      displayName: 'Khách Hàng ${index + 1}',
      avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=500&auto=format&fit=crop',
      role: UserRole.customer,
      isBlocked: false,
      createdAt: DateTime.now().subtract(Duration(days: index * 2)),
      updatedAt: DateTime.now(),
    );
  });
}

// CreBy: MenBoyBMN
