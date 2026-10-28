# UI Design & Styling Rules

## 1. Design Philosophy
HairFit AI features a modern, masculine, high-end salon aesthetic:
- **Palette**: Dark Mode First. Pitch black (`#121212`) background paired with dark card surfaces (`#1E1E1E`), warm amber/orange primary accents (`#FF6B00`), and gold/secondary accents.
- **Glassmorphism**: Subtle borders (`#2C2C2C` or semi-transparent white) with gentle elevation.
- **No Raw Colors**: Never use `Colors.black`, `Colors.white`, or hardcoded hex strings directly in UI code. Always import:
  ```dart
  import 'package:hairfit_ai/core/constants/app_colors.dart';
  import 'package:hairfit_ai/core/constants/app_dimensions.dart';
  import 'package:hairfit_ai/core/constants/app_text_styles.dart';
  ```

## 2. Token References

### Colors (`AppColors`)
- Background: `AppColors.background` (`0xFF121212`)
- Surface: `AppColors.surface` (`0xFF1E1E1E`)
- Card Surface: `AppColors.card` (`0xFF252525`)
- Primary (Brand): `AppColors.primary` (`0xFFFF6B00`)
- Secondary / Accent: `AppColors.accent` (`0xFFFFB800`)
- Text Primary: `AppColors.textPrimary` (`0xFFFFFFFF`)
- Text Secondary: `AppColors.textSecondary` (`0xFF9E9E9E`)
- Success / Error: `AppColors.success` (`0xFF4CAF50`), `AppColors.error` (`0xFFE53935`)

### Dimensions & Spacing (`AppDimensions`)
- Spacing: `AppDimensions.xs` (4), `AppDimensions.sm` (8), `AppDimensions.md` (16), `AppDimensions.lg` (24), `AppDimensions.xl` (32)
- Border Radius: `AppDimensions.radiusSm` (8), `AppDimensions.radiusMd` (12), `AppDimensions.radiusLg` (16)

## 3. Responsive Layout & Overflow Safety
- Any column that can grow dynamically with content or keyboard must be wrapped in `SingleChildScrollView` or a scrollable list.
- In `Row` widgets, wrap flexible child text widgets in `Expanded` or `Flexible` with `overflow: TextOverflow.ellipsis`.
- Support varied screen heights in widget testing: use minimum sizing bounds and test with standard mobile aspect ratios.

## 4. Language & Localization Standards
- All customer and barber facing UI text must be natural, polite Vietnamese.
- Examples:
  - *"Đặt lịch ngay"*, *"Xác nhận ca hẹn"*, *"Hồ sơ tóc AI của bạn"*, *"Đổi lịch hẹn"*, *"Quản lý lịch hẹn"*.
- Error dialogues should provide clear, actionable guidance in Vietnamese rather than raw technical stack traces.
