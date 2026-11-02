import 'package:flutter/material.dart'
    show ChangeNotifier, Color, Colors, VoidCallback;
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/api_requests/api_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flutter_flow/flutter_flow_util.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {
    prefs = await SharedPreferences.getInstance();
    _safeInit(() {
      _selectedProvinceId =
          prefs.getInt('ff_selectedProvinceId') ?? _selectedProvinceId;
    });
    _safeInit(() {
      _selectedProvinceName =
          prefs.getString('ff_selectedProvinceName') ?? _selectedProvinceName;
    });
    _safeInit(() {
      _selectedCityId = prefs.getInt('ff_selectedCityId') ?? _selectedCityId;
    });
    _safeInit(() {
      _selectedCityName =
          prefs.getString('ff_selectedCityName') ?? _selectedCityName;
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late SharedPreferences prefs;

  /// App state selectedProvinceId
  int _selectedProvinceId = 1;
  int get selectedProvinceId => _selectedProvinceId;
  set selectedProvinceId(int value) {
    _selectedProvinceId = value;
    prefs.setInt('ff_selectedProvinceId', value);
  }

  /// App state selectedProvinceName
  String _selectedProvinceName = 'Estuaire';
  String get selectedProvinceName => _selectedProvinceName;
  set selectedProvinceName(String value) {
    _selectedProvinceName = value;
    prefs.setString('ff_selectedProvinceName', value);
  }

  /// App state selectedCityId
  int _selectedCityId = 1;
  int get selectedCityId => _selectedCityId;
  set selectedCityId(int value) {
    _selectedCityId = value;
    prefs.setInt('ff_selectedCityId', value);
  }

  /// App state selectedCityName
  String _selectedCityName = 'Libreville';
  String get selectedCityName => _selectedCityName;
  set selectedCityName(String value) {
    _selectedCityName = value;
    prefs.setString('ff_selectedCityName', value);
  }
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}

Future _safeInitAsync(Function() initializeField) async {
  try {
    await initializeField();
  } catch (_) {}
}
