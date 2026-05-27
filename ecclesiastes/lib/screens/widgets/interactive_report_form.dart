import 'package:flutter/material.dart';
import '../../models/report_base.dart';
import '../../models/meeting_report.dart';
import '../../services/validation_service.dart';

class InteractiveReportForm extends StatefulWidget {
  final ReportBase report;
  final VoidCallback onSave;
  final Function(List<String> errors)? onValidationErrors;

  const InteractiveReportForm({
    Key? key,
    required this.report,
    required this.onSave,
    this.onValidationErrors,
  }) : super(key: key);

  @override
  State<InteractiveReportForm> createState() => _InteractiveReportFormState();
}

class _InteractiveReportFormState extends State<InteractiveReportForm> {
  late final ValidationService _validationService;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _validationService = ValidationService();
  }

  void _validateAndSave() {
    final errors = widget.report.validate();
    if (errors.isEmpty) {
      widget.onSave();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rapport enregistré avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      widget.onValidationErrors?.call(errors);
      _showErrorDialog(errors);
    }
  }

  void _showErrorDialog(List<String> errors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erreurs de validation'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: errors
                .map((error) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: Colors.red)),
                  Expanded(child: Text(error)),
                ],
              ),
            ))
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildReportTypeSection(),
              const SizedBox(height: 20),
              _buildBasicInfoSection(),
              const SizedBox(height: 20),
              if (widget.report is MeetingReport) _buildMeetingSection(),
              const SizedBox(height: 20),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportTypeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Type de Rapport',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.report.type.label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.report.type.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations de Base',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: widget.report.title,
              decoration: InputDecoration(
                labelText: 'Titre du Rapport',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              onChanged: (value) {
                widget.report.metadata['title'] = value;
              },
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Le titre est requis';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: widget.report.author,
              decoration: InputDecoration(
                labelText: 'Auteur',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              onChanged: (value) {
                widget.report.metadata['author'] = value;
              },
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'L\'auteur est requis';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Date de création: ${widget.report.createdAt.toLocal().toString().split('.')[0]}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeetingSection() {
    final meeting = widget.report as MeetingReport;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Détails de la Réunion',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: meeting.hierarchy,
              decoration: InputDecoration(
                labelText: 'Hiérarchie',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => meeting.hierarchy = value,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: meeting.meetingType,
              decoration: InputDecoration(
                labelText: 'Type de Réunion',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => meeting.meetingType = value,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: meeting.meetingObject,
              decoration: InputDecoration(
                labelText: 'Objet de la Réunion',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) => meeting.meetingObject = value,
            ),
            const SizedBox(height: 16),
            if (meeting.discussionPoints.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Points de Discussion (${meeting.discussionPoints.length})',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: meeting.discussionPoints.length,
                    itemBuilder: (context, index) {
                      final point = meeting.discussionPoints[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text('${index + 1}'),
                        ),
                        title: Text(point['point'] ?? ''),
                        subtitle: Text(point['decision'] ?? ''),
                      );
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
          label: const Text('Annuler'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
          ),
        ),
        ElevatedButton.icon(
          onPressed: _validateAndSave,
          icon: const Icon(Icons.save),
          label: const Text('Enregistrer'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
        ),
      ],
    );
  }
}
