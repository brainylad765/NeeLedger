import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

class NewProjectForm extends StatefulWidget {
  const NewProjectForm({super.key});

  @override
  State<NewProjectForm> createState() => _NewProjectFormState();
}

class _NewProjectFormState extends State<NewProjectForm> {
  final _formKey = GlobalKey<FormState>();
  String projectName = '';
  String location = '';
  String projectType = 'Choose type';
  String size = '';
  String description = '';

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Project created (mock)')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Create new project',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Project name',
                  filled: true,
                  fillColor: kCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                onChanged: (v) => projectName = v,
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Location',
                  filled: true,
                  fillColor: kCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (v) => location = v,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: projectType,
                      items:
                          [
                                'Choose type',
                                'Blue Carbon',
                                'REDD+',
                                'Afforestation',
                              ]
                              .map(
                                (t) =>
                                    DropdownMenuItem(value: t, child: Text(t)),
                              )
                              .toList(),
                      onChanged: (v) =>
                          setState(() => projectType = v ?? 'Choose type'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 120,
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Size (ha)',
                        filled: true,
                        fillColor: kCard,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (v) => size = v,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description (optional)',
                  filled: true,
                  fillColor: kCard,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (v) => description = v,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(backgroundColor: kAccent),
                child: const Text('Next'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
