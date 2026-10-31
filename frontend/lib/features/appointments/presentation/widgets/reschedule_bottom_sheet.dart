// ============================================================================
// File: lib/features/appointments/presentation/widgets/reschedule_bottom_sheet.dart
// Mục đích: BottomSheet cho phép khách hàng đổi giờ hẹn linh hoạt (Task Phase 4 - C5).
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/business_constants.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../models/appointment_model.dart';
import '../../../../models/barber_profile_model.dart';
import '../../../../models/booked_slot_model.dart';
import '../../../../models/service_model.dart';
import '../../../../providers/appointment_provider.dart';
import '../../../../providers/booking_provider.dart';
import '../../../booking/data/slot_service.dart';
import '../../../search_map/data/barber_repository.dart';

class RescheduleBottomSheet extends ConsumerStatefulWidget {
  final AppointmentModel appointment;

  const RescheduleBottomSheet({super.key, required this.appointment});

  static Future<bool?> show(
    BuildContext context, {
    required AppointmentModel appointment,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RescheduleBottomSheet(appointment: appointment),
    );
  }

  @override
  ConsumerState<RescheduleBottomSheet> createState() =>
      _RescheduleBottomSheetState();
}

class _RescheduleBottomSheetState extends ConsumerState<RescheduleBottomSheet> {
  static const _weekdayNames = ['', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  late DateTime _selectedDate;
  AvailableSlot? _selectedSlot;
  bool _isLoading = true;
  List<AvailableSlot> _availableSlots = [];
  BarberProfileModel? _barberProfile;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _loadBarberAndSlots();
  }

  Future<void> _loadBarberAndSlots() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _selectedSlot = null;
    });

    try {
      _barberProfile ??= await ref
          .read(barberRepositoryProvider)
          .getBarberById(widget.appointment.barberId);

      if (_barberProfile == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Không tìm thấy thông tin thợ cắt tóc';
          });
        }
        return;
      }

      final dateStr = DateFormatter.toIsoDateString(_selectedDate);
      final rawBookedSlots = await ref
          .read(bookingRepositoryProvider)
          .getBookedSlotsForDate(widget.appointment.barberId, dateStr);

      // Cho phép chọn lại khung giờ của chính lịch hẹn này
      final effectiveBookedSlots = rawBookedSlots
          .where((s) => s.appointmentId != widget.appointment.id)
          .toList();

      const slotService = SlotService();
      final slots = slotService.generateAvailableSlots(
        barberProfile: _barberProfile!,
        selectedDate: _selectedDate,
        selectedService: ServiceModel(
          id: widget.appointment.serviceId,
          name: widget.appointment.serviceName,
          price: widget.appointment.price,
          durationMinutes: widget.appointment.durationMinutes,
        ),
        existingBookedSlots: effectiveBookedSlots,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _availableSlots = slots;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Lỗi tải danh sách khung giờ: $e';
        });
      }
    }
  }

  Future<void> _handleConfirmReschedule() async {
    if (_selectedSlot == null) return;

    final dateStr = DateFormatter.toIsoDateString(_selectedDate);
    final slotsCount =
        (widget.appointment.durationMinutes / BusinessConstants.slotMinutes)
            .ceil();

    final timeParts = _selectedSlot!.startTime.split(':');
    final startMin = int.parse(timeParts[0]) * 60 + int.parse(timeParts[1]);

    final newSlotIds = <String>[];
    for (int i = 0; i < slotsCount; i++) {
      final subMin = startMin + (i * BusinessConstants.slotMinutes);
      final h = (subMin ~/ 60).toString().padLeft(2, '0');
      final m = (subMin % 60).toString().padLeft(2, '0');
      newSlotIds.add(
        BookedSlotModel.generateSlotId(
          barberId: widget.appointment.barberId,
          date: dateStr,
          time: '$h:$m',
        ),
      );
    }

    final success = await ref
        .read(appointmentActionProvider.notifier)
        .rescheduleAppointment(
          appointmentId: widget.appointment.id,
          newDate: dateStr,
          newStartTime: _selectedSlot!.startTime,
          newEndTime: _selectedSlot!.endTime,
          newSlotIds: newSlotIds,
        );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      final actionState = ref.read(appointmentActionProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(actionState.errorMessage ?? 'Không thể đổi giờ hẹn!'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOptions = List.generate(
      BusinessConstants.maxBookingDaysAhead,
      (i) => today.add(Duration(days: i)),
    );

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: AppDimensions.sm),
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.lg,
              AppDimensions.sm,
              AppDimensions.sm,
              AppDimensions.xs,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.event_repeat_rounded,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: AppDimensions.sm),
                    const Text('Đổi Giờ Hẹn', style: AppTextStyles.h3),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Current Appointment Summary Info
          Container(
            margin: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
            padding: const EdgeInsets.all(AppDimensions.sm),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: AppDimensions.borderRadiusMd,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Hiện tại: ${widget.appointment.startTime}, ${widget.appointment.date} • ${widget.appointment.serviceName}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: AppDimensions.lg),

          // Date Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '1. Chọn ngày mới',
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.xs),
          SizedBox(
            height: 52,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
              scrollDirection: Axis.horizontal,
              itemCount: dateOptions.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final date = dateOptions[index];
                final isSelected = DateUtils.isSameDay(date, _selectedDate);
                final isCurrentDay = DateUtils.isSameDay(date, today);

                return ChoiceChip(
                  selected: isSelected,
                  selectedColor: AppColors.accent,
                  label: Text(
                    isCurrentDay
                        ? 'Hôm nay (${date.day}/${date.month})'
                        : '${_weekdayNames[date.weekday]} (${date.day}/${date.month})',
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                  onSelected: (selected) {
                    if (selected && !isSelected) {
                      setState(() {
                        _selectedDate = date;
                      });
                      _loadBarberAndSlots();
                    }
                  },
                );
              },
            ),
          ),

          const SizedBox(height: AppDimensions.md),

          // Time Slot Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '2. Chọn khung giờ mới (${widget.appointment.durationMinutes} phút)',
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.xs),

          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  )
                : _errorMessage != null
                ? Center(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  )
                : _availableSlots.isEmpty
                ? const Center(
                    child: Text(
                      'Không có khung giờ trống trong ngày này',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.lg,
                      vertical: AppDimensions.xs,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 2.2,
                        ),
                    itemCount: _availableSlots.length,
                    itemBuilder: (context, index) {
                      final slot = _availableSlots[index];
                      final isSelected =
                          _selectedSlot?.startTime == slot.startTime;

                      return InkWell(
                        onTap: slot.isAvailable
                            ? () {
                                setState(() {
                                  _selectedSlot = slot;
                                });
                              }
                            : null,
                        borderRadius: AppDimensions.borderRadiusSm,
                        child: Container(
                          decoration: BoxDecoration(
                            color: !slot.isAvailable
                                ? AppColors.inputBackground
                                : isSelected
                                ? AppColors.accent
                                : AppColors.surface,
                            borderRadius: AppDimensions.borderRadiusSm,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.accent
                                  : slot.isAvailable
                                  ? AppColors.divider
                                  : Colors.transparent,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                slot.startTime,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: !slot.isAvailable
                                      ? AppColors.textSecondary
                                      : isSelected
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                ),
                              ),
                              if (!slot.isAvailable)
                                Text(
                                  slot.unavailabilityReason ?? 'Bận',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Confirm button
          Padding(
            padding: const EdgeInsets.all(AppDimensions.lg),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppDimensions.borderRadiusMd,
                  ),
                ),
                icon: const Icon(Icons.check_circle_outline_rounded),
                label: Text(
                  _selectedSlot != null
                      ? 'Đổi sang ${_selectedSlot!.startTime} ngày ${_selectedDate.day}/${_selectedDate.month}'
                      : 'Vui lòng chọn khung giờ',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed:
                    _selectedSlot != null &&
                        ref.watch(appointmentActionProvider).isLoading == false
                    ? _handleConfirmReschedule
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// CreBy: MenBoyBMN
