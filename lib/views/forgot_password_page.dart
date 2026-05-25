import 'package:flutter/material.dart';
import 'package:ecclesiaste/services/database_helper.dart';
import 'package:ecclesiaste/utils/password_utils.dart';
import 'package:ecclesiaste/utils/security_policy.dart';
import 'package:ecclesiaste/widgets/ena_logo.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  static const _blue = Color(0xFF1565C0);

  final _identifiantController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;

  void _reinitialiser() async {
    final identifiant = _identifiantController.text.trim();
    final pwd = _passwordController.text;
    final confirm = _confirmController.text;

    if (identifiant.isEmpty) {
      _message('Indiquez votre identifiant.');
      return;
    }
    final erreur = SecurityPolicy.validate(pwd);
    if (erreur != null) {
      _message(erreur);
      return;
    }
    if (pwd != confirm) {
      _message('Les mots de passe ne correspondent pas.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final existe = await DatabaseHelper.instance.identifiantExiste(identifiant);
      if (!existe) {
        _message('Aucun compte trouvé pour cet identifiant.');
        return;
      }
      await DatabaseHelper.instance.mettreAJourMotDePasse(identifiant, hashPassword(pwd));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mot de passe mis à jour. Vous pouvez vous connecter.')),
      );
      Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _blue,
        elevation: 0,
        title: const Text('Mot de passe oublié', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        child: Column(
          children: [
            const EnaLogo(size: 80),
            const SizedBox(height: 20),
            const Text(
              'Réinitialisation',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _blue),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choisissez un nouveau mot de passe conforme aux règles de sécurité.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 24),
            _SecurityRulesCard(password: _passwordController.text),
            const SizedBox(height: 20),
            TextField(
              controller: _identifiantController,
              decoration: const InputDecoration(
                labelText: 'Identifiant du compte',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _passwordController,
              obscureText: _obscure,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Nouveau mot de passe',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _confirmController,
              obscureText: _obscure,
              decoration: const InputDecoration(
                labelText: 'Confirmer le mot de passe',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                ),
                onPressed: _isLoading ? null : _reinitialiser,
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Enregistrer le nouveau mot de passe', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _identifiantController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }
}

class _SecurityRulesCard extends StatelessWidget {
  final String password;

  const _SecurityRulesCard({required this.password});

  @override
  Widget build(BuildContext context) {
    final checks = [
      ('8+ caractères', password.length >= SecurityPolicy.minLength),
      ('Majuscule', RegExp(r'[A-Z]').hasMatch(password)),
      ('Minuscule', RegExp(r'[a-z]').hasMatch(password)),
      ('Chiffre', RegExp(r'[0-9]').hasMatch(password)),
      ('Spécial', RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\/]').hasMatch(password)),
    ];

    return Card(
      color: const Color(0xFFF5F8FC),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Conditions de sécurité', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...checks.map(
              (c) => Row(
                children: [
                  Icon(
                    c.$2 ? Icons.check_circle : Icons.radio_button_unchecked,
                    size: 18,
                    color: c.$2 ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(c.$1, style: TextStyle(color: c.$2 ? Colors.green.shade800 : Colors.grey.shade700)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
