import 'package:flutter/material.dart';

class CreateVerseView extends StatelessWidget {
  final VoidCallback onBack;

  const CreateVerseView({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(onPressed: onBack, child: const Text('Back')),
        const Text('Verse Creation UI goes here'),
      ],
    );
  }
}
