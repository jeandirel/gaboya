import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'geo_empty_state_model.dart';
export 'geo_empty_state_model.dart';

/// DSL component GeoEmptyState
class GeoEmptyStateWidget extends StatefulWidget {
  const GeoEmptyStateWidget({
    super.key,
    this.message,
  });

  final String? message;

  @override
  State<GeoEmptyStateWidget> createState() => _GeoEmptyStateWidgetState();
}

class _GeoEmptyStateWidgetState extends State<GeoEmptyStateWidget> {
  late GeoEmptyStateModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => GeoEmptyStateModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(14.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          widget!.message!,
          style: FlutterFlowTheme.of(context).brandCaption.override(
                font: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  fontStyle:
                      FlutterFlowTheme.of(context).brandCaption.fontStyle,
                ),
                color: FlutterFlowTheme.of(context).secondaryText,
                fontSize: 12.0,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w500,
                fontStyle: FlutterFlowTheme.of(context).brandCaption.fontStyle,
              ),
        ),
      ),
    );
  }
}
