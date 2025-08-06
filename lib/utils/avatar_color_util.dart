import 'package:flutter/material.dart';

Color generateColorFromUsername(String username) {
  final hash = username.codeUnits.fold(0, (prev, char) => prev + char);
  final colors = [
    Colors.redAccent,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.indigo,
    Colors.deepOrange,
  ];
  return colors[hash % colors.length - 1];
}
