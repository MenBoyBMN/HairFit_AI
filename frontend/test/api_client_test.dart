import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hairfit_ai/core/services/api_client.dart';
import 'package:hairfit_ai/features/admin/data/admin_repository.dart';
import 'package:hairfit_ai/features/booking/data/booking_repository.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('ApiClient & Backend Repository Integration Unit Tests', () {
    test(
      'ApiClient resolves custom baseUrl and parses JSON GET response',
      () async {
        final mockHttp = MockClient((request) async {
          expect(request.url.toString(), 'http://localhost:5000/api/health');
          expect(request.method, 'GET');
          return http.Response.bytes(
            utf8.encode(
              jsonEncode({'status': 'healthy', 'service': 'HairFit.Api'}),
            ),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        });

        final apiClient = ApiClient(
          httpClient: mockHttp,
          baseUrl: 'http://localhost:5000/',
        );

        expect(apiClient.baseUrl, 'http://localhost:5000');
        final res = await apiClient.get('/api/health');
        expect(res['status'], 'healthy');
        expect(res['service'], 'HairFit.Api');
      },
    );

    test('BookingRepository maps SLOT_ALREADY_BOOKED conflict to SlotAlreadyBookedException', () async {
      final mockHttp = MockClient((request) async {
        return http.Response.bytes(
          utf8.encode(
            jsonEncode({
              'code': 'SLOT_ALREADY_BOOKED',
              'slotId': 'barber_01_2026-11-01_09-00',
              'message': 'Khung giờ này vừa có người khác đặt.',
            }),
          ),
          409,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final repo = BookingRepository(
        apiClient: ApiClient(
          httpClient: mockHttp,
          baseUrl: 'http://localhost:5000',
        ),
      );

      expect(
        () => repo.createBooking(
          customerId: 'cust_1',
          customerName: 'Nguyễn Văn A',
          barberId: 'barber_01',
          barberName: 'HairFit Studio',
          serviceId: 'svc_01',
          serviceName: 'Cắt tóc',
          price: 80000,
          durationMinutes: 30,
          date: '2026-11-01',
          startTime: '09:00',
          endTime: '09:30',
          slotIds: ['barber_01_2026-11-01_09-00'],
        ),
        throwsA(isA<SlotAlreadyBookedException>()),
      );
    });

    test(
      'AdminRepository parses AdminDashboardStats from /api/admin/stats',
      () async {
        final mockHttp = MockClient((request) async {
          expect(request.url.path, '/api/admin/stats');
          return http.Response.bytes(
            utf8.encode(
              jsonEncode({
                'totalUsers': 15,
                'totalCustomers': 10,
                'totalBarbers': 4,
                'totalAdmins': 1,
                'approvedBarbers': 4,
                'completedAppointmentsToday': 3,
                'cancelledAppointmentsToday': 1,
                'revenueToday': 350000,
                'totalRevenue': 2500000,
                'totalHairstyles': 10,
              }),
            ),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        });

        final adminRepo = AdminRepository(
          null,
          ApiClient(httpClient: mockHttp, baseUrl: 'http://localhost:5000'),
        );

        final stats = await adminRepo.getDashboardStats();
        expect(stats.totalUsers, 15);
        expect(stats.totalBarbers, 4);
        expect(stats.revenueToday, 350000);
        expect(stats.completionRate, 75.0);
      },
    );

    test(
      'ApiClient.getCandidateUrls returns non-empty priority candidates',
      () {
        final candidates = ApiClient.getCandidateUrls();
        expect(candidates, isNotEmpty);
        expect(candidates.any((url) => url.contains('5000')), isTrue);
      },
    );

    test(
      'ApiClient.probe detects active endpoint and sets discoveredBaseUrl',
      () async {
        ApiClient.resetDiscoveredBaseUrl();

        final mockHttp = MockClient((request) async {
          if (request.url.path.contains('/health')) {
            return http.Response('{"status":"healthy"}', 200);
          }
          return http.Response('Not found', 404);
        });

        final detected = await ApiClient.probe(
          client: mockHttp,
          timeout: const Duration(milliseconds: 200),
        );

        expect(detected, isNotNull);
        expect(ApiClient.discoveredBaseUrl, detected);

        final client = ApiClient(httpClient: mockHttp);
        expect(client.baseUrl, detected);

        ApiClient.resetDiscoveredBaseUrl();
      },
    );

    test('ApiClient auto-failover switches to alive candidate when current endpoint fails', () async {
      ApiClient.resetDiscoveredBaseUrl();
      ApiClient.setDiscoveredBaseUrl('http://unreachable-host:9999');

      final mockHttp = MockClient((request) async {
        if (request.url.host == 'unreachable-host') {
          throw http.ClientException('Connection refused');
        }
        if (request.url.path == '/api/health' ||
            request.url.path == '/health') {
          return http.Response('{"status":"healthy"}', 200);
        }
        if (request.url.path == '/api/test') {
          return http.Response(jsonEncode({'success': true}), 200);
        }
        return http.Response('OK', 200);
      });

      final client = ApiClient(httpClient: mockHttp);
      final response = await client.get('/api/test');
      expect(response['success'], isTrue);
      expect(
        ApiClient.discoveredBaseUrl,
        isNot('http://unreachable-host:9999'),
      );

      ApiClient.resetDiscoveredBaseUrl();
    });
  });
}

// CreBy: MenBoyBMN
