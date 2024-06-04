import 'package:flutter/material.dart';

class EnvironmentDetailView extends StatefulWidget {
  final Map<String, dynamic> environmentData;
  final int index;
  final Future<void> Function(Map<String, dynamic>) onSave;
  final Future<void> Function()? onDelete;

  EnvironmentDetailView({
    required this.environmentData,
    required this.index,
    required this.onSave,
    this.onDelete,
  });

  @override
  _EnvironmentDetailViewState createState() => _EnvironmentDetailViewState();
}

class _EnvironmentDetailViewState extends State<EnvironmentDetailView> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> _formData;

  @override
  void initState() {
    super.initState();
    _formData = Map<String, dynamic>.from(widget.environmentData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Environment Detail'),
        actions: [
          if (widget.onDelete != null)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                await widget.onDelete!();
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ..._formData.keys.map((key) {
                return TextFormField(
                  initialValue: _formData[key]?.toString(),
                  decoration: InputDecoration(labelText: key),
                  onSaved: (value) {
                    _formData[key] = value;
                  },
                );
              }).toList(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    await widget.onSave(_formData);
                    Navigator.of(context).pop();
                  }
                },
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
