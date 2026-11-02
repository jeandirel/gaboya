import '/backend/api_requests/api_calls.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/ff_builtin_enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'pay_taxi_page_widget.dart' show PayTaxiPageWidget;
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PayTaxiPageModel extends FlutterFlowModel<PayTaxiPageWidget> {
  ///  Local state fields for this page.

  bool? lookupFailed = false;

  bool? driverVerified = false;

  GaboyaVerifiedDriverStruct? verifiedDriver;
  void updateVerifiedDriverStruct(
      Function(GaboyaVerifiedDriverStruct) updateFn) {
    updateFn(verifiedDriver ??= GaboyaVerifiedDriverStruct());
  }

  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  var scannedCode = '';
  // Stores action output result for [Backend Call - API (ResolveDriver)] action in Button widget.
  ApiCallResponse? qrLookup;
  // State field(s) for driverCode widget.
  FocusNode? driverCodeFocusNode;
  TextEditingController? driverCodeTextController;
  String? Function(BuildContext, String?)? driverCodeTextControllerValidator;
  String? _driverCodeTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Saisissez l’identifiant du chauffeur';
    }

    return null;
  }

  // State field(s) for amountXaf widget.
  FocusNode? amountXafFocusNode;
  TextEditingController? amountXafTextController;
  String? Function(BuildContext, String?)? amountXafTextControllerValidator;
  String? _amountXafTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Saisissez le montant de la course';
    }

    return null;
  }

  // Stores action output result for [Backend Call - API (ResolveDriver)] action in Button widget.
  ApiCallResponse? manualLookup;

  @override
  void initState(BuildContext context) {
    driverCodeTextControllerValidator = _driverCodeTextControllerValidator;
    amountXafTextControllerValidator = _amountXafTextControllerValidator;
  }

  @override
  void dispose() {
    driverCodeFocusNode?.dispose();
    driverCodeTextController?.dispose();

    amountXafFocusNode?.dispose();
    amountXafTextController?.dispose();
  }
}
