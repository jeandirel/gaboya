// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Struct DriverVehicle
class DriverVehicleStruct extends BaseStruct {
  DriverVehicleStruct({
    /// DriverVehicle.vehicleId
    String? vehicleId,

    /// DriverVehicle.vehicleType
    String? vehicleType,

    /// DriverVehicle.maskedPlate
    String? maskedPlate,

    /// DriverVehicle.approvalStatus
    String? approvalStatus,
  })  : _vehicleId = vehicleId,
        _vehicleType = vehicleType,
        _maskedPlate = maskedPlate,
        _approvalStatus = approvalStatus;

  // "vehicleId" field.
  String? _vehicleId;
  String get vehicleId => _vehicleId ?? '';
  set vehicleId(String? val) => _vehicleId = val;

  bool hasVehicleId() => _vehicleId != null;

  // "vehicleType" field.
  String? _vehicleType;
  String get vehicleType => _vehicleType ?? '';
  set vehicleType(String? val) => _vehicleType = val;

  bool hasVehicleType() => _vehicleType != null;

  // "maskedPlate" field.
  String? _maskedPlate;
  String get maskedPlate => _maskedPlate ?? '';
  set maskedPlate(String? val) => _maskedPlate = val;

  bool hasMaskedPlate() => _maskedPlate != null;

  // "approvalStatus" field.
  String? _approvalStatus;
  String get approvalStatus => _approvalStatus ?? '';
  set approvalStatus(String? val) => _approvalStatus = val;

  bool hasApprovalStatus() => _approvalStatus != null;

  static DriverVehicleStruct fromMap(Map<String, dynamic> data) =>
      DriverVehicleStruct(
        vehicleId: data['vehicleId'] as String?,
        vehicleType: data['vehicleType'] as String?,
        maskedPlate: data['maskedPlate'] as String?,
        approvalStatus: data['approvalStatus'] as String?,
      );

  static DriverVehicleStruct? maybeFromMap(dynamic data) => data is Map
      ? DriverVehicleStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'vehicleId': _vehicleId,
        'vehicleType': _vehicleType,
        'maskedPlate': _maskedPlate,
        'approvalStatus': _approvalStatus,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'vehicleId': serializeParam(
          _vehicleId,
          ParamType.String,
        ),
        'vehicleType': serializeParam(
          _vehicleType,
          ParamType.String,
        ),
        'maskedPlate': serializeParam(
          _maskedPlate,
          ParamType.String,
        ),
        'approvalStatus': serializeParam(
          _approvalStatus,
          ParamType.String,
        ),
      }.withoutNulls;

  static DriverVehicleStruct fromSerializableMap(Map<String, dynamic> data) =>
      DriverVehicleStruct(
        vehicleId: deserializeParam(
          data['vehicleId'],
          ParamType.String,
          false,
        ),
        vehicleType: deserializeParam(
          data['vehicleType'],
          ParamType.String,
          false,
        ),
        maskedPlate: deserializeParam(
          data['maskedPlate'],
          ParamType.String,
          false,
        ),
        approvalStatus: deserializeParam(
          data['approvalStatus'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'DriverVehicleStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is DriverVehicleStruct &&
        vehicleId == other.vehicleId &&
        vehicleType == other.vehicleType &&
        maskedPlate == other.maskedPlate &&
        approvalStatus == other.approvalStatus;
  }

  @override
  int get hashCode => const ListEquality()
      .hash([vehicleId, vehicleType, maskedPlate, approvalStatus]);
}

DriverVehicleStruct createDriverVehicleStruct({
  String? vehicleId,
  String? vehicleType,
  String? maskedPlate,
  String? approvalStatus,
}) =>
    DriverVehicleStruct(
      vehicleId: vehicleId,
      vehicleType: vehicleType,
      maskedPlate: maskedPlate,
      approvalStatus: approvalStatus,
    );
