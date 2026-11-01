import '/services/gaboya_api.dart';
import '/flutter_flow/ff_builtin_enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'sign_in_page_model.dart';
export 'sign_in_page_model.dart';

/// DSL page SignInPage
class SignInPageWidget extends StatefulWidget {
  const SignInPageWidget({super.key, this.api});
  final GaboyaApi? api;

  static String routeName = 'SignInPage';
  static String routePath = '/connexion';

  @override
  State<SignInPageWidget> createState() => _SignInPageWidgetState();
}

class _SignInPageWidgetState extends State<SignInPageWidget> {
  late SignInPageModel _model;

  final _otp = TextEditingController();
  String? _challenge;
  String _delivery = '';
  bool _busy = false;

  Future<void> _submit() async {
    if (_busy || !_model.formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
    });
    try {
      if (_challenge == null) {
        final result =
            await _api.requestOtp(_model.phoneNumberTextController!.text);
        if (!mounted) return;
        setState(() {
          _challenge = result['challenge_id'];
          _delivery = result['delivery'];
        });
      } else {
        if (!RegExp(r'^\d{6}$').hasMatch(_otp.text)) {
          throw ApiException('Saisissez les 6 chiffres du code.');
        }
        await _api.verifyOtp(_challenge!, _otp.text);
        if (!mounted) return;
        context.goNamed('PayTaxiPage');
      }
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
    _model = createModel(context, () => SignInPageModel());

    _model.phoneNumberTextController ??= TextEditingController();
    _model.phoneNumberFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _otp.dispose();
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
            'Connexion',
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
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment:
                              (FFMainAxisAlignment.start).flutterValue,
                          crossAxisAlignment:
                              (FFCrossAxisAlignment.start).flutterValue,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Icon(
                              Icons.lock_outline,
                              color: FlutterFlowTheme.of(context).primary,
                              size: 32.0,
                            ),
                            Text(
                              'Votre numéro, votre compte.',
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
                              'Nous vous enverrons un code de vérification pour sécuriser votre accès.',
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
                          ].divide(SizedBox(height: 12.0)),
                        ),
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
                            controller: _model.phoneNumberTextController,
                            enabled: _challenge == null && !_busy,
                            focusNode: _model.phoneNumberFocusNode,
                            obscureText: false,
                            decoration: InputDecoration(
                              labelText: 'Numéro de téléphone',
                              hintText: '+241 77 12 34 56',
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
                              prefixIcon: Icon(
                                Icons.phone,
                              ),
                            ),
                            style: TextStyle(),
                            maxLines: null,
                            keyboardType: (FFKeyboardType.phone).flutterValue,
                            validator: _model.phoneNumberTextControllerValidator
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
                                _delivery == 'test_inbox'
                                    ? 'Environnement de test isolé : récupérez le code dans la boîte SMS locale. Aucun SMS réel envoyé.'
                                    : 'Votre accès est sécurisé par un code SMS à usage unique. Ne partagez jamais ce code.',
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
                    if (_challenge != null) ...[
                      TextField(
                          controller: _otp,
                          keyboardType: TextInputType.number,
                          autofillHints: const [AutofillHints.oneTimeCode],
                          maxLength: 6,
                          decoration: const InputDecoration(
                              labelText: 'Code de vérification à 6 chiffres'),
                          onSubmitted: (_) => _submit()),
                      TextButton(
                          onPressed: _busy
                              ? null
                              : () {
                                  setState(() {
                                    _challenge = null;
                                    _otp.clear();
                                    _delivery = '';
                                  });
                                },
                          child: const Text(
                              'Modifier le numéro ou renvoyer le code')),
                    ],
                    FFButtonWidget(
                      onPressed: _busy ? null : _submit,
                      text: _busy
                          ? 'Patientez…'
                          : (_challenge == null
                              ? 'Recevoir le code'
                              : 'Vérifier et continuer'),
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
