// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Struct GaboyaCoverage
class GaboyaCoverageStruct extends BaseStruct {
  GaboyaCoverageStruct({
    /// GaboyaCoverage.country
    String? country,

    /// GaboyaCoverage.active_city_ids
    List<int>? activeCityIds,

    /// GaboyaCoverage.active_city_count
    int? activeCityCount,
  })  : _country = country,
        _activeCityIds = activeCityIds,
        _activeCityCount = activeCityCount;

  // "country" field.
  String? _country;
  String get country => _country ?? '';
  set country(String? val) => _country = val;

  bool hasCountry() => _country != null;

  // "active_city_ids" field.
  List<int>? _activeCityIds;
  List<int> get activeCityIds => _activeCityIds ?? const [];
  set activeCityIds(List<int>? val) => _activeCityIds = val;

  void updateActiveCityIds(Function(List<int>) updateFn) {
    updateFn(_activeCityIds ??= []);
  }

  bool hasActiveCityIds() => _activeCityIds != null;

  // "active_city_count" field.
  int? _activeCityCount;
  int get activeCityCount => _activeCityCount ?? 0;
  set activeCityCount(int? val) => _activeCityCount = val;

  void incrementActiveCityCount(int amount) =>
      activeCityCount = activeCityCount + amount;

  bool hasActiveCityCount() => _activeCityCount != null;

  static GaboyaCoverageStruct fromMap(Map<String, dynamic> data) =>
      GaboyaCoverageStruct(
        country: data['country'] as String?,
        activeCityIds: getDataList(data['active_city_ids']),
        activeCityCount: castToType<int>(data['active_city_count']),
      );

  static GaboyaCoverageStruct? maybeFromMap(dynamic data) => data is Map
      ? GaboyaCoverageStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'country': _country,
        'active_city_ids': _activeCityIds,
        'active_city_count': _activeCityCount,
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'country': serializeParam(
          _country,
          ParamType.String,
        ),
        'active_city_ids': serializeParam(
          _activeCityIds,
          ParamType.int,
          isList: true,
        ),
        'active_city_count': serializeParam(
          _activeCityCount,
          ParamType.int,
        ),
      }.withoutNulls;

  static GaboyaCoverageStruct fromSerializableMap(Map<String, dynamic> data) =>
      GaboyaCoverageStruct(
        country: deserializeParam(
          data['country'],
          ParamType.String,
          false,
        ),
        activeCityIds: deserializeParam<int>(
          data['active_city_ids'],
          ParamType.int,
          true,
        ),
        activeCityCount: deserializeParam(
          data['active_city_count'],
          ParamType.int,
          false,
        ),
      );

  @override
  String toString() => 'GaboyaCoverageStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is GaboyaCoverageStruct &&
        country == other.country &&
        listEquality.equals(activeCityIds, other.activeCityIds) &&
        activeCityCount == other.activeCityCount;
  }

  @override
  int get hashCode => const ListEquality().hash(
      [country, const ListEquality().hash(activeCityIds), activeCityCount]);
}

GaboyaCoverageStruct createGaboyaCoverageStruct({
  String? country,
  int? activeCityCount,
}) =>
    GaboyaCoverageStruct(
      country: country,
      activeCityCount: activeCityCount,
    );
