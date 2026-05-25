import 'package:flutter/material.dart';
import 'package:ecclesiaste/services/database_helper.dart';
import 'package:ecclesiaste/services/entite_scope_service.dart';
import 'package:ecclesiaste/utils/entite_types.dart';
import 'package:ecclesiaste/widgets/dashboard/dashboard_shared.dart';

/// Trois pills Champ / District / Communauté branchées sur la table [entites].
class EntiteHierarchyPills extends StatefulWidget {
  final VoidCallback? onScopeChanged;

  const EntiteHierarchyPills({super.key, this.onScopeChanged});

  @override
  State<EntiteHierarchyPills> createState() => _EntiteHierarchyPillsState();
}

class _EntiteHierarchyPillsState extends State<EntiteHierarchyPills> {
  List<Map<String, dynamic>> _champs = [];
  List<Map<String, dynamic>> _districts = [];
  List<Map<String, dynamic>> _communautes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    setState(() => _loading = true);
    await EntiteScopeService.initFromSession();
    _champs = await DatabaseHelper.instance.getEntitesByType(EntiteTypes.champApostolique);
    if (_champs.isEmpty) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    if (EntiteScopeService.champId == null ||
        !_champs.any((c) => c['id'].toString() == EntiteScopeService.champId)) {
      EntiteScopeService.champId = _champs.first['id'].toString();
    }
    await _loadDistricts(keepSelection: false);
    if (mounted) {
      setState(() => _loading = false);
      widget.onScopeChanged?.call();
    }
  }

  Future<void> _loadDistricts({required bool keepSelection}) async {
    final champId = EntiteScopeService.champId;
    if (champId == null) return;
    _districts = await DatabaseHelper.instance.getSubEntites(champId, EntiteTypes.district);
    if (_districts.isEmpty) {
      EntiteScopeService.setScope(champ: champId);
      _communautes = [];
      return;
    }
    if (!keepSelection ||
        EntiteScopeService.districtId == null ||
        !_districts.any((d) => d['id'].toString() == EntiteScopeService.districtId)) {
      EntiteScopeService.districtId = _districts.first['id'].toString();
    }
    await _loadCommunautes(keepSelection: keepSelection);
  }

  Future<void> _loadCommunautes({required bool keepSelection}) async {
    final districtId = EntiteScopeService.districtId;
    if (districtId == null) return;
    _communautes = await DatabaseHelper.instance.getSubEntites(districtId, EntiteTypes.communaute);
    if (_communautes.isEmpty) {
      EntiteScopeService.setScope(
        champ: EntiteScopeService.champId,
        district: districtId,
      );
      return;
    }
    if (!keepSelection ||
        EntiteScopeService.communauteId == null ||
        !_communautes.any((c) => c['id'].toString() == EntiteScopeService.communauteId)) {
      EntiteScopeService.communauteId = _communautes.first['id'].toString();
    }
    EntiteScopeService.setScope(
      champ: EntiteScopeService.champId,
      district: districtId,
      communaute: EntiteScopeService.communauteId,
    );
  }

  void _notify() {
    if (mounted) setState(() {});
    widget.onScopeChanged?.call();
  }

  Future<void> _selectChamp(int index) async {
    EntiteScopeService.champId = _champs[index]['id'].toString();
    await _loadDistricts(keepSelection: false);
    _notify();
  }

  Future<void> _selectDistrict(int index) async {
    EntiteScopeService.districtId = _districts[index]['id'].toString();
    await _loadCommunautes(keepSelection: false);
    _notify();
  }

  void _selectCommunaute(int index) {
    EntiteScopeService.communauteId = _communautes[index]['id'].toString();
    EntiteScopeService.setScope(
      champ: EntiteScopeService.champId,
      district: EntiteScopeService.districtId,
      communaute: EntiteScopeService.communauteId,
    );
    _notify();
  }

  int _indexOf(List<Map<String, dynamic>> list, String? id) {
    if (id == null) return 0;
    final i = list.indexWhere((e) => e['id'].toString() == id);
    return i >= 0 ? i : 0;
  }

  List<String> _labelsFor(List<Map<String, dynamic>> list, String prefix) {
    return list.map((e) => EntiteScopeService.pillLabel(prefix, e['nom']?.toString() ?? '—')).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        height: 40,
        child: Center(child: LinearProgressIndicator(minHeight: 2)),
      );
    }
    if (_champs.isEmpty) {
      return Text(
        'Aucune entité en base. Créez la hiérarchie dans Config.',
        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EntityPillRow(
          labels: _labelsFor(_champs, 'Champ'),
          selectedIndex: _indexOf(_champs, EntiteScopeService.champId),
          onSelected: _selectChamp,
        ),
        if (_districts.isNotEmpty) ...[
          const SizedBox(height: 10),
          EntityPillRow(
            labels: _labelsFor(_districts, 'District'),
            selectedIndex: _indexOf(_districts, EntiteScopeService.districtId),
            onSelected: _selectDistrict,
          ),
        ],
        if (_communautes.isNotEmpty) ...[
          const SizedBox(height: 10),
          EntityPillRow(
            labels: _labelsFor(_communautes, 'Communauté'),
            selectedIndex: _indexOf(_communautes, EntiteScopeService.communauteId),
            onSelected: _selectCommunaute,
          ),
        ],
      ],
    );
  }
}

/// Filtre districts pour le dashboard ministre (données [entites]).
class DistrictFilterPills extends StatefulWidget {
  final ValueChanged<String?> onDistrictChanged;

  const DistrictFilterPills({super.key, required this.onDistrictChanged});

  @override
  State<DistrictFilterPills> createState() => _DistrictFilterPillsState();
}

class _DistrictFilterPillsState extends State<DistrictFilterPills> {
  List<Map<String, dynamic>> _districts = [];
  int _selectedIndex = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = await DatabaseHelper.instance.getEntitesByType(EntiteTypes.district);
    if (mounted) {
      setState(() {
        _districts = all;
        _loading = false;
      });
      widget.onDistrictChanged(null);
    }
  }

  List<String> get _labels {
    final names = _districts.map((d) => d['nom']?.toString() ?? '—').toList();
    return ['Tout', ...names];
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(height: 40, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
    }
    if (_districts.isEmpty) {
      return const Text('Aucun district enregistré.', style: TextStyle(color: Colors.grey));
    }
    return EntityPillRow(
      labels: _labels,
      selectedIndex: _selectedIndex.clamp(0, _labels.length - 1),
      onSelected: (i) {
        setState(() => _selectedIndex = i);
        widget.onDistrictChanged(i == 0 ? null : _districts[i - 1]['id'].toString());
      },
    );
  }
}
