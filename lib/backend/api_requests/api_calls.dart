import 'dart:convert';
import 'dart:typed_data';
import '../schema/structs/index.dart';

import 'package:flutter/foundation.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';

export 'api_manager.dart' show ApiCallResponse;

const _kPrivateApiFunctionName = 'ffPrivateApiCall';

/// Start GaboyaApi Group Code

class GaboyaApiGroup {
  static String getBaseUrl() => 'https://gaboya-geo-api.onrender.com';
  static Map<String, String> headers = {};
  static ResolveDriverCall resolveDriverCall = ResolveDriverCall();
  static CapabilitiesCall capabilitiesCall = CapabilitiesCall();
  static ProvincesCall provincesCall = ProvincesCall();
  static CitiesCall citiesCall = CitiesCall();
  static TransportPointsCall transportPointsCall = TransportPointsCall();
  static CoverageCall coverageCall = CoverageCall();
}

class ResolveDriverCall {
  Future<ApiCallResponse> call({
    String? code = 'GBY-TEST01',
  }) async {
    final baseUrl = GaboyaApiGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'ResolveDriver',
      apiUrl: '${baseUrl}v1/drivers/resolve/${code}',
      callType: ApiCallType.GET,
      headers: {},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class CapabilitiesCall {
  Future<ApiCallResponse> call() async {
    final baseUrl = GaboyaApiGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Capabilities',
      apiUrl: '${baseUrl}v1/capabilities',
      callType: ApiCallType.GET,
      headers: {},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class ProvincesCall {
  Future<ApiCallResponse> call() async {
    final baseUrl = GaboyaApiGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Provinces',
      apiUrl: '${baseUrl}v1/geo/provinces',
      callType: ApiCallType.GET,
      headers: {},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class CitiesCall {
  Future<ApiCallResponse> call({
    int? provinceId = 1,
  }) async {
    final baseUrl = GaboyaApiGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Cities',
      apiUrl: '${baseUrl}v1/geo/cities',
      callType: ApiCallType.GET,
      headers: {},
      params: {
        'province_id': "${provinceId}",
        'available_only': "false",
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class TransportPointsCall {
  Future<ApiCallResponse> call({
    int? cityId = 1,
  }) async {
    final baseUrl = GaboyaApiGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'TransportPoints',
      apiUrl: '${baseUrl}v1/geo/transport-points',
      callType: ApiCallType.GET,
      headers: {},
      params: {
        'city_id': "${cityId}",
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

class CoverageCall {
  Future<ApiCallResponse> call() async {
    final baseUrl = GaboyaApiGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Coverage',
      apiUrl: '${baseUrl}v1/geo/coverage',
      callType: ApiCallType.GET,
      headers: {},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

/// End GaboyaApi Group Code

class ApiPagingParams {
  int nextPageNumber = 0;
  int numItems = 0;
  dynamic lastResponse;

  ApiPagingParams({
    required this.nextPageNumber,
    required this.numItems,
    required this.lastResponse,
  });

  @override
  String toString() =>
      'PagingParams(nextPageNumber: $nextPageNumber, numItems: $numItems, lastResponse: $lastResponse,)';
}

String _toEncodable(dynamic item) {
  return item;
}

String _serializeList(List? list) {
  list ??= <String>[];
  try {
    return json.encode(list, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("List serialization failed. Returning empty list.");
    }
    return '[]';
  }
}

String _serializeJson(dynamic jsonVar, [bool isList = false]) {
  jsonVar ??= (isList ? [] : {});
  try {
    return json.encode(jsonVar, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("Json serialization failed. Returning empty json.");
    }
    return isList ? '[]' : '{}';
  }
}
