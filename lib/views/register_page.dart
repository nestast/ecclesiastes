import 'package:flutter/material.dart';
import 'package:ecclesiaste/services/database_helper.dart';
import 'package:ecclesiaste/utils/constants.dart';
import 'package:ecclesiaste/utils/entite_types.dart';
import 'package:ecclesiaste/utils/password_utils.dart';
import 'package:ecclesiaste/utils/security_policy.dart';
import 'package:ecclesiaste/widgets/ena_logo.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  static const _blue = Color(0xFF1565C0);

  final _nomController = TextEditingController();
  final _identifiantController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  List<Map<String, dynamic>> _communautes = [];
  String? _communauteId;
  String? _ministere;
  String? _role;
  bool _accepteConditions = false;
  bool _obscure = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _chargerCommunautes();
  }

  Future<void> _chargerCommunautes() async {
    final data = await DatabaseHelper.instance.getCommunautesAvecChemin();
    if (mounted) setState(() => _communautes = data);
  }

  Future<void> _creerCompte() async {
    final nom = _nomController.text.trim();
    final identifiant = _identifiantController.text.trim();
    final pwd = _passwordController.text;

    if (nom.isEmpty || identifiant.isEmpty) {
      _msg('Nom complet et identifiant sont obligatoires.');
      return;
    }
    if (_communauteId == null || _ministere == null || _role == null) {
      _msg('Sélectionnez le niveau (communauté), le ministère et le rôle.');
      return;
    }
    if (!_accepteConditions) {
      _msg('Vous devez accepter les conditions de sécurité.');
      return;
    }
    final erreur = SecurityPolicy.validate(pwd);
    if (erreur != null) {
      _msg(erreur);
      return;
    }
    if (pwd != _confirmController.text) {
      _msg('Les mots de passe ne correspondent pas.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (await DatabaseHelper.instance.identifiantExiste(identifiant)) {
        _msg('Cet identifiant est déjà utilisé.');
        return;
      }
      await DatabaseHelper.instance.creerUtilisateur(
        identifiant: identifiant,
        motDePasseHash: hashPassword(pwd),
        nomComplet: nom,
        role: _role == 'Membre' ? 'MEMBRE' : 'RESPONSABLE',
        entiteId: _communauteId,
        typeEntite: EntiteTypes.communaute,
        roleLabel: _role,
        ministere: _ministere,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Compte créé ! Un responsable doit valider votre compte sous 3 jours, sinon vous devrez vous réinscrire.'),
          duration: Duration(seconds: 5),
        ),
      );
      Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _msg(String t) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _blue,
        elevation: 0,
        title: const Text('Nouveau compte', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
        child: Column(
          children: [
            const EnaLogo(size: 72),
            const SizedBox(height: 16),
            TextField(
              controller: _nomController,
              decoration: const InputDecoration(labelText: 'Nom complet', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _identifiantController,
              decoration: const InputDecoration(labelText: 'Identifiant', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            _labeledDropdown(
              label: 'Niveau (communauté)',
              value: _communauteId,
              hint: 'Choisir votre communauté',
              items: _communautes
                  .map((c) => DropdownMenuItem<String>(
                        value: c['id'] as String,
                        child: Text(c['chemin'] as String, overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _communauteId = v),
            ),
            const SizedBox(height: 14),
            _labeledDropdown(
              label: 'Ministère',
              value: _ministere,
              items: AppConstants.commissions
                  .map((m) => DropdownMenuItem<String>(value: m, child: Text(m, overflow: TextOverflow.ellipsis)))
                  .toList(),
              onChanged: (v) => setState(() => _ministere = v),
            ),
            const SizedBox(height: 14),
            _labeledDropdown(
              label: 'Rôle',
              value: _role,
              items: AppConstants.rolesConnexion
                  .map((r) => DropdownMenuItem<String>(value: r, child: Text(r)))
                  .toList(),
              onChanged: (v) => setState(() => _role = v),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _passwordController,
              obscureText: _obscure,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildSecurityHint(),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmController,
              obscureText: _obscure,
              decoration: const InputDecoration(
                labelText: 'Confirmer le mot de passe',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              value: _accepteConditions,
              onChanged: (v) => setState(() => _accepteConditions = v ?? false),
              title: const Text(
                "J'accepte les conditions de sécurité et la charte d'utilisation des données.",
                style: TextStyle(fontSize: 13),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                ),
                onPressed: _isLoading ? null : _creerCompte,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    : const Text('Créer mon compte', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityHint() {
    final score = SecurityPolicy.strengthScore(_passwordController.text);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: score,
          backgroundColor: Colors.grey.shade200,
          color: score > 0.7 ? Colors.green : (score > 0.4 ? Colors.orange : Colors.red),
        ),
        const SizedBox(height: 6),
        Text(
          SecurityPolicy.validate(_passwordController.text) ?? 'Force du mot de passe acceptable',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
        ),
      ],
    );
  }

  Widget _labeledDropdown({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          hint: hint != null ? Text(hint) : null,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          isExpanded: true,
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    _identifiantController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }
}
