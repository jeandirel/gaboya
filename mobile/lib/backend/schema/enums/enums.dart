import 'package:collection/collection.dart';

/// Enum GaboyaRole
enum GaboyaRole {
  passenger,
  driver,
  inspector,
  companyAgent,
  companyOwner,
  support,
  finance,
  compliance,
  administrator,
}

extension FFEnumExtensions<T extends Enum> on T {
  String serialize() => name;
}

extension FFEnumListExtensions<T extends Enum> on Iterable<T> {
  T? deserialize(String? value) =>
      firstWhereOrNull((e) => e.serialize() == value);
}

T? deserializeEnum<T>(String? value) {
  switch (T) {
    case (GaboyaRole):
      return GaboyaRole.values.deserialize(value) as T?;
    default:
      return null;
  }
}
