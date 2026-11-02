// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Struct GaboyaProvince
class GaboyaProvinceStruct extends BaseStruct {
  GaboyaProvinceStruct({
    /// GaboyaProvince.id
    int? id,

    /// GaboyaProvince.name
    String? name,

    /// GaboyaProvince.code
    String? code,
  })  : _id = id,
        _name = name,
        _code = code;

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

  // "code" field.
  String? _code;
  String get code => _code ?? '';
  set code(String? val) => _code = val;

  bool hasCode() => _code != null;

  static GaboyaProvinceStruct fromMap(Map<String, dynamic> data) =>
      GaboyaProvinceStruct(
        id: castToType<int>(data['id']),
        name: data['name'] as String?,
        code: data['code'] as String?,
      );

  static GaboyaProvinceStruct? maybeFromMap(dynamic data) => data is Map
      ? GaboyaProvinceStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'id': _id,
        'name': _name,
        'code': _code,
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
        'code': serializeParam(
          _code,
          ParamType.String,
        ),
      }.withoutNulls;

  static GaboyaProvinceStruct fromSerializableMap(Map<String, dynamic> data) =>
      GaboyaProvinceStruct(
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
        code: deserializeParam(
          data['code'],
          ParamType.String,
          false,
        ),
      );

  @override
  String toString() => 'GaboyaProvinceStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is GaboyaProvinceStruct &&
        id == other.id &&
        name == other.name &&
        code == other.code;
  }

  @override
  int get hashCode => const ListEquality().hash([id, name, code]);
}

GaboyaProvinceStruct createGaboyaProvinceStruct({
  int? id,
  String? name,
  String? code,
}) =>
    GaboyaProvinceStruct(
      id: id,
      name: name,
      code: code,
    );
