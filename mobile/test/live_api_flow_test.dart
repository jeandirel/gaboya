// Real FastAPI -> PostgreSQL contract, enabled only in the isolated CI/local lab.
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:gaboya/services/gaboya_api.dart';

void main() {
  const enabled = bool.fromEnvironment('GABOYA_RUN_LIVE_TESTS');
  test('real OTP session, approved QR lookup and idempotent pending payment',
      () async {
    final api = GaboyaApi(
        baseUrl: 'http://127.0.0.1:8000',
        allowLocalHttp: true,
        store: MemorySessionStore());
    const inbox = String.fromEnvironment('GABOYA_TEST_SMS_DIR');
    const demoFile = String.fromEnvironment('GABOYA_DEMO_FILE');
    final demo = jsonDecode(await File(demoFile).readAsString());
    final otp = await api.requestOtp('+24177100999');
    expect(otp['delivery'], 'test_inbox');
    final code = await File('$inbox/${otp['challenge_id']}.txt').readAsString();
    await api.verifyOtp(otp['challenge_id'], code);
    await api.loadProfile();
    expect(api.roles, contains('passenger'));
    final driver = await api.resolveDriver(demo['driver_code']);
    expect(driver['driver_id'], demo['driver_id']);
    expect(driver['verified'], true);
    expect(driver['vehicle']['license_plate'], 'DEMO-GA-001');
    final key = GaboyaApi.newIdempotencyKey();
    final intent = await api.preparePayment(demo['driver_code'], 1000, key);
    final retry = await api.preparePayment(demo['driver_code'], 1000, key);
    expect(retry['id'], intent['id']);
    expect(intent['status'], 'pending');
    expect(intent['can_pay'], false);
    expect(intent['provider_confirmed'], false);
    await api.logout();
    expect(api.isSignedIn, false);
  }, skip: !enabled);
}
