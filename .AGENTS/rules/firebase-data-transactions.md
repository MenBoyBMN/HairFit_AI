# Firebase Data & Transaction Rules

## 1. Zero-Cost Free Tier Constraints
HairFit AI operates under Firebase Spark Free Tier limits:
- Max 50,000 document reads/day.
- Max 20,000 document writes/day.
- Max 20,000 document deletes/day.

### Mitigation Strategies:
1. **Denormalization**: Store frequently needed summary data directly in parent documents (e.g. `barberName`, `customerName`, `serviceName` directly in `appointments` collection rather than executing extra joins).
2. **Deterministic Document IDs**:
   - `booked_slots` IDs follow the pattern: `{barberId}_{YYYY-MM-DD}_{HH-mm}`.
   - This allows direct `doc.get()` lookups rather than scanning collections.
3. **Compound Queries & Composite Indexes**:
   - Avoid unbounded collection queries. Always apply `.limit(n)` on history/search queries.

## 2. Mandatory Firestore Transactions

Any operation that creates, shifts, or releases a timeslot MUST be executed within a transaction:

### A. New Booking (`BookingRepository.createAppointment`)
1. Read target `booked_slots` for all required time slots.
2. Verify none of them are currently booked or locked.
3. Read barber profile to confirm `isAcceptingBookingsToday == true` and working hours allow it.
4. Set `booked_slots` entries with `status: 'active'`.
5. Set `appointments` document.

### B. Rescheduling (`BookingRepository.rescheduleAppointment`)
1. In the same transaction:
   - Verify new slots are completely unreserved.
   - Delete/release the previous `booked_slots` documents.
   - Create new `booked_slots` documents.
   - Update appointment date, startTime, endTime, and slotIds.

### C. Cancellation (`AppointmentRepository.cancelAppointment`)
1. Mark appointment status as `cancelled`.
2. Delete corresponding `booked_slots` documents so the slot becomes instantly available for other clients.

## 3. Security Rules Alignment
Always verify that client-side Firestore queries conform to `firestore.rules`:
- Customers can only read/write their own user doc and appointments.
- Barbers can only modify their own profile, schedule exceptions, and assigned appointments.
- Admins (`role == 'admin'`) have full system visibility.
