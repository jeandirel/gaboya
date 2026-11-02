// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Struct GaboyaCity
class GaboyaCityStruct extends BaseStruct {
  GaboyaCityStruct({
    /// GaboyaCity.id
    int? id,

    /// GaboyaCity.name
    String? name,

    /// GaboyaCity.province_id
    int? provinceId,

    /// GaboyaCity.service_enabled
    bool? serviceEnabled,
  })  : _id = id,
        _name = name,
        _provinceId = provinceId,
        _serviceEnabled = serviceEnabled;

  // "id" field.
  int? _id;
  int get id => _id ?? 0;
  set id(int? val) => _id = val;

  void incrementId(int amount) => id = id + amount;

  bool hasId() => _id != null;

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  set name(String? val) => _name = val;

  bool hasName() => _name != null;

  // "province_id" field.
  int? _provinceId;
  int get provinceId => _provinceId ?? 0;
  set provinceId(int? val) => _provinceId = val;

  void incrementProvinceId(int amount) => provinceId = provinceId + amount;

  bool hasProvinceId() => _provinceId != null;

  // "service_enabled" field.
  bool? _serviceEnabled;
  bool get serviceEnabled => _serviceEnabled ?? false;
  set serviceEnabled(bool? val) => _serviceEnabled = val;

  bool hasServiceEnabled() => _serviceEnabled != null;

  static GaboyaCityStruct fromMap(Map<String, dynamic> data) =>
      GaboyaCityStruct(
        id: castToType<int>(data['id']),
        name: data['name'] as String?,
        provinceId: castToType<int>(data['province_id']),
        serviceEnabled: data['service_enabled'] as bool?,
      );

  static GaboyaCityStruct? maybeFromMap(dynamic data) => data is Map
      ? GaboyaCityStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'id': _id,
        'name': _name,
        'province_id': _provinceId,
        'service_enabled': _serviceEnabled,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'id': serializeParam(
          _id,
          ParamType.int,
        ),
        'name': serializeParam(
          _name,
          ParamType.String,
        ),
        'province_id': serializeParam(
          _provinceId,
          ParamType.int,
        ),
        'service_enabled': serializeParam(
          _serviceEnabled,
          ParamType.bool,
        ),
      }.withoutNulls;

  static GaboyaCityStruct fromSerializableMap(Map<String, dynamic> data) =>
      GaboyaCityStruct(
        id: deserializeParam(
          data['id'],
          ParamType.int,
          false,
        ),
        name: deserializeParam(
          data['name'],
          ParamType.String,
          false,
        ),
        provinceId: deserializeParam(
          data['province_id'],
          ParamType.int,
          false,
        ),
        serviceEnabled: deserializeParam(
          data['service_enabled'],
          ParamType.bool,
          false,
        ),
      );

  @override
  String toString() => 'GaboyaCityStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is GaboyaCityStruct &&
        id == other.id &&
        name == other.name &&
        provinceId == other.provinceId &&
        serviceEnabled == other.serviceEnabled;
  }

  @override
  int get hashCode =>
      const ListEquality().hash([id, name, provinceId, serviceEnabled]);
}

GaboyaCityStruct createGaboyaCityStruct({
  int? id,
  String? name,
  int? provinceId,
  bool? serviceEnabled,
}) =>
    GaboyaCityStruct(
      id: id,
      name: name,
      provinceId: provinceId,
      serviceEnabled: serviceEnabled,
    );
