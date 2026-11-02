// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Struct GaboyaVerifiedDriver
class GaboyaVerifiedDriverStruct extends BaseStruct {
  GaboyaVerifiedDriverStruct({
    /// GaboyaVerifiedDriver.driver_id
    String? driverId,

    /// GaboyaVerifiedDriver.display_name
    String? displayName,

    /// GaboyaVerifiedDriver.vehicle
    dynamic vehicle,

    /// GaboyaVerifiedDriver.verified
    bool? verified,
  })  : _driverId = driverId,
        _displayName = displayName,
        _vehicle = vehicle,
        _verified = verified;

  // "driver_id" field.
  String? _driverId;
  String get driverId => _driverId ?? '';
  set driverId(String? val) => _driverId = val;

  bool hasDriverId() => _driverId != null;

  // "display_name" field.
  String? _displayName;
  String get displayName => _displayName ?? '';
  set displayName(String? val) => _displayName = val;

  bool hasDisplayName() => _displayName != null;

  // "vehicle" field.
  dynamic? _vehicle;
  dynamic? get vehicle => _vehicle;
  set vehicle(dynamic? val) => _vehicle = val;

  bool hasVehicle() => _vehicle != null;

  // "verified" field.
  bool? _verified;
  bool get verified => _verified ?? false;
  set verified(bool? val) => _verified = val;

  bool hasVerified() => _verified != null;

  static GaboyaVerifiedDriverStruct fromMap(Map<String, dynamic> data) =>
      GaboyaVerifiedDriverStruct(
        driverId: data['driver_id'] as String?,
        displayName: data['display_name'] as String?,
        vehicle: data['vehicle'] as dynamic?,
        verified: data['verified'] as bool?,
      );

  static GaboyaVerifiedDriverStruct? maybeFromMap(dynamic data) => data is Map
      ? GaboyaVerifiedDriverStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'driver_id': _driverId,
        'display_name': _displayName,
        'vehicle': _vehicle,
        'verified': _verified,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'driver_id': serializeParam(
          _driverId,
          ParamType.String,
        ),
        'display_name': serializeParam(
          _displayName,
          ParamType.String,
        ),
        'vehicle': serializeParam(
          _vehicle,
          ParamType.JSON,
        ),
        'verified': serializeParam(
          _verified,
          ParamType.bool,
        ),
      }.withoutNulls;

  static GaboyaVerifiedDriverStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      GaboyaVerifiedDriverStruct(
        driverId: deserializeParam(
          data['driver_id'],
          ParamType.String,
          false,
        ),
        displayName: deserializeParam(
          data['display_name'],
          ParamType.String,
          false,
        ),
        vehicle: deserializeParam(
          data['vehicle'],
          ParamType.JSON,
          false,
        ),
        verified: deserializeParam(
          data['verified'],
          ParamType.bool,
          false,
        ),
      );

  @override
  String toString() => 'GaboyaVerifiedDriverStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is GaboyaVerifiedDriverStruct &&
        driverId == other.driverId &&
        displayName == other.displayName &&
        vehicle == other.vehicle &&
        verified == other.verified;
  }

  @override
  int get hashCode =>
      const ListEquality().hash([driverId, displayName, vehicle, verified]);
}

GaboyaVerifiedDriverStruct createGaboyaVerifiedDriverStruct({
  String? driverId,
  String? displayName,
  dynamic? vehicle,
  bool? verified,
}) =>
    GaboyaVerifiedDriverStruct(
      driverId: driverId,
      displayName: displayName,
      vehicle: vehicle,
      verified: verified,
    );
