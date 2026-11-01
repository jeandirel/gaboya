import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:gaboya/services/gaboya_api.dart';

Map<String, dynamic> session([String suffix = '1']) => {
      'access_token': 'test-access-$suffix',
      'refresh_token': 'test-refresh-$suffix',
      'user': {
        'id': 'passenger-test',
        'phone': '+24177123456',
        'roles': ['passenger']
      }
    };

http.Response jsonResponse(Object data, [int code = 200]) =>
    http.Response(jsonEncode(data), code,
        headers: {'content-type': 'application/json'});

GaboyaApi apiWith(http.Client client, [SessionStore? store]) => GaboyaApi(
    baseUrl: 'https://gaboya.example',
    client: client,
    store: store ?? MemorySessionStore());

void main() {
  test('OTP -> authenticated QR lookup -> pending payment with same retry key',
      () async {
    final calls = <http.Request>[];
    final store = MemorySessionStore();
    final api = apiWith(MockClient((request) async {
      calls.add(request);
      switch (request.url.path) {
        case '/v1/auth/otp/request':
          expect(jsonDecode(request.body)['phone'], '+24177123456');
          return jsonResponse(
              {'challenge_id': 'test-challenge', 'delivery': 'test_inbox'},
              202);
        case '/v1/auth/otp/verify':
          expect(jsonDecode(request.body)['code'], '123456');
          return jsonResponse(session());
        case '/v1/drivers/resolve/GBY-1234ABCD':
          expect(request.headers['Authorization'], 'Bearer test-access-1');
          return jsonResponse({
            'verified': true,
            'display_name': 'Chauffeur test',
            'vehicle': {
              'license_plate': 'TEST-001',
              'description': 'Toyota verte'
            }
          });
        case '/v1/payments/intents':
          expect(request.headers['Idempotency-Key'], 'same-key-on-every-retry');
          expect(jsonDecode(request.body)['amount_xaf'], isA<int>());
          return jsonResponse({
            'id': 'intent-test',
            'status': 'pending',
            'can_pay': false,
            'provider_confirmed': false
          }, 201);
        default:
          throw StateError(request.url.toString());
      }
    }), store);
    final challenge = await api.requestOtp('+24177123456');
    await api.verifyOtp(challenge['challenge_id'], '123456');
    expect(api.isSignedIn, true);
    expect(await store.read(), 'test-refresh-1');
    expect((await api.resolveDriver('GBY-1234ABCD'))['verified'], true);
    final intent = await api.preparePayment(
        'GBY-1234ABCD', 1000, 'same-key-on-every-retry');
    expect(intent['status'], 'pending');
    expect(intent['provider_confirmed'], false);
    await api.preparePayment('GBY-1234ABCD', 1000, 'same-key-on-every-retry');
    expect(calls.length, 5);
  });

  test('reject QR URLs before making a network request', () async {
    var calls = 0;
    final api = apiWith(MockClient((_) async {
      calls++;
      return jsonResponse({});
    }));
    await expectLater(
        api.resolveDriver('https://untrusted.example/GBY-1234ABCD'),
        throwsA(isA<ApiException>()));
    expect(calls, 0);
  });

  test('expired access refreshes once and stores rotated refresh token',
      () async {
    var refreshCalls = 0;
    final store = MemorySessionStore();
    final api = apiWith(MockClient((request) async {
      if (request.url.path.endsWith('/verify')) return jsonResponse(session());
      if (request.url.path.endsWith('/refresh')) {
        refreshCalls++;
        return jsonResponse(session('2'));
      }
      if (request.headers['Authorization'] == 'Bearer test-access-1') {
        return jsonResponse({'detail': 'Expired'}, 401);
      }
      return jsonResponse(session()['user']);
    }), store);
    await api.verifyOtp('test', '123456');
    await api.loadProfile();
    expect(refreshCalls, 1);
    expect(await store.read(), 'test-refresh-2');
  });

  test('refresh rejection clears session and secure storage', () async {
    final store = MemorySessionStore();
    await store.write('revoked-refresh');
    final api = apiWith(
        MockClient((_) async => jsonResponse({'detail': 'Revoked'}, 401)),
        store);
    await api.restore();
    expect(api.isSignedIn, false);
    expect(await store.read(), null);
  });

  test('unverified or unavailable driver cannot reach payment preparation',
      () async {
    final api = apiWith(MockClient((request) async =>
        request.url.path.endsWith('/verify')
            ? jsonResponse(session())
            : jsonResponse({'verified': false, 'vehicle': null})));
    await api.verifyOtp('test', '123456');
    await expectLater(
        api.resolveDriver('GBY-1234ABCD'), throwsA(isA<ApiException>()));
  });

  test('HTTP is rejected unless explicitly local in a debug build', () async {
    var calls = 0;
    final client = MockClient((_) async {
      calls++;
      return jsonResponse({});
    });
    final api = GaboyaApi(
        baseUrl: 'http://remote.example',
        client: client,
        store: MemorySessionStore(),
        allowLocalHttp: true);
    await expectLater(
        api.requestOtp('+24177123456'), throwsA(isA<ApiException>()));
    expect(calls, 0);
  });

  test('logout clears local session even if server is temporarily unavailable',
      () async {
    final store = MemorySessionStore();
    final api = apiWith(
        MockClient((request) async => request.url.path.endsWith('/verify')
            ? jsonResponse(session())
            : jsonResponse({'detail': 'Unavailable'}, 503)),
        store);
    await api.verifyOtp('test', '123456');
    await expectLater(api.logout(), throwsA(isA<ApiException>()));
    expect(api.isSignedIn, false);
    expect(await store.read(), null);
  });
}
