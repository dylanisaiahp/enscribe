import 'package:flutter/material.dart';

class CreatePrayerView extends StatelessWidget {
  final VoidCallback onBack;

  const CreatePrayerView({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(onPressed: onBack, child: const Text('Back')),
        const Text('Prayer Creation UI goes here'),
      ],
    );
  }
}
