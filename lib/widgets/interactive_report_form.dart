import 'package:flutter/material.dart';
import '../models/meeting_report.dart';
import '../models/visit_report.dart';
import '../models/divine_service_report.dart';

class InteractiveReportForm extends StatefulWidget {
  final dynamic report;
  final VoidCallback? onSave;
  final Function(List<String>)? onValidationErrors;

  const InteractiveReportForm({
    required this.report,
    this.onSave,
    this.onValidationErrors,
    Key? key,
  }) : super(key: key);

  @override
  State<InteractiveReportForm> createState() => _InteractiveReportFormState();
}

class _InteractiveReportFormState extends State<InteractiveReportForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    if (widget.report == null) return const Center(child: Text('Aucun rapport sélectionné'));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: _buildFormFields(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _validateAndSave,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Sauvegarder les modifications'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _validateAndSave() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final errors = widget.report.validate();
      if (errors.isEmpty) {
        widget.onSave?.call();
      } else {
        widget.onValidationErrors?.call(errors);
      }
    }
  }

  Widget _buildFormFields() {
    final report = widget.report;
    if (report is MeetingReport) return _buildMeetingFields(report);
    if (report is VisitReport) return _buildVisitFields(report);
    if (report is DivineServiceReport) return _buildDivineServiceFields(report);
    return const Text('Type de rapport inconnu');
  }

  Widget _buildMeetingFields(MeetingReport report) {
    return Column(
      children: [
        _textInput('Titre du rapport', (v) => report.title, (v) => report.title = v ?? report.title),
        _textInput('Sujet de la réunion', (v) => report.meetingObject, (v) => report.meetingObject = v),
        _textInput('Hiérarchie', (v) => report.hierarchy, (v) => report.hierarchy = v),
        _textInput('Président', (v) => report.president, (v) => report.president = v),
        _textInput('Secrétaire', (v) => report.secretary, (v) => report.secretary = v),
      ],
    );
  }

  Widget _buildVisitFields(VisitReport report) {
    return Column(
      children: [
        _textInput('Titre du rapport', (v) => report.title, (v) => report.title = v ?? report.title),
        _textInput('Lieu de la visite', (v) => report.location, (v) => report.location = v),
        _textInput('Raison de la visite', (v) => report.visitReason, (v) => report.visitReason = v),
        _textInput('Observations', (v) => report.observations, (v) => report.observations = v, maxLines: 5),
      ],
    );
  }

  Widget _buildDivineServiceFields(DivineServiceReport report) {
    return Column(
      children: [
        _textInput('Titre du rapport', (v) => report.title, (v) => report.title = v ?? report.title),
        _textInput('Thème', (v) => report.theme, (v) => report.theme = v),
        _textInput('Résumé', (v) => report.summary, (v) => report.summary = v, maxLines: 5),
        _textInput('Participants (nombre)', (v) => report.attendance.toString(), (v) => report.attendance = int.tryParse(v ?? '0') ?? 0),
      ],
    );
  }

  Widget _textInput(String label, String? Function(String?) getter, Function(String?) setter, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        initialValue: getter(null),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        maxLines: maxLines,
        onSaved: setter,
        validator: (value) => value?.isEmpty ?? true ? 'Champ requis' : null,
      ),
    );
  }
}
