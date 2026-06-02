import 'package:flutter/material.dart';
import '../models/report_type.dart';
import '../models/report_base.dart';
import '../services/report_provider.dart';
import '../widgets/report_preview_widget.dart';

class ReportListScreen extends StatefulWidget {
  const ReportListScreen({Key? key}) : super(key: key);

  @override
  State<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  late InteractiveReportProvider _reportProvider;
  String _searchQuery = '';
  String? _selectedTypeFilter = 'all';

  @override
  void initState() {
    super.initState();
    _reportProvider = InteractiveReportProvider();
  }

  void _openReportDetails(ReportBase report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) => ReportPreviewWidget(
          report: report,
          onEdit: () {
            Navigator.pop(context);
            _editReport(report);
          },
          onDelete: () {
            Navigator.pop(context);
            _deleteReport(report.id);
          },
          onExport: () {
            _exportReport(report);
          },
        ),
      ),
    );
  }

  void _editReport(ReportBase report) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonctionnalité d\'édition en cours de développement')),
    );
  }

  Future<void> _deleteReport(String reportId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le rapport'),
        content: const Text('Êtes-vous sûr de vouloir supprimer ce rapport ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await _reportProvider.deleteReport(reportId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rapport supprimé')),
        );
      }
    }
  }

  void _exportReport(ReportBase report) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export en cours...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Rapports'),
        elevation: 0,
        backgroundColor: Colors.blue.shade700,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterBar(),
          Expanded(
            child: _buildReportsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/create-report');
        },
        icon: const Icon(Icons.add),
        label: const Text('Nouveau Rapport'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) {
          setState(() => _searchQuery = value);
          _reportProvider.searchReports(value);
        },
        decoration: InputDecoration(
          hintText: 'Chercher un rapport...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() => _searchQuery = '');
                    _reportProvider.searchReports('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildFilterChip('all', 'Tous'),
          ...ReportType.values.map((type) =>
              _buildFilterChip(type.name, type.label)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedTypeFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedTypeFilter = value);
          _reportProvider.filterByType(value == 'all' ? null : value);
        },
        backgroundColor: Colors.grey.shade200,
        selectedColor: Colors.blue,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildReportsList() {
    return AnimatedBuilder(
      animation: _reportProvider,
      builder: (context, _) {
        final provider = _reportProvider;
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(provider.error!),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    provider.reloadReports();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        if (provider.filteredReports.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_open, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text('Aucun rapport trouvé'),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: provider.filteredReports.length,
          itemBuilder: (context, index) {
            final report = provider.filteredReports[index];
            return _buildReportCard(report);
          },
        );
      },
    );
  }

  Widget _buildReportCard(ReportBase report) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: () => _openReportDetails(report),
        leading: CircleAvatar(
          backgroundColor: _getTypeColor(report.type),
          child: Icon(
            _getTypeIcon(report.type),
            color: Colors.white,
          ),
        ),
        title: Text(
          report.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(report.author, maxLines: 1, overflow: TextOverflow.ellipsis),
            Row(
              children: [
                Text(
                  report.type.label,
                  style: TextStyle(
                    fontSize: 12,
                    color: _getTypeColor(report.type),
                  ),
                ),
                const Spacer(),
                if (report.audioSegments.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.audio_file, size: 16, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        report.audioSegments.length.toString(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
        trailing: Icon(
          report.isCompleted ? Icons.check_circle : Icons.schedule,
          color: report.isCompleted ? Colors.green : Colors.orange,
        ),
      ),
    );
  }

  Color _getTypeColor(ReportType type) {
    switch (type) {
      case ReportType.meeting:
        return Colors.blue;
      case ReportType.visit:
        return Colors.orange;
      case ReportType.divineService:
        return Colors.purple;
      case ReportType.activity:
        return Colors.green;
      case ReportType.financial:
        return Colors.teal;
      case ReportType.disciplinary:
        return Colors.red;
      case ReportType.other:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(ReportType type) {
    switch (type) {
      case ReportType.meeting:
        return Icons.groups;
      case ReportType.visit:
        return Icons.place;
      case ReportType.divineService:
        return Icons.church;
      case ReportType.activity:
        return Icons.event;
      case ReportType.financial:
        return Icons.attach_money;
      case ReportType.disciplinary:
        return Icons.gavel;
      case ReportType.other:
        return Icons.description;
    }
  }

  @override
  void dispose() {
    _reportProvider.dispose();
    super.dispose();
  }
}
