import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

abstract class SessionStore {
  Future<String?> read();
  Future<void> write(String? token);
}

class MemorySessionStore implements SessionStore {
  String? _token;
  @override
  Future<String?> read() async => _token;
  @override
  Future<void> write(String? token) async {
    _token = token;
  }
}

class SecureSessionStore implements SessionStore {
  static const _storage = FlutterSecureStorage();
  static const _key = 'gaboya_refresh_token';
  @override
  Future<String?> read() => _storage.read(key: _key);
  @override
  Future<void> write(String? token) => token == null
      ? _storage.delete(key: _key)
      : _storage.write(key: _key, value: token);
}

class ApiException implements Exception {
  ApiException(this.message, [this.statusCode = 0]);
  final String message;
  final int statusCode;
  @override
  String toString() => message;
}

class GaboyaApi extends ChangeNotifier {
  GaboyaApi(
      {String? baseUrl,
      http.Client? client,
      SessionStore? store,
      bool? allowLocalHttp})
      : baseUrl =
            baseUrl ?? const String.fromEnvironment('GABOYA_API_BASE_URL'),
        _client = client ?? http.Client(),
        _store =
            store ?? (kIsWeb ? MemorySessionStore() : SecureSessionStore()),
        _allowLocalHttp = allowLocalHttp ??
            (!kReleaseMode &&
                const bool.fromEnvironment('GABOYA_ALLOW_LOCAL_HTTP'));

  static final instance = GaboyaApi();
  final String baseUrl;
  final http.Client _client;
  final SessionStore _store;
  final bool _allowLocalHttp;
  String? _accessToken;
  String? _refreshToken;
  Future<void>? _refreshing;
  Map<String, dynamic>? user;
  bool get isSignedIn => user != null;
  List<String> get roles => List<String>.from(user?['roles'] ?? []);

  Uri _uri(String path) {
    final uri = Uri.tryParse(baseUrl);
    const localHosts = ['localhost', '127.0.0.1', '10.0.2.2', '::1'];
    if (uri == null ||
        !uri.hasAuthority ||
        uri.userInfo.isNotEmpty ||
        uri.query.isNotEmpty ||
        uri.fragment.isNotEmpty ||
        (uri.scheme != 'https' &&
            !(_allowLocalHttp &&
                !kReleaseMode &&
                uri.scheme == 'http' &&
                localHosts.contains(uri.host)))) {
      throw ApiException('Adresse s�curis�e de l�API GABOYA non configur�e.');
    }
    return Uri.parse('${baseUrl.replaceAll(RegExp(r"/+$"), "")}$path');
  }

  Future<dynamic> _request(String method, String path,
      {Map<String, dynamic>? body,
      bool auth = true,
      Map<String, String> headers = const {},
      bool retry = true}) async {
    if (auth && _accessToken == null) {
      throw ApiException('Connectez-vous pour continuer.', 401);
    }
    try {
      final request = http.Request(method, _uri(path));
      request.headers.addAll({
        'Content-Type': 'application/json',
        ...headers,
        if (auth) 'Authorization': 'Bearer $_accessToken'
      });
      if (body != null) request.body = jsonEncode(body);
      final response = await http.Response.fromStream(
          await _client.send(request).timeout(const Duration(seconds: 20)));
      if (response.statusCode == 401 &&
          auth &&
          retry &&
          _refreshToken != null) {
        await _refresh();
        return _request(method, path,
            body: body, auth: auth, headers: headers, retry: false);
      }
      dynamic data;
      try {
        data = response.body.isEmpty
            ? null
            : jsonDecode(utf8.decode(response.bodyBytes));
      } on FormatException {
        throw ApiException(
            'R�ponse du serveur illisible.', response.statusCode);
      }
      if (response.statusCode >= 400) {
        if (response.statusCode == 401 && auth) await _clearSession();
        final detail = data is Map ? data['detail'] : null;
        throw ApiException(
            detail is String ? detail : 'V�rifiez les informations saisies.',
            response.statusCode);
      }
      return data;
    } on TimeoutException {
      throw ApiException('Le serveur ne r�pond pas. R�essayez.');
    } on http.ClientException {
      throw ApiException('Connexion au serveur impossible.');
    }
  }

  Future<void> restore() async {
    _refreshToken = await _store.read();
    if (_refreshToken != null) {
      try {
        await _refresh();
      } on ApiException {/* Login remains available. */}
    }
  }

  Future<void> _saveSession(Map<String, dynamic> data) async {
    // Persist refresh first; never store access tokens in shared_preferences.
    await _store.write(data['refresh_token'] as String);
    _refreshToken = data['refresh_token'] as String;
    _accessToken = data['access_token'] as String;
    user = Map<String, dynamic>.from(data['user']);
    notifyListeners();
  }

  Future<void> _clearSession() async {
    _accessToken = null;
    _refreshToken = null;
    user = null;
    await _store.write(null);
    notifyListeners();
  }

  Future<void> _refresh() async {
    if (_refreshing != null) return _refreshing!;
    final future = _refreshOnce();
    _refreshing = future;
    try {
      await future;
    } finally {
      _refreshing = null;
    }
  }

  Future<void> _refreshOnce() async {
    try {
      final data = await _request('POST', '/v1/auth/refresh',
          auth: false, body: {'refresh_token': _refreshToken});
      await _saveSession(Map<String, dynamic>.from(data));
    } on ApiException catch (error) {
      if (error.statusCode == 401) await _clearSession();
      rethrow;
    }
  }

  Future<Map<String, dynamic>> requestOtp(String phone) async =>
      Map<String, dynamic>.from(await _request('POST', '/v1/auth/otp/request',
          auth: false, body: {'phone': phone}));

  Future<void> verifyOtp(String challengeId, String code) async {
    final data = await _request('POST', '/v1/auth/otp/verify',
        auth: false, body: {'challenge_id': challengeId, 'code': code});
    await _saveSession(Map<String, dynamic>.from(data));
  }

  Future<void> loadProfile() async {
    user = Map<String, dynamic>.from(await _request('GET', '/v1/me'));
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      await _request('POST', '/v1/auth/logout');
    } finally {
      await _clearSession();
    }
  }

  static String driverCode(String scanned) {
    final code = scanned.trim().toUpperCase();
    if (!RegExp(r'^GBY-[A-Z0-9]{4,16}$').hasMatch(code)) {
      throw ApiException(
          'Ce QR code n�est pas un identifiant chauffeur GABOYA.');
    }
    return code;
  }

  Future<Map<String, dynamic>> resolveDriver(String scanned) async {
    final code = driverCode(scanned);
    final driver = Map<String, dynamic>.from(
        await _request('GET', '/v1/drivers/resolve/$code'));
    if (driver['verified'] != true || driver['vehicle'] == null) {
      throw ApiException('Chauffeur non disponible.');
    }
    return driver;
  }

  static String newIdempotencyKey() => List.generate(24,
          (_) => Random.secure().nextInt(256).toRadixString(16).padLeft(2, '0'))
      .join();

  Future<Map<String, dynamic>> preparePayment(
          String code, int amount, String key) async =>
      Map<String, dynamic>.from(await _request('POST', '/v1/payments/intents',
          body: {'driver_code': driverCode(code), 'amount_xaf': amount},
          headers: {'Idempotency-Key': key}));

  Future<Map<String, dynamic>?> myDriver() async {
    try {
      return Map<String, dynamic>.from(await _request('GET', '/v1/drivers/me'));
    } on ApiException catch (error) {
      if (error.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<Map<String, dynamic>> saveDriver(
          String name, String plate, String description,
          {bool update = false}) async =>
      Map<String, dynamic>.from(await _request(
          update ? 'PUT' : 'POST', update ? '/v1/drivers/me' : '/v1/drivers',
          body: {
            'display_name': name,
            'vehicle': {'license_plate': plate, 'description': description}
          }));

  Future<List<Map<String, dynamic>>> reviewQueue() async =>
      (await _request('GET', '/v1/admin/drivers') as List)
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

  Future<void> reviewDriver(String id, String status, String note) async {
    await _request('POST', '/v1/admin/drivers/$id/review',
        body: {'status': status, 'note': note});
  }
}
