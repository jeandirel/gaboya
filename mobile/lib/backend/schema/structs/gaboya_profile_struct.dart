// ignore_for_file: unnecessary_getters_setters

import '/backend/schema/util/schema_util.dart';
import '/backend/schema/enums/enums.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Struct GaboyaProfile
class GaboyaProfileStruct extends BaseStruct {
  GaboyaProfileStruct({
    /// GaboyaProfile.userId
    String? userId,

    /// GaboyaProfile.phoneE164
    String? phoneE164,

    /// GaboyaProfile.displayName
    String? displayName,

    /// GaboyaProfile.locale
    String? locale,

    /// GaboyaProfile.roles
    List<GaboyaRole>? roles,
  })  : _userId = userId,
        _phoneE164 = phoneE164,
        _displayName = displayName,
        _locale = locale,
        _roles = roles;

  // "userId" field.
  String? _userId;
  String get userId => _userId ?? '';
  set userId(String? val) => _userId = val;

  bool hasUserId() => _userId != null;

  // "phoneE164" field.
  String? _phoneE164;
  String get phoneE164 => _phoneE164 ?? '';
  set phoneE164(String? val) => _phoneE164 = val;

  bool hasPhoneE164() => _phoneE164 != null;

  // "displayName" field.
  String? _displayName;
  String get displayName => _displayName ?? '';
  set displayName(String? val) => _displayName = val;

  bool hasDisplayName() => _displayName != null;

  // "locale" field.
  String? _locale;
  String get locale => _locale ?? '';
  set locale(String? val) => _locale = val;

  bool hasLocale() => _locale != null;

  // "roles" field.
  List<GaboyaRole>? _roles;
  List<GaboyaRole> get roles => _roles ?? const [];
  set roles(List<GaboyaRole>? val) => _roles = val;

  void updateRoles(Function(List<GaboyaRole>) updateFn) {
    updateFn(_roles ??= []);
  }

  bool hasRoles() => _roles != null;

  static GaboyaProfileStruct fromMap(Map<String, dynamic> data) =>
      GaboyaProfileStruct(
        userId: data['userId'] as String?,
        phoneE164: data['phoneE164'] as String?,
        displayName: data['displayName'] as String?,
        locale: data['locale'] as String?,
        roles: getEnumList<GaboyaRole>(data['roles']),
      );

  static GaboyaProfileStruct? maybeFromMap(dynamic data) => data is Map
      ? GaboyaProfileStruct.fromMap(data.cast<String, dynamic>())
      : null;

  Map<String, dynamic> toMap() => {
        'userId': _userId,
        'phoneE164': _phoneE164,
        'displayName': _displayName,
        'locale': _locale,
        'roles': _roles?.map((e) => e.serialize()).toList(),
      }.withoutNulls;

  @override
  Map<String, dynamic> toSerializableMap() => {
        'userId': serializeParam(
          _userId,
          ParamType.String,
        ),
        'phoneE164': serializeParam(
          _phoneE164,
          ParamType.String,
        ),
        'displayName': serializeParam(
          _displayName,
          ParamType.String,
        ),
        'locale': serializeParam(
          _locale,
          ParamType.String,
        ),
        'roles': serializeParam(
          _roles,
          ParamType.Enum,
          isList: true,
        ),
      }.withoutNulls;

  static GaboyaProfileStruct fromSerializableMap(Map<String, dynamic> data) =>
      GaboyaProfileStruct(
        userId: deserializeParam(
          data['userId'],
          ParamType.String,
          false,
        ),
        phoneE164: deserializeParam(
          data['phoneE164'],
          ParamType.String,
          false,
        ),
        displayName: deserializeParam(
          data['displayName'],
          ParamType.String,
          false,
        ),
        locale: deserializeParam(
          data['locale'],
          ParamType.String,
          false,
        ),
        roles: deserializeParam<GaboyaRole>(
          data['roles'],
          ParamType.Enum,
          true,
        ),
      );

  @override
  String toString() => 'GaboyaProfileStruct(${toMap()})';

  @override
  bool operator ==(Object other) {
    const listEquality = ListEquality();
    return other is GaboyaProfileStruct &&
        userId == other.userId &&
        phoneE164 == other.phoneE164 &&
        displayName == other.displayName &&
        locale == other.locale &&
        listEquality.equals(roles, other.roles);
  }

  @override
  int get hashCode => const ListEquality().hash([
        userId,
        phoneE164,
        displayName,
        locale,
        const ListEquality().hash(roles)
      ]);
}

GaboyaProfileStruct createGaboyaProfileStruct({
  String? userId,
  String? phoneE164,
  String? displayName,
  String? locale,
}) =>
    GaboyaProfileStruct(
      userId: userId,
      phoneE164: phoneE164,
      displayName: displayName,
      locale: locale,
    );
