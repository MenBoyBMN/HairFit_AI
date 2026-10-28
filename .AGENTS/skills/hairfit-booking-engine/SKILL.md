---
name: hairfit-booking-engine
description: Understand, maintain, and extend the HairFit AI appointment booking and slot calculation engine with zero-cost atomic concurrency protection.
risk: medium
source: workspace
---

# HairFit AI - Booking & Scheduling Engine

## 1. Architectural Overview

The booking engine coordinates appointment reservation without running an expensive Node.js/Cloud Function backend. All concurrency guarantees are upheld via **Firestore Transactions** and **Deterministic Document Locking**.

### Relevant Code Locations:
- `lib/features/booking/data/slot_service.dart`: Working hours parser, day key mapping, slot chunk generation.
- `lib/features/booking/data/booking_repository.dart`: Atomic booking creation, slot blocking, rescheduling.
- `lib/features/appointments/data/appointment_repository.dart`: Appointment status updates, cancel & slot release, barber notes.
- `lib/models/booked_slot_model.dart`: Slot reservation schema.

---

## 2. Slot Calculation Invariants

1. **Deterministic Slot Key Format**:
   ```
   {barberId}_{YYYY-MM-DD}_{HH-mm}
   ```
   Example: `barber_abc123_2026-10-15_14-30`

2. **Buffer & Multi-Slot Services**:
   - A service with `durationMinutes = 60` and standard `slotDuration = 30` requires **2 consecutive slots**.
   - If ANY of the required consecutive slots is booked or locked, the starting time is considered **unavailable**.

3. **Shop Status Checks**:
   - Daily schedule check: `barber.workingHours[weekdayKey]`.
   - Special holiday/exception check: `barber.exceptions`.
   - Emergency pause check: `barber.isAcceptingBookingsToday == false` blocks all same-day bookings.

---

## 3. Transaction Workflow Reference

### A. Atomic Booking Reservation
```dart
await firestore.runTransaction((transaction) async {
  // 1. Read all required slot docs
  for (final slotId in slotIds) {
    final slotDoc = await transaction.get(slotsRef.doc(slotId));
    if (slotDoc.exists) {
      throw SlotAlreadyBookedException('Slot $slotId is already booked.');
    }
  }

  // 2. Lock slots
  for (final slotId in slotIds) {
    transaction.set(slotsRef.doc(slotId), {
      'barberId': barberId,
      'date': date,
      'time': time,
      'status': 'active',
      'appointmentId': appointmentId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 3. Write appointment document
  transaction.set(appointmentsRef.doc(appointmentId), appointment.toMap());
});
```

### B. Rescheduling
1. Check availability of all new slots.
2. In the same transaction:
   - Delete previous slot documents in `booked_slots`.
   - Create new slot documents in `booked_slots`.
   - Update appointment date, start time, end time, and slotIds.

### C. Break / Emergency Blocking
Thợ có thể chủ động khóa một slot trong ngày với type `'break'` qua `BookingRepository.blockSlotForBreak()`. Khách hàng sẽ thấy khung giờ đó đã bị chiếm chỗ.
