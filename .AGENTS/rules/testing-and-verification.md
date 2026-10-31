# Testing & Quality Verification Rules

## 1. Quality Invariants
No feature branch, pull request, or commit is acceptable unless:
1. `flutter analyze` passes with **0 issues found**.
2. `flutter test` executes with **100% passing tests**.

## 2. Widget Test Best Practices

### A. Provider Overrides
In widget tests, never permit direct Firebase Auth, Firestore, or Camera initialization. Always isolate widgets using `ProviderScope.overrides`:
```dart
testWidgets('Screen renders correctly', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authStateProvider.overrideWith((ref) => Stream.value(mockUser)),
        currentBarberProfileStreamProvider.overrideWith((ref) => Stream.value(mockBarber)),
        barberAppointmentsProvider.overrideWith((ref) => Stream.value([mockAppointment])),
      ],
      child: const MaterialApp(home: BarberAppointmentsScreen()),
    ),
  );
  await tester.pumpAndSettle();
  expect(find.byType(AppointmentCard), findsOneWidget);
});
```

### B. Viewport & Scrolling
Default Flutter test screen resolution is 800x600. When testing screens containing headers, statistics cards, and long lists:
- Enlarge the test physical surface to avoid offscreen lazy-loading dropping target widgets:
  ```dart
  tester.view.physicalSize = const Size(1200, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  ```
- Or use `tester.scrollUntilVisible(...)` / `skipOffstage: false`.

### C. Shimmer & Animation Handling
- For widgets using `Shimmer` or infinite pulsing animations, avoid indefinite timeouts with `pumpAndSettle()`.
- Use targeted `tester.pump(const Duration(milliseconds: 300))` or settle finite animations.
