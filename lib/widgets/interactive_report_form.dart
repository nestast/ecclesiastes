import 'package:flutter/material.dart';

class InteractiveReportForm extends StatefulWidget {
  final Function(Map<String, dynamic>)? onSubmit;

  const InteractiveReportForm({
    this.onSubmit,
    Key? key,
  }) : super(key: key);

  @override
  State<InteractiveReportForm> createState() => _InteractiveReportFormState();
}

class _InteractiveReportFormState extends State<InteractiveReportForm> {
  final _formKey = GlobalKey<FormState>();
  String? title;
  String? description;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Titre du rapport',
              border: OutlineInputBorder(),
            ),
            onSaved: (value) => title = value,
            validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
            onSaved: (value) => description = value,
            validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                widget.onSubmit?.call({
                  'title': title,
                  'description': description,
                });
              }
            },
            child: const Text('Soumettre'),
          ),
        ],
      ),
    );
  }
}
