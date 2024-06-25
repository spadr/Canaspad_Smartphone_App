import 'package:flutter/material.dart';

class EnvironmentTextField extends StatelessWidget {
  final String labelText;
  final String? initialValue;
  final FormFieldSetter<String?> onSaved;
  final bool obscureText;

  const EnvironmentTextField({
    Key? key,
    required this.labelText,
    this.initialValue,
    required this.onSaved,
    this.obscureText = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(),
      ),
      onSaved: onSaved,
      obscureText: obscureText,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $labelText';
        }
        return null;
      },
    );
  }
}
