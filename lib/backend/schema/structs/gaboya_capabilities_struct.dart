// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Struct GaboyaCapabilities
class GaboyaCapabilitiesStruct extends BaseStruct {
  GaboyaCapabilitiesStruct({
    /// GaboyaCapabilities.project
    String? project,

    /// GaboyaCapabilities.currency
    String? currency,

    /// GaboyaCapabilities.otp_ready
    bool? otpReady,

    /// GaboyaCapabilities.payments_ready
    bool? paymentsReady,

    /// GaboyaCapabilities.payments_live
    bool? paymentsLive,

    /// GaboyaCapabilities.message
    String? message,
  })  : _project = project,
        _currency = currency,
        _otpReady = otpReady,
        _paymentsReady = paymentsReady,
        _paymentsLive = paymentsLive,
        _message = message;

  // "project" field.
  String? _project;
  String get project => _project ?? '';
  set project(String? val) => _project = val;

  bool hasProject() => _project != null;

  // "currency" field.
  String? _currency;
  String get currency => _currency ?? '';
  set currency(String? val) => _currency = val;

  bool hasCurrency() => _currency != null;

  // "otp_ready" field.
  bool? _otpReady;
  bool get otpReady => _otpReady ?? false;
  set otpReady(bool? val) => _otpReady = val;

  bool hasOtpReady() => _otpReady != null;

  // "payments_ready" field.
  bool? _paymentsReady;
  bool get paymentsReady => _paymentsReady ?? false;
  set paymentsReady(bool? val) => _paymentsReady = val;

  bool hasPaymentsReady() => _paymentsReady != null;

  // "payments_live" field.
  bool? _paymentsLive;
  bool get paymentsLive => _paymentsLive ?? false;
  set paymentsLive(bool? val) => _paymentsLive = val;

  bool hasPaymentsLive() => _paymentsLive != null;

  // "message" field.
  String? _message;
  String get message => _message ?? '';
  set message(String? val) => _message = val;

  bool hasMessage() => _message != null;

  static GaboyaCapabilitiesStruct fromMap(Map<String, dynamic> data) =>
      GaboyaCapabilitiesStruct(
        project: data['project'] as String?,
        currency: data['currency'] as String?,
        otpReady: data['otp_ready'] as bool?,
        paymentsReady: data['payments_ready'] as bool?,
        paymentsLive: data['payments_live'] as bool?,
        message: data['message'] as String?,
      );

  static GaboyaCapabilitiesStruct? maybeFromMap(dynamic data) => data is Map
      ? GaboyaCapabilitiesStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'project': _project,
        'currency': _currency,
        'otp_ready': _otpReady,
        'payments_ready': _paymentsReady,
        'payments_live': _paymentsLive,
        'message': _message,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'project': serializeParam(
          _project,
          ParamType.String,
        ),
        'currency': serializeParam(
          _currency,
          ParamType.String,
        ),
        'otp_ready': serializeParam(
          _otpReady,
          ParamType.bool,
        ),
        'payments_ready': serializeParam(
          _paymentsReady,
          ParamType.bool,
        ),
        'payments_live': serializeParam(
          _paymentsLive,
          ParamType.bool,
        ),
        'message': serializeParam(
          _message,
          ParamType.String,
        ),
      }.withoutNulls;

  static GaboyaCapabilitiesStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      GaboyaCapabilitiesStruct(
        project: deserializeParam(
          data['project'],
          ParamType.String,
          false,
        ),
        currency: deserializeParam(
          data['currency'],
          ParamType.String,
          false,
        ),
        otpReady: deserializeParam(
          data['otp_ready'],
          ParamType.bool,
          false,
        ),
        paymentsReady: deserializeParam(
          data['payments_ready'],
          ParamType.bool,
          false,
        ),
        paymentsLive: deserializeParam(
          data['payments_live'],
          ParamType.bool,
          false,
        ),
        message: deserializeParam(
          data['message'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'GaboyaCapabilitiesStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is GaboyaCapabilitiesStruct &&
        project == other.project &&
        currency == other.currency &&
        otpReady == other.otpReady &&
        paymentsReady == other.paymentsReady &&
        paymentsLive == other.paymentsLive &&
        message == other.message;
  }

  @override
  int get hashCode => const ListEquality().hash(
      [project, currency, otpReady, paymentsReady, paymentsLive, message]);
}

GaboyaCapabilitiesStruct createGaboyaCapabilitiesStruct({
  String? project,
  String? currency,
  bool? otpReady,
  bool? paymentsReady,
  bool? paymentsLive,
  String? message,
}) =>
    GaboyaCapabilitiesStruct(
      project: project,
      currency: currency,
      otpReady: otpReady,
      paymentsReady: paymentsReady,
      paymentsLive: paymentsLive,
      message: message,
    );
