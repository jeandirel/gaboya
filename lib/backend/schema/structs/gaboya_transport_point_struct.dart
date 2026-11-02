// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Struct GaboyaTransportPoint
class GaboyaTransportPointStruct extends BaseStruct {
  GaboyaTransportPointStruct({
    /// GaboyaTransportPoint.id
    int? id,

    /// GaboyaTransportPoint.name
    String? name,

    /// GaboyaTransportPoint.city_id
    int? cityId,
  })  : _id = id,
        _name = name,
        _cityId = cityId;

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

  // "city_id" field.
  int? _cityId;
  int get cityId => _cityId ?? 0;
  set cityId(int? val) => _cityId = val;

  void incrementCityId(int amount) => cityId = cityId + amount;

  bool hasCityId() => _cityId != null;

  static GaboyaTransportPointStruct fromMap(Map<String, dynamic> data) =>
      GaboyaTransportPointStruct(
        id: castToType<int>(data['id']),
        name: data['name'] as String?,
        cityId: castToType<int>(data['city_id']),
      );

  static GaboyaTransportPointStruct? maybeFromMap(dynamic data) => data is Map
      ? GaboyaTransportPointStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'id': _id,
        'name': _name,
        'city_id': _cityId,
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
        'city_id': serializeParam(
          _cityId,
          ParamType.int,
        ),
      }.withoutNulls;

  static GaboyaTransportPointStruct fromSerializableMap(
          Map<String, dynamic> data) =>
      GaboyaTransportPointStruct(
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
        cityId: deserializeParam(
          data['city_id'],
          ParamType.int,
          false,
        ),
      );

  @override
  String toString() => 'GaboyaTransportPointStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    return other is GaboyaTransportPointStruct &&
        id == other.id &&
        name == other.name &&
        cityId == other.cityId;
  }

  @override
  int get hashCode => const ListEquality().hash([id, name, cityId]);
}

GaboyaTransportPointStruct createGaboyaTransportPointStruct({
  int? id,
  String? name,
  int? cityId,
}) =>
    GaboyaTransportPointStruct(
      id: id,
      name: name,
      cityId: cityId,
    );
