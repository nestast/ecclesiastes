import 'package:flutter/material.dart';
import 'package:ecclesiaste/services/database_helper.dart';
import 'package:ecclesiaste/utils/entite_types.dart';
import 'package:ecclesiaste/views/gestion_membres_page.dart';

class HierarchiePage extends StatefulWidget {
  final String? parentId;
  final String title;
  final String typeEntite;

  const HierarchiePage({
    super.key,
    this.parentId,
    this.title = "Hiérarchie Néo-Apostolique",
    this.typeEntite = EntiteTypes.racine,
  });

  @override
  State<HierarchiePage> createState() => _HierarchiePageState();
}

class _HierarchiePageState extends State<HierarchiePage> {
  List<Map<String, dynamic>> _entites = [];
  bool _isLoading = true;

  final List<String> commissionsKSO = [
    "Jeunesse",
    "École du Dimanche",
    "Chorale & Musique",
    "Femmes",
    "Anciens / Sages",
    "Administration & Finances",
  ];

  @override
  void initState() {
    super.initState();
    _loadEntites();
  }

  Future<void> _loadEntites() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final childType = EntiteTypes.enfantDe(widget.typeEntite);
      if (childType == null) {
        if (mounted) setState(() => _entites = []);
        return;
      }

      final parentId = widget.typeEntite == EntiteTypes.racine ? null : widget.parentId;
      final data = await DatabaseHelper.instance.getSubEntites(parentId, childType);

      final normalized = data
          .map((e) => {...e, 'type': EntiteTypes.normalize(e['type']?.toString())})
          .toList();

      if (mounted) setState(() => _entites = normalized);
    } catch (e) {
      debugPrint("Erreur hiérarchie : $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  IconData _iconForType(String type) {
    switch (EntiteTypes.normalize(type)) {
      case EntiteTypes.egliseTerritoriale:
        return Icons.account_balance;
      case EntiteTypes.champApostolique:
        return Icons.public;
      case EntiteTypes.district:
        return Icons.corporate_fare;
      case EntiteTypes.communaute:
        return Icons.location_city;
      default:
        return Icons.account_tree;
    }
  }

  void _showApostleProfile(BuildContext context, String nomEntite) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profil d\'Apôtre'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: const Icon(Icons.account_circle, color: Colors.blue),
                title: const Text('Apôtre Mpaka Gilbert Nzakimuena'),
                subtitle: const Text('Né en 1966\nChamp KSE depuis 2022'),
              ),
              const Divider(),
              _profileItem(Icons.verified_user, 'Ordination', '10 juillet 2022 par Apôtre-patriarche Jean-Luc Schneider'),
              _profileItem(Icons.map, 'Champ apostolique', 'Kinshasa Sud-Est (KSE)'),
              _profileItem(Icons.event, 'Actions récentes', 
                '• Service divin avec Saint-Scellement à Totalana (02/2026)\n'
                '• Séminaire pour choristes à Punda (11/2025)\n'
                '• Représentations officielles avec l\'état'
              ),
              _profileItem(Icons.leaderboard, 'Style de leadership', 
                'Engagement communautaire fort :\n'
                '- Concours enfants\n'
                '- Séminaires ministres\n'
                '- Visites régulières'
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _profileItem(IconData icon, String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blueGrey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(content, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _colorForType(String type) {
    switch (EntiteTypes.normalize(type)) {
      case EntiteTypes.egliseTerritoriale:
        return Colors.indigo;
      case EntiteTypes.champApostolique:
        return Colors.teal;
      case EntiteTypes.district:
        return Colors.orange;
      case EntiteTypes.communaute:
        return Colors.blue;
      default:
        return Colors.blueGrey;
    }
  }

  void _showCommissionsBottomSheet(BuildContext context, String entiteId, String nomEntite) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.blueGrey[50],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Text(
              "Activités & Commissions :\n$nomEntite",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: commissionsKSO.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final c = commissionsKSO[index];
                return ListTile(
                  leading: const Icon(Icons.group_work, color: Colors.blueAccent),
                  title: Text(c, style: const TextStyle(fontWeight: FontWeight.w500)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GestionMembresPage(
                          commissionName: c,
                          entiteId: entiteId,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final childLabel = EntiteTypes.enfantDe(widget.typeEntite);
    final emptyHint = childLabel != null
        ? "Aucun ${EntiteTypes.label(childLabel).toLowerCase()} sous ${widget.title}"
        : "Aucune sous-entité";

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _entites.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.account_tree_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(emptyHint, style: TextStyle(color: Colors.grey[600], fontSize: 15)),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _entites.length,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemBuilder: (context, index) {
                    final entite = _entites[index];
                    final id = entite['id']?.toString() ?? '';
                    final nom = entite['nom']?.toString() ?? 'Sans nom';
                    final type = EntiteTypes.normalize(entite['type']?.toString());
                    final responsable = entite['responsable_nom']?.toString() ?? 'À définir';
                    final color = _colorForType(type);

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: color.withValues(alpha: 0.12),
                          child: Icon(_iconForType(type), color: color),
                        ),
                        title: Text(nom, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        subtitle: Text(
                          "${EntiteTypes.label(type)} • Responsable : $responsable",
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Icon(
                          EntiteTypes.peutNaviguerVersEnfants(type)
                              ? Icons.arrow_forward_ios
                              : Icons.assignment_outlined,
                          size: 16,
                          color: Colors.grey,
                        ),
                        onTap: () {
                          if (type == EntiteTypes.communaute) {
                            _showCommissionsBottomSheet(context, id, nom);
                          } else if (type == EntiteTypes.champApostolique && nom.contains("Kinshasa Sud-Est")) {
                            _showApostleProfile(context, nom);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => HierarchiePage(
                                  parentId: id,
                                  title: "${EntiteTypes.label(type)} : $nom",
                                  typeEntite: type,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
