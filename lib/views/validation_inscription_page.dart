import 'package:flutter/material.dart';
import 'package:ecclesiaste/services/admin_service.dart';
import 'package:ecclesiaste/services/database_helper.dart';

class ValidationInscriptionPage extends StatefulWidget {
  final bool isSuperAdmin;
  final String? entiteId;

  const ValidationInscriptionPage({
    super.key, 
    required this.isSuperAdmin, 
    this.entiteId
  });

  @override
  State<ValidationInscriptionPage> createState() => _ValidationInscriptionPageState();
}

class _ValidationInscriptionPageState extends State<ValidationInscriptionPage> {
  List<Map<String, dynamic>> _membresDemandes = [];
  List<Map<String, dynamic>> _utilisateursDemandes = [];
  List<Map<String, dynamic>> _entites = [];
  String? _filtreEntiteId;
  bool _isLoading = true;
  bool _isLoadingEntites = true;

  @override
  void initState() {
    super.initState();
    _loadEntites();
    _fetchDemandes();
  }

  Future<void> _loadEntites() async {
    if (!widget.isSuperAdmin) return;
    setState(() => _isLoadingEntites = true);
    try {
      final data = await DatabaseHelper.instance.getAllEntites();
      if (mounted) {
        setState(() {
          _entites = data;
          _isLoadingEntites = false;
        });
      }
    } catch (e) {
      debugPrint("Erreur chargement entités : $e");
      if (mounted) setState(() => _isLoadingEntites = false);
    }
  }

  void _fetchDemandes() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      List<Map<String, dynamic>> membresData;
      List<Map<String, dynamic>> usersData;

      final currentEntite = widget.isSuperAdmin 
          ? (_filtreEntiteId == 'TOUS' ? null : _filtreEntiteId) 
          : widget.entiteId;

      if (widget.isSuperAdmin && (_filtreEntiteId == null || _filtreEntiteId == 'TOUS')) {
        membresData = await AdminService.getAllPending();
        usersData = await AdminService.getPendingUtilisateurs(entiteId: null);
      } else {
        membresData = await AdminService.getPendingByEntite(currentEntite!);
        usersData = await AdminService.getPendingUtilisateurs(entiteId: currentEntite);
      }

      if (mounted) {
        setState(() {
          _membresDemandes = membresData;
          _utilisateursDemandes = usersData;
        });
      }
    } catch (e) {
      debugPrint("Erreur lors de la récupération : $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isSuperAdmin ? "Validations Globales" : "Validations Locales"),
          backgroundColor: Colors.blueGrey[900],
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                _loadEntites();
                _fetchDemandes();
              },
            ),
          ],
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.orange,
            tabs: [
              Tab(icon: Icon(Icons.security), text: "Comptes Utilisateurs"),
              Tab(icon: Icon(Icons.people), text: "Fiches Membres"),
            ],
          ),
        ),
        body: Column(
          children: [
            if (widget.isSuperAdmin)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _isLoadingEntites
                    ? const Center(child: SizedBox(height: 40, child: CircularProgressIndicator()))
                    : DropdownButtonFormField<String>(
                        initialValue: _filtreEntiteId,
                        hint: const Text("Filtrer par entité"),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: [
                          const DropdownMenuItem<String>(value: 'TOUS', child: Text("Toutes les entités")),
                          ..._entites.map((e) => DropdownMenuItem<String>(
                            value: e['id'].toString(),
                            child: Text("${e['nom']} (${e['type']})"),
                          )),
                        ],
                        onChanged: (val) {
                          setState(() => _filtreEntiteId = val);
                          _fetchDemandes();
                        },
                      ),
              ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      children: [
                        _buildUtilisateursTab(),
                        _buildMembresTab(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUtilisateursTab() {
    if (_utilisateursDemandes.isEmpty) {
      return const Center(child: Text("Aucun compte utilisateur en attente"));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: _utilisateursDemandes.length,
      itemBuilder: (context, index) {
        final u = _utilisateursDemandes[index];
        final dateInsc = DateTime.tryParse(u['date_inscription'] ?? "") ?? DateTime.now();
        final diffDays = DateTime.now().difference(dateInsc).inDays;
        final estUrgent = diffDays >= 2; // Approche de la limite de 3 jours

        return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 12),
          color: estUrgent ? Colors.red[50] : Colors.white,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: estUrgent ? Colors.red : Colors.blueAccent,
              child: const Icon(Icons.admin_panel_settings, color: Colors.white),
            ),
            title: Text(
              u['nom_complet'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Rôle : ${u['role_label'] ?? 'Non défini'}"),
                Text("Ministère : ${u['ministere'] ?? 'Aucun'}"),
                Text("Identifiant : ${u['identifiant']}"),
                const SizedBox(height: 4),
                Text(
                  "Temps restant : ${3 - diffDays} jour(s) avant expiration",
                  style: TextStyle(
                    color: estUrgent ? Colors.red : Colors.grey[600],
                    fontWeight: estUrgent ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check_circle, color: Colors.green, size: 30),
                  onPressed: () async {
                    await AdminService.confirmerUtilisateur(u['id']);
                    if (!mounted) return;
                    _fetchDemandes();
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      const SnackBar(content: Text("Compte utilisateur confirmé avec succès")),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.red, size: 30),
                  onPressed: () async {
                    final confirm = await _showDeleteDialog("Rejeter le compte ?");
                    if (confirm == true) {
                      await AdminService.rejeterUtilisateur(u['id']);
                      if (mounted) _fetchDemandes();
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMembresTab() {
    if (_membresDemandes.isEmpty) {
      return const Center(child: Text("Aucune fiche de membre en attente"));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: _membresDemandes.length,
      itemBuilder: (context, index) {
        final d = _membresDemandes[index];
        final dateInsc = DateTime.tryParse(d['date_inscription'] ?? "") ?? DateTime.now();
        final joursPasses = DateTime.now().difference(dateInsc).inDays;
        final estUrgent = joursPasses >= 4;

        return Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 12),
          color: estUrgent ? Colors.red[50] : Colors.white,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: estUrgent ? Colors.red : Colors.blueGrey,
              child: const Icon(Icons.person, color: Colors.white),
            ),
            title: Text(
              "${d['nom']} ${d['prenom'] ?? ''}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Commission : ${d['commission']}"),
                const SizedBox(height: 4),
                Text(
                  "Attente : $joursPasses jour(s)",
                  style: TextStyle(
                    color: estUrgent ? Colors.red : Colors.grey[600],
                    fontWeight: estUrgent ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check_circle, color: Colors.green, size: 30),
                  onPressed: () async {
                    await AdminService.confirmerMembre(d['id']);
                    if (!mounted) return;
                    _fetchDemandes();
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      const SnackBar(content: Text("Membre confirmé avec succès")),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.red, size: 30),
                  onPressed: () async {
                    final confirm = await _showDeleteDialog("Rejeter la fiche membre ?");
                    if (confirm == true) {
                      await AdminService.rejeterMembre(d['id']);
                      if (mounted) _fetchDemandes();
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool?> _showDeleteDialog(String title) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: const Text("Cette action supprimera définitivement la demande."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Annuler")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true), 
            child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
