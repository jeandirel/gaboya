import '/services/gaboya_api.dart';
import 'package:flutter/foundation.dart';
import '/flutter_flow/ff_builtin_enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'pay_taxi_page_model.dart';
export 'pay_taxi_page_model.dart';

/// DSL page PayTaxiPage
class PayTaxiPageWidget extends StatefulWidget {
  const PayTaxiPageWidget({super.key, this.api});
  final GaboyaApi? api;

  static String routeName = 'PayTaxiPage';
  static String routePath = '/payer-taxi';

  @override
  State<PayTaxiPageWidget> createState() => _PayTaxiPageWidgetState();
}

class _PayTaxiPageWidgetState extends State<PayTaxiPageWidget> {
  late PayTaxiPageModel _model;

  Map<String, dynamic>? _driver;
  Map<String, dynamic>? _intent;
  String? _resolvedCode;
  String? _intentKey;
  String? _intentFingerprint;
  bool _busy = false;

  Future<void> _lookup(String value) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _driver = null;
      _resolvedCode = null;
      _intent = null;
    });
    try {
      final code = GaboyaApi.driverCode(value);
      final driver = await _api.resolveDriver(code);
      if (!mounted) return;
      setState(() {
        _model.driverCodeTextController!.text = code;
        _driver = driver;
        _resolvedCode = code;
      });
    } on ApiException catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted)
        setState(() {
          _busy = false;
        });
    }
  }

  Future<void> _scan() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Sur le web, saisissez le code imprimé sous le QR.')));
      return;
    }
    try {
      final value = await FlutterBarcodeScanner.scanBarcode(
          '#125C45', 'Annuler', true, ScanMode.QR);
      if (!mounted || value == '-1' || value.isEmpty) return;
      await _lookup(value);
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text('Caméra indisponible. Saisissez le code chauffeur.')));
    }
  }

  Future<void> _prepare() async {
    if (_busy) return;
    if (_driver == null ||
        _resolvedCode !=
            _model.driverCodeTextController!.text.trim().toUpperCase()) {
      await _lookup(_model.driverCodeTextController!.text);
      return;
    }
    if (!_model.formKey.currentState!.validate()) return;
    final amount = int.tryParse(_model.amountXafTextController!.text.trim());
    if (amount == null || amount < 1 || amount > 250000) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Saisissez un montant entier entre 1 et 250 000 FCFA.')));
      return;
    }
    final accepted = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text('Préparer votre paiement'),
                content: Text(
                    '${_driver!['display_name']} • ${_driver!['vehicle']['license_plate']}\n$amount FCFA\nAucun débit ne sera effectué. pawaPay sera disponible après intégration.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Annuler')),
                  TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Préparer'))
                ]));
    if (accepted != true || !mounted) return;
    final fingerprint = '$_resolvedCode:$amount';
    if (_intentFingerprint != fingerprint) {
      _intentFingerprint = fingerprint;
      _intentKey = GaboyaApi.newIdempotencyKey();
    }
    setState(() {
      _busy = true;
      _intent = null;
    });
    try {
      final intent =
          await _api.preparePayment(_resolvedCode!, amount, _intentKey!);
      if (mounted)
        setState(() {
          _intent = intent;
        });
    } on ApiException catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted)
        setState(() {
          _busy = false;
        });
    }
  }

  GaboyaApi get _api => widget.api ?? GaboyaApi.instance;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PayTaxiPageModel());

    _model.driverCodeTextController ??= TextEditingController();
    _model.driverCodeFocusNode ??= FocusNode();

    _model.amountXafTextController ??= TextEditingController();
    _model.amountXafFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
          automaticallyImplyLeading: true,
          title: Text(
            'Payer un taxi',
            style: FlutterFlowTheme.of(context).titleLarge.override(
                  font: GoogleFonts.manrope(
                    fontWeight:
                        FlutterFlowTheme.of(context).titleLarge.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).titleLarge.fontStyle,
                  ),
                  letterSpacing: 0.0,
                  fontWeight:
                      FlutterFlowTheme.of(context).titleLarge.fontWeight,
                  fontStyle: FlutterFlowTheme.of(context).titleLarge.fontStyle,
                ),
          ),
          actions: [],
          centerTitle: true,
          elevation: 0.0,
        ),
        body: SafeArea(
            top: true,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: (FFMainAxisAlignment.start).flutterValue,
                  crossAxisAlignment: (FFCrossAxisAlignment.start).flutterValue,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        borderRadius: BorderRadius.circular(22.0),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment:
                              (FFMainAxisAlignment.start).flutterValue,
                          crossAxisAlignment:
                              (FFCrossAxisAlignment.center).flutterValue,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Icon(
                              Icons.qr_code_scanner,
                              color: FlutterFlowTheme.of(context).primary,
                              size: 42.0,
                            ),
                            Text(
                              'Scannez le QR du chauffeur',
                              style: FlutterFlowTheme.of(context)
                                  .brandTitle
                                  .override(
                                    font: GoogleFonts.manrope(
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .brandTitle
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    fontSize: 20.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .brandTitle
                                        .fontStyle,
                                  ),
                            ),
                            Text(
                              'Vérifiez son identité avant de saisir le montant.',
                              style: FlutterFlowTheme.of(context)
                                  .brandBody
                                  .override(
                                    font: GoogleFonts.inter(
                                      fontWeight: FontWeight.normal,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .brandBody
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                    fontSize: 15.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.normal,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .brandBody
                                        .fontStyle,
                                  ),
                            ),
                            FFButtonWidget(
                              onPressed: _busy ? null : _scan,
                              text: 'Ouvrir le scanner',
                              options: FFButtonOptions(
                                width: double.infinity,
                                height: 48.0,
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 0.0),
                                iconPadding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 0.0, 0.0, 0.0),
                                color: FlutterFlowTheme.of(context).primary,
                                textStyle: TextStyle(
                                  color: FlutterFlowTheme.of(context).info,
                                ),
                                borderRadius: BorderRadius.circular(14.0),
                              ),
                            ),
                          ].divide(SizedBox(height: 12.0)),
                        ),
                      ),
                    ),
                    Text(
                      'OU SAISIR UN IDENTIFIANT',
                      style: FlutterFlowTheme.of(context).brandCaption.override(
                            font: GoogleFonts.inter(
                              fontWeight: FontWeight.w500,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .brandCaption
                                  .fontStyle,
                            ),
                            color: FlutterFlowTheme.of(context).secondaryText,
                            fontSize: 12.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w500,
                            fontStyle: FlutterFlowTheme.of(context)
                                .brandCaption
                                .fontStyle,
                          ),
                    ),
                    Form(
                      key: _model.formKey,
                      autovalidateMode: AutovalidateMode.disabled,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment:
                            (FFMainAxisAlignment.start).flutterValue,
                        crossAxisAlignment:
                            (FFCrossAxisAlignment.center).flutterValue,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          TextFormField(
                            controller: _model.driverCodeTextController,
                            enabled: !_busy,
                            onChanged: (_) => setState(() {
                              _driver = null;
                              _resolvedCode = null;
                              _intent = null;
                            }),
                            focusNode: _model.driverCodeFocusNode,
                            obscureText: false,
                            decoration: InputDecoration(
                              labelText: 'Identifiant chauffeur',
                              hintText: 'Ex. GBY-A1B2C3D4E5F60708',
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0x00000000),
                                  width: 1.0,
                                ),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4.0),
                                  topRight: Radius.circular(4.0),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0x00000000),
                                  width: 1.0,
                                ),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4.0),
                                  topRight: Radius.circular(4.0),
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0x00000000),
                                  width: 1.0,
                                ),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4.0),
                                  topRight: Radius.circular(4.0),
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0x00000000),
                                  width: 1.0,
                                ),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4.0),
                                  topRight: Radius.circular(4.0),
                                ),
                              ),
                              filled: true,
                            ),
                            style: TextStyle(),
                            maxLines: null,
                            validator: _model.driverCodeTextControllerValidator
                                .asValidator(context),
                          ),
                          TextFormField(
                            controller: _model.amountXafTextController,
                            enabled: !_busy,
                            onChanged: (_) => setState(() {
                              _intent = null;
                            }),
                            focusNode: _model.amountXafFocusNode,
                            obscureText: false,
                            decoration: InputDecoration(
                              labelText: 'Montant (FCFA)',
                              hintText: 'Ex. 1 000',
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0x00000000),
                                  width: 1.0,
                                ),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4.0),
                                  topRight: Radius.circular(4.0),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0x00000000),
                                  width: 1.0,
                                ),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4.0),
                                  topRight: Radius.circular(4.0),
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0x00000000),
                                  width: 1.0,
                                ),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4.0),
                                  topRight: Radius.circular(4.0),
                                ),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0x00000000),
                                  width: 1.0,
                                ),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4.0),
                                  topRight: Radius.circular(4.0),
                                ),
                              ),
                              filled: true,
                            ),
                            style: TextStyle(),
                            maxLines: null,
                            keyboardType: (FFKeyboardType.number).flutterValue,
                            validator: _model.amountXafTextControllerValidator
                                .asValidator(context),
                          ),
                        ].divide(SizedBox(height: 16.0)),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: FlutterFlowTheme.of(context).accent3,
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(14.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment:
                              (FFMainAxisAlignment.start).flutterValue,
                          crossAxisAlignment:
                              (FFCrossAxisAlignment.center).flutterValue,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: FlutterFlowTheme.of(context).warning,
                              size: 18.0,
                            ),
                            Expanded(
                              child: Text(
                                'Aucun débit disponible pour le moment. Une intention de paiement ne constitue jamais une confirmation de paiement.',
                                style: FlutterFlowTheme.of(context)
                                    .brandCaption
                                    .override(
                                      font: GoogleFonts.inter(
                                        fontWeight: FontWeight.w500,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .brandCaption
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      fontSize: 12.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w500,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .brandCaption
                                          .fontStyle,
                                    ),
                              ),
                            ),
                          ].divide(SizedBox(width: 10.0)),
                        ),
                      ),
                    ),
                    if (_driver != null)
                      Card(
                          child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Row(children: [
                                      Icon(Icons.verified,
                                          color: Color(0xFF125C45)),
                                      SizedBox(width: 8),
                                      Text('Chauffeur approuvé')
                                    ]),
                                    Text(_driver!['display_name'],
                                        style: FlutterFlowTheme.of(context)
                                            .titleLarge),
                                    Text(_driver!['vehicle']['license_plate']),
                                    Text(_driver!['vehicle']['description']),
                                  ]))),
                    if (_intent != null)
                      Card(
                          child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                        'Intention enregistrée — paiement non effectué'),
                                    Text('${_intent!['amount_xaf']} FCFA'),
                                    Text('Référence : ${_intent!['id']}'),
                                    const Text(
                                        'pawaPay indisponible. Aucun montant débité.'),
                                  ]))),
                    FFButtonWidget(
                      onPressed: _busy ? null : _prepare,
                      text: _busy
                          ? 'Patientez…'
                          : (_driver == null
                              ? 'Vérifier le chauffeur'
                              : 'Préparer le paiement'),
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: 54.0,
                        padding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                        iconPadding:
                            EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                        color: FlutterFlowTheme.of(context).primary,
                        textStyle: TextStyle(
                          color: FlutterFlowTheme.of(context).info,
                        ),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    ),
                  ].divide(SizedBox(height: 18.0)),
                ),
              ),
            )),
      ),
    );
  }
}
