import 'package:flutter/material.dart';
import 'package:ecclesiaste/services/auth_service.dart';
import 'package:ecclesiaste/services/database_helper.dart';
import 'package:ecclesiaste/services/entite_scope_service.dart';
import 'package:ecclesiaste/utils/constants.dart';
import 'package:ecclesiaste/utils/security_policy.dart';
import 'package:ecclesiaste/views/dashboard_page.dart';
import 'package:ecclesiaste/views/forgot_password_page.dart';
import 'package:ecclesiaste/views/register_page.dart';
import 'package:ecclesiaste/widgets/ena_logo.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const _blue = Color(0xFF1565C0);

  final _identifiantController = TextEditingController();
  final _passwordController = TextEditingController();

  List<Map<String, dynamic>> _communautes = [];
  String? _communauteId;
  String? _ministere;
  String? _role;
  bool _accepteConditions = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _chargerCommunautes();
  }

  Future<void> _chargerCommunautes() async {
    try {
      final data = await DatabaseHelper.instance.getCommunautesAvecChemin();
      if (mounted) setState(() => _communautes = data);
    } catch (e) {
      debugPrint('Erreur chargement communautés : $e');
    }
  }

  Future<void> _handleLogin() async {
    if (_communauteId == null || _ministere == null || _role == null) {
      _snack('Sélectionnez le niveau, le ministère et le rôle.');
      return;
    }
    if (_identifiantController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      _snack('Saisissez votre identifiant et mot de passe.');
      return;
    }
    if (!_accepteConditions) {
      _snack('Acceptez les conditions de sécurité pour continuer.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final success = await AuthService.login(
        identifiant: _identifiantController.text.trim(),
        password: _passwordController.text.trim(),
        communauteId: _communauteId!,
        ministere: _ministere,
        roleLabel: _role,
      );

      if (!mounted) return;
      if (success) {
        await EntiteScopeService.initFromCommunaute(_communauteId!);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardPage()),
        );
      } else {
        _snack('Identifiant, mot de passe ou communauté incorrect.');
      }
    } catch (e) {
      _snack(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _afficherConditions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Conditions de sécurité',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _blue),
            ),
            const SizedBox(height: 12),
            const Text(
              'En vous connectant, vous vous engagez à protéger les données des membres, '
              'à ne pas partager votre mot de passe et à signaler toute activité suspecte au responsable du district.',
            ),
            const SizedBox(height: 12),
            ...SecurityPolicy.rules.map(
              (r) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.shield_outlined, size: 18, color: _blue),
                    const SizedBox(width: 8),
                    Expanded(child: Text(r, style: const TextStyle(fontSize: 14))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: _blue, foregroundColor: Colors.white),
                onPressed: () {
                  setState(() => _accepteConditions = true);
                  Navigator.pop(ctx);
                },
                child: const Text("J'accepte"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              const EnaLogo(size: 120),
              const SizedBox(height: 28),
              const Text(
                'Bienvenue !',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: _blue,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'connectez-vous à votre communauté',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 36),
              _LoginDropdown(
                label: 'Niveau',
                hint: 'Communauté (église › champ › district)',
                value: _communauteId,
                items: _communautes
                    .map((c) => DropdownMenuItem<String>(
                          value: c['id'] as String,
                          child: Text(
                            c['chemin'] as String,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _communauteId = v),
              ),
              const SizedBox(height: 20),
              _LoginDropdown(
                label: 'Ministère',
                value: _ministere,
                items: AppConstants.commissions
                    .map((m) => DropdownMenuItem<String>(value: m, child: Text(m, overflow: TextOverflow.ellipsis)))
                    .toList(),
                onChanged: (v) => setState(() => _ministere = v),
              ),
              const SizedBox(height: 20),
              _LoginDropdown(
                label: 'Rôle',
                value: _role,
                items: AppConstants.rolesConnexion
                    .map((r) => DropdownMenuItem<String>(value: r, child: Text(r)))
                    .toList(),
                onChanged: (v) => setState(() => _role = v),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _identifiantController,
                decoration: InputDecoration(
                  labelText: 'Identifiant',
                  labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _afficherConditions,
                  icon: const Icon(Icons.info_outline, size: 18, color: _blue),
                  label: Text(
                    _accepteConditions ? 'Conditions acceptées' : 'Lire les conditions de sécurité',
                    style: TextStyle(
                      fontSize: 13,
                      color: _accepteConditions ? Colors.green.shade700 : _blue,
                    ),
                  ),
                ),
              ),
              CheckboxListTile(
                value: _accepteConditions,
                onChanged: (v) => setState(() => _accepteConditions = v ?? false),
                title: const Text(
                  "J'accepte les conditions de sécurité",
                  style: TextStyle(fontSize: 13),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                activeColor: _blue,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _blue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? const SizedBox(
                          width: 26,
                          height: 26,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Text(
                          'Se connecter',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
                      );
                    },
                    child: const Text(
                      'Mot de passe oublié ?',
                      style: TextStyle(color: Colors.black87, decoration: TextDecoration.underline),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterPage()),
                      );
                    },
                    child: const Text(
                      'Créer un nouveau compte',
                      style: TextStyle(color: Colors.black87, decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _identifiantController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

class _LoginDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final String? hint;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;

  const _LoginDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          hint: hint != null ? Text(hint!, style: const TextStyle(color: Colors.grey)) : null,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
          ),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
