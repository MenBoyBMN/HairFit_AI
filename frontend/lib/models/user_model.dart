// ============================================================================
// File: lib/models/user_model.dart
// Mục đích: Định nghĩa cấu trúc dữ liệu (user_model).
// Kết cấu:
//  - Lớp mô hình (Model) bao gồm các thuộc tính và phương thức chuyển đổi (toMap, fromMap, copyWith).
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  customer,
  barber,
  admin;

  static UserRole fromString(String? role) {
    switch (role?.toLowerCase().trim()) {
      case 'barber':
        return UserRole.barber;
      case 'admin':
        return UserRole.admin;
      case 'customer':
      default:
        return UserRole.customer;
    }
  }

  String toRoleString() {
    switch (this) {
      case UserRole.customer:
        return 'customer';
      case UserRole.barber:
        return 'barber';
      case UserRole.admin:
        return 'admin';
    }
  }
}

/// Mô hình tài khoản người dùng HairFit AI (users/{uid})
class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String avatarUrl;
  final UserRole role;
  final bool isBlocked;
  final String? phone;
  final String? savedFaceShape;
  final List<String> savedHairstyleIds;
  final List<String> favoriteBarberIds;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.avatarUrl = '',
    this.role = UserRole.customer,
    this.isBlocked = false,
    this.phone,
    this.savedFaceShape,
    this.savedHairstyleIds = const [],
    this.favoriteBarberIds = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, {String? id}) {
    DateTime? parseTimestamp(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    return UserModel(
      uid: id ?? map['uid'] as String? ?? '',
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String? ?? '',
      avatarUrl: map['avatarUrl'] as String? ?? '',
      role: UserRole.fromString(map['role'] as String?),
      isBlocked: map['isBlocked'] as bool? ?? false,
      phone: map['phone'] as String?,
      savedFaceShape: map['savedFaceShape'] as String?,
      savedHairstyleIds:
          (map['savedHairstyleIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      favoriteBarberIds:
          (map['favoriteBarberIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      createdAt: parseTimestamp(map['createdAt']),
      updatedAt: parseTimestamp(map['updatedAt']),
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return UserModel.fromMap(data, id: doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'role': role.toRoleString(),
      'isBlocked': isBlocked,
      if (phone != null) 'phone': phone,
      if (savedFaceShape != null) 'savedFaceShape': savedFaceShape,
      'savedHairstyleIds': savedHairstyleIds,
      'favoriteBarberIds': favoriteBarberIds,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? avatarUrl,
    UserRole? role,
    bool? isBlocked,
    String? phone,
    String? savedFaceShape,
    List<String>? savedHairstyleIds,
    List<String>? favoriteBarberIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      isBlocked: isBlocked ?? this.isBlocked,
      phone: phone ?? this.phone,
      savedFaceShape: savedFaceShape ?? this.savedFaceShape,
      savedHairstyleIds: savedHairstyleIds ?? this.savedHairstyleIds,
      favoriteBarberIds: favoriteBarberIds ?? this.favoriteBarberIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isCustomer => role == UserRole.customer;
  bool get isBarber => role == UserRole.barber;
  bool get isAdmin => role == UserRole.admin;
}

// CreBy: MenBoyBMN
