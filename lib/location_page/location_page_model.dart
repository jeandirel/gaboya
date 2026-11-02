import '/backend/api_requests/api_calls.dart';
import '/backend/schema/structs/index.dart';
import '/components/geo_loading_state_widget.dart';
import '/flutter_flow/ff_builtin_enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'location_page_widget.dart' show LocationPageWidget;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class LocationPageModel extends FlutterFlowModel<LocationPageWidget> {
  ///  Local state fields for this page.

  int? selectedProvinceId = 1;

  int? selectedCityId = 1;

  String? selectedProvinceName = 'Estuaire';

  String? selectedCityName = 'Libreville';

  bool? citySelected = false;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
