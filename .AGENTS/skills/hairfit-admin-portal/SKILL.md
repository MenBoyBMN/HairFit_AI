---
name: hairfit-admin-portal
description: Guide for developing, testing, and maintaining the HairFit AI Admin Management Portal and seed data scripts.
risk: low
source: workspace
---

# HairFit AI - Admin Portal Engineering Guide

## 1. Overview & Role Security
The Admin Portal provides full operational governance over HairFit AI.
Access is gated at two levels:
1. **Route Guard**: In `AppRouter`, any route prefixed with `/admin` requires `user.role == UserRole.admin`. Non-admin users are automatically redirected to their designated home screen.
2. **Firestore Security**: `firestore.rules` enforces admin-only write permissions for moderation, barber approval, and global system configuration.

---

## 2. Admin Modules Reference

| Screen | Location | Core Functionality |
| :--- | :--- | :--- |
| **AdminShellScreen** | `lib/features/admin/presentation/admin_shell_screen.dart` | Responsive navigation rail/bottom bar for admin sub-routes |
| **AdminDashboardScreen** | `lib/features/admin/presentation/admin_dashboard_screen.dart` | Key performance indicators (revenue, users, appointments, barber stats) |
| **ApproveBarbersScreen** | `lib/features/admin/presentation/approve_barbers_screen.dart` | Review and verify new barber registrations |
| **AdminBarbersScreen** | `lib/features/admin/presentation/admin_barbers_screen.dart` | Full barber directory, status filter, and suspension toggle |
| **AdminAppointmentsScreen**| `lib/features/admin/presentation/admin_appointments_screen.dart`| Live appointment monitor with date & status filtering |
| **AdminUsersScreen** | `lib/features/admin/presentation/admin_users_screen.dart` | User accounts list, role assignment, and search |
| **AdminReviewsScreen** | `lib/features/admin/presentation/admin_reviews_screen.dart` | Moderation of salon reviews and star ratings |
| **AdminSettingsScreen** | `lib/features/admin/presentation/admin_settings_screen.dart` | System maintenance, cache clearing, seed data execution |

---

## 3. Mock & Seed Data Utilities
Location: `lib/core/services/seed_data_service.dart`
- Used to populate realistic demo data (salons, services, sample appointments, test users) in Firestore for staging and review.
- Always check that seeded barbers contain valid working hours and coordinates around major Vietnamese cities (e.g. Da Nang, Hanoi, Ho Chi Minh City).
