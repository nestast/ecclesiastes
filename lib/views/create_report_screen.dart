import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../models/report_type.dart';
import '../models/meeting_report.dart';
import '../models/visit_report.dart';
import '../models/divine_service_report.dart';
import '../models/audio_segment.dart';
import '../services/report_provider.dart';
import '../widgets/audio_recorder_widget.dart';
import '../widgets/interactive_report_form.dart';

final logger = Logger();

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({Key? key}) : super(key: key);

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen>
    with SingleTickerProviderStateMixin {
  late InteractiveReportProvider _reportProvider;
  ReportType? _selectedType;
  dynamic _currentReport;
  late TabController _tabController;
  final List<AudioSegment> _recordedAudios = [];
  final String _authorName = 'Admin';

  @override
  void initState() {
    super.initState();
    _reportProvider = InteractiveReportProvider();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _initializeReport(ReportType type) {
    setState(() {
      _selectedType = type;
      _recordedAudios.clear();

      switch (type) {
        case ReportType.meeting:
          _currentReport = MeetingReport(
            title: 'Rapport de Réunion',
            author: _authorName,
          );
          break;
        case ReportType.visit:
          _currentReport = VisitReport(
            title: 'Rapport de Visite',
            author: _authorName,
          );
          break;
        case ReportType.divineService:
          _currentReport = DivineServiceReport(
            title: 'Rapport de Service Divin',
            author: _authorName,
          );
          break;
        default:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${type.label} non encore supporté')),
          );
      }
    });
  }

  void _onAudioRecordingComplete(String filePath, Duration duration) {
    final audio = AudioSegment(
      filePath: filePath,
      duration: duration,
      section: _selectedType?.label ?? 'Enregistrement',
    );
    setState(() {
      _recordedAudios.add(audio);
      _currentReport?.addAudioSegment(audio);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Enregistrement sauvegardé: ${duration.inSeconds}s',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _saveReport() async {
    if (_currentReport == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un type de rapport')),
      );
      return;
    }

    // Mark as completed
    _currentReport.isCompleted = true;

    try {
      await _reportProvider.createReport(_currentReport);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rapport créé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un Rapport'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: _selectedType == null
          ? _buildTypeSelection()
          : _buildReportCreation(),
    );
  }

  Widget _buildTypeSelection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Sélectionnez le type de rapport',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          ...ReportType.values
              .where((t) =>
                  t != ReportType.other && t != ReportType.financial &&
                  t != ReportType.activity)
              .map((type) => _buildTypeCard(type))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildTypeCard(ReportType type) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _initializeReport(type),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getIcon(type),
                    size: 32,
                    color: _getColor(type),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          type.label,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          type.description,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: _getColor(type)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportCreation() {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.info), text: 'Infos'),
            Tab(icon: Icon(Icons.mic), text: 'Audio'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildInfoTab(),
              _buildAudioTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTab() {
    return InteractiveReportForm(
      report: _currentReport,
      onSave: _saveReport,
      onValidationErrors: (errors) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${errors.length} erreur(s) de validation'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }

  Widget _buildAudioTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Enregistrements Audio',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          AudioRecorderWidget(
            section: 'Discussion Principal',
            onRecordingComplete: _onAudioRecordingComplete,
            onRecordingStart: () {
              logger.i('Enregistrement commencé');
            },
          ),
          const SizedBox(height: 16),
          AudioRecorderWidget(
            section: 'Décisions & Actions',
            onRecordingComplete: _onAudioRecordingComplete,
          ),
          const SizedBox(height: 16),
          AudioRecorderWidget(
            section: 'Notes Additionnelles',
            onRecordingComplete: _onAudioRecordingComplete,
          ),
          if (_recordedAudios.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Enregistrements Effectués',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ..._recordedAudios.asMap().entries.map((entry) {
              final index = entry.key;
              final audio = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.audio_file, color: Colors.orange),
                  title: Text(audio.section),
                  subtitle: Text(
                    'Durée: ${audio.duration.inSeconds}s',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _recordedAudios.removeAt(index);
                        _currentReport?.removeAudioSegment(audio.id);
                      });
                    },
                  ),
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  IconData _getIcon(ReportType type) {
    switch (type) {
      case ReportType.meeting:
        return Icons.groups;
      case ReportType.visit:
        return Icons.place;
      case ReportType.divineService:
        return Icons.church;
      default:
        return Icons.description;
    }
  }

  Color _getColor(ReportType type) {
    switch (type) {
      case ReportType.meeting:
        return Colors.blue;
      case ReportType.visit:
        return Colors.orange;
      case ReportType.divineService:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _reportProvider.dispose();
    super.dispose();
  }
}
