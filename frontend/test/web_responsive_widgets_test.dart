import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hairfit_ai/core/utils/platform_helper.dart';
import 'package:hairfit_ai/core/widgets/antigravity_card.dart';
import 'package:hairfit_ai/core/widgets/staggered_reveal.dart';
import 'package:hairfit_ai/core/widgets/web_nav_shell.dart';

void main() {
  group('Web & Desktop Antigravity UI Components Test', () {
    testWidgets('PlatformHelper detects desktop and mobile breakpoints', (
      tester,
    ) async {
      late bool isDesktopResult;
      late int columnsResult;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(1280, 800)),
            child: Builder(
              builder: (context) {
                isDesktopResult = PlatformHelper.isDesktopLayout(context);
                columnsResult = PlatformHelper.getResponsiveGridColumns(
                  context,
                );
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(isDesktopResult, isTrue);
      expect(columnsResult, equals(3));
    });

    testWidgets('AntigravityCard renders child and handles tap', (
      tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AntigravityCard(
              onTap: () => tapped = true,
              child: const Text('Floating Salon Card'),
            ),
          ),
        ),
      );

      expect(find.text('Floating Salon Card'), findsOneWidget);
      await tester.tap(find.text('Floating Salon Card'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets('StaggeredReveal animates child entrance cleanly', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StaggeredReveal(index: 2, child: Text('Staggered Item')),
          ),
        ),
      );

      expect(find.text('Staggered Item'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('Staggered Item'), findsOneWidget);
    });

    testWidgets('WebTopNavBar renders Customer and Barber navigation items', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1280, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              appBar: WebTopNavBar(currentRoute: '/customer/home'),
              body: SizedBox(),
            ),
          ),
        ),
      );

      expect(find.text('HairFit AI'), findsOneWidget);
      expect(find.text('Trang chủ'), findsOneWidget);
      expect(find.text('Bản đồ & Salon'), findsOneWidget);
      expect(find.text('Tư vấn Kiểu tóc'), findsOneWidget);
    });
  });
}

// CreBy: MenBoyBMN
