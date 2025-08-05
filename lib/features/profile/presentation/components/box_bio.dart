import 'package:flutter/material.dart';

class BoxBio extends StatelessWidget {
  final String bio;
  const BoxBio({super.key, required this.bio});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        bio.isEmpty ? "Empty bio ..." : bio,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 16,
        ),
      ),
    );
  }
}
