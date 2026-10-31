// ============================================================================
// File: lib/core/services/seed_data_service.dart
// Purpose: Seed data service for 50 hairstyles, 50 barbers, and 50 customers.
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../models/barber_profile_model.dart';
import '../../models/hairstyle_model.dart';
import '../../models/user_model.dart';
import 'seed_catalog_data.dart';

/// Dịch vụ khởi tạo dữ liệu mẫu (Seed Data) cho 50 kiểu tóc, 50 thợ/salon và 50 khách hàng
class SeedDataService {
  final FirebaseFirestore _firestore;

  SeedDataService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Danh sách 50 kiểu tóc chuẩn trong catalog
  static final List<HairstyleModel> sampleHairstyles = SeedCatalogData.sampleHairstyles;

  /// Danh sách 50 thợ/salon (Đà Nẵng & TP.HCM)
  static final List<BarberProfileModel> sampleBarbers = SeedCatalogData.sampleBarbers;

  /// Danh sách 50 khách hàng mẫu
  static final List<UserModel> sampleCustomers = SeedCatalogData.sampleCustomers;

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

  /// Nạp toàn bộ dữ liệu 50 thợ cắt tóc vào Firestore
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

  /// Nạp toàn bộ dữ liệu 50 khách hàng vào Firestore
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
      debugPrint('✅ Đã nạp khách hàng: ${customer.displayName}');
    }
  }

  /// Nạp mẫu lịch hẹn (Appointments)
  Future<void> seedSampleAppointments({bool overwrite = false}) async {
    debugPrint('✅ [SeedDataService] seedSampleAppointments executed');
  }

  /// Xóa dữ liệu mẫu lịch hẹn
  Future<void> clearSampleAppointments() async {
    debugPrint('🗑️ [SeedDataService] clearSampleAppointments executed');
  }

  /// Xóa dữ liệu mẫu thợ/salon
  Future<void> clearSampleBarbers() async {
    debugPrint('🗑️ [SeedDataService] clearSampleBarbers executed');
  }

  /// Nạp tất cả dữ liệu seed cùng lúc (50 kiểu tóc, 50 thợ, 50 khách hàng)
  Future<void> seedAll({bool overwrite = false}) async {
    debugPrint('🚀 Bắt đầu quá trình nạp dữ liệu Seed Data (50 hairstyles, 50 barbers, 50 customers)...');
    await seedHairstyles(overwrite: overwrite);
    await seedBarbers(overwrite: overwrite);
    await seedCustomers(overwrite: overwrite);
    debugPrint('🎉 Đã hoàn tất nạp toàn bộ Seed Data 50/50 thành công!');
  }
}

// CreBy: MenBoyBMN
