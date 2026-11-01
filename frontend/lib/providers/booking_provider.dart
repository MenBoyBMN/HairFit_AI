// ============================================================================
// File: lib/providers/booking_provider.dart
// Mục đích: Quản lý trạng thái (State Management) cho booking.
// Kết cấu:
//  - Sử dụng Riverpod (Notifier/StateNotifier/Provider) để cung cấp trạng thái và xử lý logic nghiệp vụ.
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/date_formatter.dart';
import '../features/booking/data/booking_repository.dart';
import '../features/booking/data/slot_service.dart';
import '../models/barber_profile_model.dart';
import '../models/promotion_model.dart';
import '../models/service_model.dart';
import '../models/user_model.dart';
import 'app_providers.dart';

/// Provider cung cấp instance của SlotService
final slotServiceProvider = Provider<SlotService>((ref) {
  return const SlotService();
});

/// Provider cung cấp instance của BookingRepository
final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return BookingRepository(firestore: firestore);
});

/// Trạng thái của luồng đặt lịch hẹn (Booking Flow State)
class BookingState {
  final ServiceModel? selectedService;
  final DateTime selectedDate;
  final List<AvailableSlot> availableSlots;
  final AvailableSlot? selectedSlot;
  final String note;
  final String hairstyleId;
  final String? customerFaceShape;
  final String? aiStylingTip;
  final String? hairstyleImageUrl;
  final String? customerPhone;
  final String? barberPhone;
  final PromotionModel? appliedPromotion;
  final int discountAmount;
  final bool isLoadingSlots;
  final bool isSubmitting;
  final String? errorMessage;
  final String? bookedAppointmentId;

  BookingState({
    this.selectedService,
    DateTime? selectedDate,
    this.availableSlots = const [],
    this.selectedSlot,
    this.note = '',
    this.hairstyleId = '',
    this.customerFaceShape,
    this.aiStylingTip,
    this.hairstyleImageUrl,
    this.customerPhone,
    this.barberPhone,
    this.appliedPromotion,
    this.discountAmount = 0,
    this.isLoadingSlots = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.bookedAppointmentId,
  }) : selectedDate = selectedDate ?? DateTime.now();

  int get finalPrice {
    final original = selectedService?.price ?? 0;
    return (original - discountAmount).clamp(0, original);
  }

  BookingState copyWith({
    ServiceModel? selectedService,
    DateTime? selectedDate,
    List<AvailableSlot>? availableSlots,
    AvailableSlot? selectedSlot,
    bool clearSelectedSlot = false,
    String? note,
    String? hairstyleId,
    String? customerFaceShape,
    String? aiStylingTip,
    String? hairstyleImageUrl,
    String? customerPhone,
    String? barberPhone,
    PromotionModel? appliedPromotion,
    bool clearPromotion = false,
    int? discountAmount,
    bool? isLoadingSlots,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
    String? bookedAppointmentId,
  }) {
    return BookingState(
      selectedService: selectedService ?? this.selectedService,
      selectedDate: selectedDate ?? this.selectedDate,
      availableSlots: availableSlots ?? this.availableSlots,
      selectedSlot: clearSelectedSlot
          ? null
          : (selectedSlot ?? this.selectedSlot),
      note: note ?? this.note,
      hairstyleId: hairstyleId ?? this.hairstyleId,
      customerFaceShape: customerFaceShape ?? this.customerFaceShape,
      aiStylingTip: aiStylingTip ?? this.aiStylingTip,
      hairstyleImageUrl: hairstyleImageUrl ?? this.hairstyleImageUrl,
      customerPhone: customerPhone ?? this.customerPhone,
      barberPhone: barberPhone ?? this.barberPhone,
      appliedPromotion: clearPromotion
          ? null
          : (appliedPromotion ?? this.appliedPromotion),
      discountAmount: clearPromotion
          ? 0
          : (discountAmount ?? this.discountAmount),
      isLoadingSlots: isLoadingSlots ?? this.isLoadingSlots,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      bookedAppointmentId: bookedAppointmentId ?? this.bookedAppointmentId,
    );
  }

  /// Kiểm tra xem thông tin đã đủ để xác nhận đặt lịch chưa
  bool get canSubmit =>
      selectedService != null &&
      selectedSlot != null &&
      selectedSlot!.isAvailable &&
      !isSubmitting;
}

/// Notifier quản lý toàn bộ logic luồng đặt lịch (Task 4.6)
class BookingNotifier extends StateNotifier<BookingState> {
  final SlotService slotService;
  final BookingRepository bookingRepository;

  BookingNotifier({required this.slotService, required this.bookingRepository})
    : super(BookingState());

  /// Khởi tạo trạng thái ban đầu cho màn hình đặt lịch của thợ
  void initialize({
    required BarberProfileModel barber,
    ServiceModel? preselectedService,
    String? hairstyleId,
    String? customerFaceShape,
    String? aiStylingTip,
    String? hairstyleImageUrl,
    String? customerPhone,
    String? barberPhone,
    DateTime? initialDate,
  }) {
    final now = DateTime.now();
    final date = initialDate ?? DateTime(now.year, now.month, now.day);

    ServiceModel? service = preselectedService;
    if (service == null && barber.services.isNotEmpty) {
      service = barber.services.first;
    }

    state = BookingState(
      selectedService: service,
      selectedDate: date,
      hairstyleId: hairstyleId ?? '',
      customerFaceShape: customerFaceShape,
      aiStylingTip: aiStylingTip,
      hairstyleImageUrl: hairstyleImageUrl,
      customerPhone: customerPhone,
      barberPhone: barberPhone ?? barber.phone,
      isLoadingSlots: true,
    );

    loadSlots(barber: barber);
  }

  /// Chọn dịch vụ khác
  void selectService(ServiceModel service, BarberProfileModel barber) {
    if (state.selectedService?.id == service.id) return;
    state = state.copyWith(
      selectedService: service,
      clearSelectedSlot: true,
      isLoadingSlots: true,
      clearError: true,
    );
    loadSlots(barber: barber);
  }

  /// Chọn ngày khác
  void selectDate(DateTime date, BarberProfileModel barber) {
    final normalized = DateTime(date.year, date.month, date.day);
    state = state.copyWith(
      selectedDate: normalized,
      clearSelectedSlot: true,
      isLoadingSlots: true,
      clearError: true,
    );
    loadSlots(barber: barber);
  }

  /// Chọn khung giờ
  void selectSlot(AvailableSlot slot) {
    if (!slot.isAvailable) return;
    state = state.copyWith(selectedSlot: slot, clearError: true);
  }

  /// Nhập ghi chú
  void setNote(String note) {
    state = state.copyWith(note: note);
  }

  /// Tải danh sách slot khả dụng từ Firestore và SlotService
  Future<void> loadSlots({
    required BarberProfileModel barber,
    bool preserveError = false,
  }) async {
    final service = state.selectedService;
    if (service == null) {
      state = state.copyWith(availableSlots: [], isLoadingSlots: false);
      return;
    }

    final currentError = preserveError ? state.errorMessage : null;
    state = state.copyWith(
      isLoadingSlots: true,
      clearError: !preserveError,
      errorMessage: currentError,
    );

    try {
      final dateStr = DateFormatter.toIsoDateString(state.selectedDate);
      final bookedSlots = await bookingRepository.getBookedSlotsForDate(
        barber.uid,
        dateStr,
      );

      final available = slotService.generateAvailableSlots(
        barberProfile: barber,
        selectedDate: state.selectedDate,
        selectedService: service,
        existingBookedSlots: bookedSlots,
      );

      // Nếu slot đang chọn vẫn hợp lệ trong danh sách mới thì giữ nguyên, ngược lại xóa
      AvailableSlot? newSelectedSlot;
      if (state.selectedSlot != null) {
        final found = available.where(
          (s) => s.startTime == state.selectedSlot!.startTime,
        );
        if (found.isNotEmpty && found.first.isAvailable) {
          newSelectedSlot = found.first;
        }
      }

      state = state.copyWith(
        availableSlots: available,
        selectedSlot: newSelectedSlot,
        clearSelectedSlot: newSelectedSlot == null,
        isLoadingSlots: false,
        errorMessage: currentError,
      );
    } catch (e) {
      state = state.copyWith(
        availableSlots: [],
        isLoadingSlots: false,
        errorMessage: 'Lỗi tải khung giờ: ${e.toString()}',
      );
    }
  }

  /// Áp dụng mã giảm giá / Giờ vàng Happy Hour
  bool applyPromotion(PromotionModel promo) {
    final service = state.selectedService;
    final slot = state.selectedSlot;
    if (service == null || slot == null) {
      state = state.copyWith(
        errorMessage: 'Vui lòng chọn dịch vụ và khung giờ trước khi dùng mã!',
      );
      return false;
    }

    final dateStr = DateFormatter.toIsoDateString(state.selectedDate);
    final isValid = promo.isApplicableForSlot(
      orderPrice: service.price,
      time: slot.startTime,
      dateIso: dateStr,
      now: DateTime.now(),
    );

    if (!isValid) {
      state = state.copyWith(
        errorMessage:
            'Mã ${promo.code} không áp dụng cho khung giờ hoặc ngày này!',
      );
      return false;
    }

    final discount = promo.calculateDiscount(service.price);
    state = state.copyWith(
      appliedPromotion: promo,
      discountAmount: discount,
      clearError: true,
    );
    return true;
  }

  /// Hủy áp dụng mã giảm giá
  void removePromotion() {
    state = state.copyWith(clearPromotion: true, clearError: true);
  }

  /// Xác nhận tạo lịch hẹn (Atomic Transaction)
  Future<bool> submitBooking({
    required UserModel customer,
    required BarberProfileModel barber,
  }) async {
    if (state.selectedService == null) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Vui lòng chọn dịch vụ cắt tóc trước khi xác nhận!',
      );
      return false;
    }

    if (state.selectedSlot == null) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage:
            'Vui lòng chọn một khung giờ hẹn trống ở Bước 3 trước khi bấm xác nhận!',
      );
      return false;
    }

    if (!state.selectedSlot!.isAvailable) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage:
            'Khung giờ bạn chọn đã kín lịch. Vui lòng chọn khung giờ khác!',
      );
      return false;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final service = state.selectedService!;
      final slot = state.selectedSlot!;
      final dateStr = DateFormatter.toIsoDateString(state.selectedDate);

      final appointmentId = await bookingRepository.createBooking(
        customerId: customer.uid,
        customerName: customer.displayName.isNotEmpty
            ? customer.displayName
            : customer.email.split('@').first,
        barberId: barber.uid,
        barberName: barber.displayName,
        serviceId: service.id,
        serviceName: service.name,
        price: service.price,
        durationMinutes: service.durationMinutes,
        date: dateStr,
        startTime: slot.startTime,
        endTime: slot.endTime,
        slotIds: slot.slotIds,
        hairstyleId: state.hairstyleId,
        customerFaceShape: state.customerFaceShape ?? customer.savedFaceShape,
        aiStylingTip: state.aiStylingTip,
        hairstyleImageUrl: state.hairstyleImageUrl,
        customerPhone: state.customerPhone ?? customer.phone,
        barberPhone: state.barberPhone ?? barber.phone,
        note: state.note,
        promoCode: state.appliedPromotion?.code ?? '',
        discountAmount: state.discountAmount,
      );

      state = state.copyWith(
        isSubmitting: false,
        bookedAppointmentId: appointmentId,
      );
      return true;
    } on BookingException catch (e) {
      final errorMsg = e.message;
      await loadSlots(barber: barber, preserveError: true);
      state = state.copyWith(isSubmitting: false, errorMessage: errorMsg);
      return false;
    } catch (e) {
      final errorMsg = 'Đã có lỗi xảy ra: ${e.toString()}';
      await loadSlots(barber: barber, preserveError: true);
      state = state.copyWith(isSubmitting: false, errorMessage: errorMsg);
      return false;
    }
  }
}

/// Provider quản lý StateNotifier cho luồng đặt lịch
final bookingNotifierProvider =
    StateNotifierProvider.autoDispose<BookingNotifier, BookingState>((ref) {
      final slotService = ref.watch(slotServiceProvider);
      final bookingRepo = ref.watch(bookingRepositoryProvider);
      return BookingNotifier(
        slotService: slotService,
        bookingRepository: bookingRepo,
      );
    });

// CreBy: MenBoyBMN
