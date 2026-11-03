// ============================================================================
// File: lib/features/appointments/presentation/widgets/directions_bottom_sheet.dart
// Mục đích: BottomSheet hiển thị thông tin salon & hỗ trợ chỉ đường GPS chính xác.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/url_helper.dart';
import '../../../../models/appointment_model.dart';
import '../../../search_map/data/barber_repository.dart';

class DirectionsBottomSheet extends ConsumerWidget {
  final AppointmentModel appointment;

  const DirectionsBottomSheet({super.key, required this.appointment});

  static Future<void> show(
    BuildContext context, {
    required AppointmentModel appointment,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DirectionsBottomSheet(appointment: appointment),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final barberAsync = ref.watch(barberDetailProvider(appointment.barberId));

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXl),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(
                    top: AppDimensions.sm,
                    bottom: AppDimensions.md,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.xs),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.directions_rounded,
                      color: AppColors.accent,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  const Expanded(
                    child: Text('Chỉ Đường Đến Tiệm', style: AppTextStyles.h4),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.md),

              // Card thông tin tiệm và địa chỉ
              barberAsync.when(
                data: (barber) {
                  final address = barber?.address.trim() ?? '';
                  final hasLocation = barber != null &&
                      barber.location.latitude != 0 &&
                      barber.location.longitude != 0;

                  return Container(
                    padding: const EdgeInsets.all(AppDimensions.md),
                    decoration: BoxDecoration(
                      color: AppColors.background.withValues(alpha: 0.5),
                      borderRadius: AppDimensions.borderRadiusMd,
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppDimensions.sm),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.storefront_rounded,
                                color: AppColors.primary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: AppDimensions.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    appointment.barberName.isNotEmpty
                                        ? appointment.barberName
                                        : (barber?.displayName ?? 'Tiệm cắt tóc'),
                                    style: AppTextStyles.h4,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Dịch vụ: ${appointment.serviceName} (${appointment.durationMinutes} phút)',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                  Text(
                                    'Lịch hẹn: ${appointment.startTime} - ${appointment.endTime}, ${appointment.date}',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: AppDimensions.lg),

                        // Chi tiết địa chỉ
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              color: AppColors.accent,
                              size: 18,
                            ),
                            const SizedBox(width: AppDimensions.xs),
                            Expanded(
                              child: Text(
                                address.isNotEmpty
                                    ? address
                                    : 'Địa chỉ đang được cập nhật bởi thợ',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (address.isNotEmpty)
                              InkWell(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: address));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Đã sao chép địa chỉ tiệm!'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(4),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(
                                        Icons.copy_rounded,
                                        size: 14,
                                        color: AppColors.primary,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Chép',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),

                        if (hasLocation) ...[
                          const SizedBox(height: AppDimensions.xs),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.gps_fixed_rounded,
                                  color: AppColors.success,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Tọa độ GPS: ${barber.location.latitude.toStringAsFixed(4)}, ${barber.location.longitude.toStringAsFixed(4)}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
                loading: () => Container(
                  padding: const EdgeInsets.all(AppDimensions.md),
                  decoration: BoxDecoration(
                    color: AppColors.background.withValues(alpha: 0.5),
                    borderRadius: AppDimensions.borderRadiusMd,
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: AppDimensions.md),
                      Expanded(
                        child: Text(
                          'Đang tải vị trí của ${appointment.barberName}...',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                error: (_, _) => Container(
                  padding: const EdgeInsets.all(AppDimensions.md),
                  decoration: BoxDecoration(
                    color: AppColors.background.withValues(alpha: 0.5),
                    borderRadius: AppDimensions.borderRadiusMd,
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Text(
                    appointment.barberName,
                    style: AppTextStyles.h4,
                  ),
                ),
              ),

              const SizedBox(height: AppDimensions.lg),

              // Nút 1: Chỉ đường bằng Google Maps
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppDimensions.borderRadiusMd,
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.navigation_rounded, size: 20),
                label: const Text(
                  'Chỉ Đường Bằng Google Maps (GPS)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  final barber = barberAsync.valueOrNull;
                  Navigator.of(context).pop();
                  UrlHelper.openMapDirections(
                    latitude: barber?.location.latitude,
                    longitude: barber?.location.longitude,
                    address: barber?.address,
                    title: appointment.barberName,
                  );
                },
              ),

              const SizedBox(height: AppDimensions.sm),

              // Nút 2: Xem trên Bản đồ HairFit AI
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.accent,
                  side: const BorderSide(color: AppColors.accent),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppDimensions.borderRadiusMd,
                  ),
                ),
                icon: const Icon(Icons.explore_outlined, size: 20),
                label: const Text(
                  'Xem Trên Bản Đồ HairFit AI',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  final query = appointment.barberName.trim();
                  if (query.isNotEmpty) {
                    context.push('/customer/search?query=${Uri.encodeComponent(query)}');
                  } else {
                    context.push('/customer/search');
                  }
                },
              ),

              const SizedBox(height: AppDimensions.sm),
              Center(
                child: Text(
                  '💡 Tự động bật dẫn đường turn-by-turn từ vị trí của bạn tới salon',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: AppDimensions.md),
            ],
          ),
        ),
      ),
    );
  }
}

// CreBy: MenBoyBMN

