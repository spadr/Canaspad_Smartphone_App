import 'package:flutter/material.dart';

void navigateTo(BuildContext context, Widget target) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => target),
  );
}
