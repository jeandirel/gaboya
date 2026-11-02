// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Struct GaboyaDriverVehicle
class GaboyaDriverVehicleStruct extends BaseStruct {
  GaboyaDriverVehicleStruct({
    /// GaboyaDriverVehicle.license_plate
    String? licensePlate,

    /// GaboyaDriverVehicle.description
    String? description,
  })  : _licensePlate = licensePlate,
        _description = description;

  // "license_plate" field.
  String? _licensePlate;
  String get licensePlate => _licensePlate ?? '';
  set licensePlate(String? val) => _licensePlate = val;

  bool hasLicensePlate() => _licensePlate != null;

  // "description" field.
  String? _description;
  String get description => _description ?? '';
  set description(String? val) => _description = val;

  bool hasDescription() => _description != null;

  static GaboyaDriverVehicleStruct fromMap(Map<String, dynamic> data) =>
      GaboyaDriverVehicleStruct(
        licensePlate: data['license_plate'] as String?,
        description: data['description'] as String?,
      );

  static GaboyaDriverVehicleStruct? maybeFromMap(dynamic data) => data is Map
      ? GaboyaDriverVehicleStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'license_plate': _licensePlate,
        'description': _description,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'license_plate': serializeParam(
          _licensePlate,
          ParamType.String,
        ),
        'description': serializeParam(
          _description,
          ParamType.String,
        ),
      }.withoutNulls;

  static GaboyaDriverVehicleStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      GaboyaDriverVehicleStruct(
        licensePlate: deserializeParam(
          data['license_plate'],
          ParamType.String,
          false,
        ),
        description: deserializeParam(
          data['description'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'GaboyaDriverVehicleStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is GaboyaDriverVehicleStruct &&
        licensePlate == other.licensePlate &&
        description == other.description;
  }

  @override
  int get hashCode => const ListEquality().hash([licensePlate, description]);
}

GaboyaDriverVehicleStruct createGaboyaDriverVehicleStruct({
  String? licensePlate,
  String? description,
}) =>
    GaboyaDriverVehicleStruct(
      licensePlate: licensePlate,
      description: description,
    );
