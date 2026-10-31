# Riverpod State Management Rules

## 1. Provider Naming & Organization
- Global and shared feature providers reside in `lib/providers/`.
- Repositories are exposed via `Provider<T>`:
  ```dart
  final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
    return BookingRepository(firestore: FirebaseFirestore.instance);
  });
  ```
- Async data streams from Firestore are exposed via `StreamProvider<T>` or `StreamProvider.autoDispose<T>`:
  ```dart
  final barberAppointmentsProvider = StreamProvider.autoDispose<List<AppointmentModel>>((ref) {
    final user = ref.watch(authStateProvider).value;
    if (user == null) return const Stream.empty();
    return ref.watch(appointmentRepositoryProvider).streamBarberAppointments(user.uid);
  });
  ```

## 2. StateNotifier & UI Interaction
- Complex mutable state (e.g. search filters, booking steps, appointment actions) must use `StateNotifier<T>` or `AsyncNotifier<T>`.
- In Flutter widgets:
  - **`ref.watch()`**: Only inside `build()` method to subscribe to state changes.
  - **`ref.read()`**: Inside user event callbacks (e.g. `onPressed`, `onTap`), never directly in `build()`.
  - **`ref.listen()`**: For one-off side effects like showing `SnackBar`, navigating via GoRouter, or popping dialogs.

## 3. Testability Rules
- Every provider consumed by UI widgets must be mockable or overridable using `overrides` in `ProviderScope`:
  ```dart
  createTestWidget({
    List<Override> overrides = const [],
  }) {
    return ProviderScope(
      overrides: [
        authStateProvider.overrideWith((ref) => Stream.value(sampleUser)),
        ...overrides,
      ],
      child: const MaterialApp(home: TargetScreen()),
    );
  }
  ```
- Never create unmanaged static singletons that bypass Riverpod injection.
