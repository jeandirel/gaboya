import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/services/gaboya_api.dart';

class DriverAccountPage extends StatefulWidget {
  const DriverAccountPage({super.key});
  @override
  State<DriverAccountPage> createState() => _DriverAccountPageState();
}

class _DriverAccountPageState extends State<DriverAccountPage> {
  final _name = TextEditingController();
  final _plate = TextEditingController();
  final _description = TextEditingController();
  final _form = GlobalKey<FormState>();
  Map<String, dynamic>? _driver;
  List<Map<String, dynamic>> _queue = [];
  bool _busy = true;
  bool _loaded = false;
  String? _error;
  final _api = GaboyaApi.instance;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _name.dispose();
    _plate.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _busy = true;
      _error = null;
      _loaded = false;
    });
    try {
      await _api.loadProfile();
      final driver = await _api.myDriver();
      final queue = _api.roles.contains('admin')
          ? await _api.reviewQueue()
          : <Map<String, dynamic>>[];
      if (!mounted) return;
      setState(() {
        _driver = driver;
        _queue = queue;
        _name.text =
            driver?['display_name'] ?? _api.user?['display_name'] ?? '';
        _plate.text = driver?['vehicle']?['license_plate'] ?? '';
        _description.text = driver?['vehicle']?['description'] ?? '';
        _loaded = true;
      });
    } on ApiException catch (error) {
      if (mounted)
        setState(() {
          _error = error.message;
        });
    } finally {
      if (mounted)
        setState(() {
          _busy = false;
        });
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _api.saveDriver(
          _name.text.trim(), _plate.text.trim(), _description.text.trim(),
          update: _driver != null);
      await _load();
    } on ApiException catch (error) {
      if (mounted)
        setState(() {
          _error = error.message;
        });
    } finally {
      if (mounted)
        setState(() {
          _busy = false;
        });
    }
  }

  Future<void> _review(Map<String, dynamic> driver, String status) async {
    final note = TextEditingController();
    final accepted = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(status == 'approved'
                  ? 'Approuver ce chauffeur'
                  : 'Suspendre ce chauffeur'),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(
                    '${driver['display_name']} � ${driver['vehicle']?['license_plate'] ?? ''}'),
                TextField(
                    controller: note,
                    maxLength: 500,
                    decoration:
                        const InputDecoration(labelText: 'Motif du contr�le')),
              ]),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Annuler')),
                TextButton(
                    onPressed: () {
                      if (note.text.trim().length >= 3)
                        Navigator.pop(context, true);
                    },
                    child: const Text('Confirmer'))
              ],
            ));
    final reason = note.text.trim();
    note.dispose();
    if (accepted != true || !mounted) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _api.reviewDriver(driver['driver_id'], status, reason);
      await _load();
    } on ApiException catch (error) {
      if (mounted)
        setState(() {
          _error = error.message;
        });
    } finally {
      if (mounted)
        setState(() {
          _busy = false;
        });
    }
  }

  String? _required(String? value) =>
      (value?.trim().length ?? 0) < 3 ? 'Au moins 3 caract�res' : null;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    const statuses = {
      'pending_review': 'En cours de v�rification',
      'approved': 'Chauffeur approuv�',
      'suspended': 'Compte chauffeur suspendu',
      'rejected': 'Dossier � corriger'
    };
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
          title: const Text('Mon compte chauffeur'),
          backgroundColor: theme.primary,
          actions: [
            IconButton(
                onPressed: _busy ? null : _load,
                icon: const Icon(Icons.refresh))
          ]),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            if (_busy) const LinearProgressIndicator(),
            if (_error != null)
              Text(_error!, style: TextStyle(color: theme.error)),
            if (_loaded) ...[
              Text(statuses[_driver?['status']] ?? 'Devenir chauffeur GABOYA',
                  style: theme.titleLarge),
              const SizedBox(height: 12),
              if (_driver?['qr_code'] != null)
                Card(
                    child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(children: [
                          QrImageView(
                              data: _driver!['qr_code'],
                              size: 220,
                              backgroundColor: Colors.white),
                          SelectableText(_driver!['qr_code']),
                          const Text(
                              'Ce QR identifie votre profil approuv�. Il ne confirme aucun paiement.'),
                        ]))),
              if ((_driver?['review_note'] ?? '').isNotEmpty)
                Text(_driver!['review_note']),
              Form(
                  key: _form,
                  child: Column(children: [
                    TextFormField(
                        controller: _name,
                        validator: _required,
                        maxLength: 160,
                        decoration:
                            const InputDecoration(labelText: 'Nom affich�')),
                    TextFormField(
                        controller: _plate,
                        validator: _required,
                        maxLength: 40,
                        decoration: const InputDecoration(
                            labelText: 'Immatriculation')),
                    TextFormField(
                        controller: _description,
                        validator: _required,
                        maxLength: 140,
                        decoration: const InputDecoration(
                            labelText: 'Marque, mod�le et couleur')),
                    const SizedBox(height: 16),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primary,
                            foregroundColor: theme.info),
                        onPressed: _busy || _driver?['status'] == 'suspended'
                            ? null
                            : _save,
                        child: Text(_driver == null
                            ? 'Soumettre mon dossier'
                            : 'Mettre � jour et soumettre')),
                    const Text(
                        'Toute modification du v�hicule ou du nom exige un nouveau contr�le et d�sactive le QR pr�c�dent.'),
                  ])),
              if (_api.roles.contains('admin')) ...[
                const SizedBox(height: 24),
                Text('Contr�le des chauffeurs', style: theme.titleLarge),
                for (final driver in _queue)
                  Card(
                      child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    '${driver['display_name']} � ${statuses[driver['status']]}'),
                                Text(
                                    '${driver['vehicle']?['license_plate']} � ${driver['vehicle']?['description']}'),
                                if (driver['user_id'] != _api.user?['id'])
                                  Wrap(children: [
                                    TextButton(
                                        onPressed: _busy
                                            ? null
                                            : () => _review(driver, 'approved'),
                                        child: const Text('Approuver')),
                                    TextButton(
                                        onPressed: _busy
                                            ? null
                                            : () =>
                                                _review(driver, 'suspended'),
                                        child: const Text('Suspendre')),
                                  ]),
                              ]))),
              ],
            ],
          ])),
    );
  }
}
