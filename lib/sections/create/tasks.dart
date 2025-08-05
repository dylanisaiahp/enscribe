import 'package:flutter/material.dart';

class CreateTasksView extends StatelessWidget {
  final VoidCallback onBack;

  const CreateTasksView({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(onPressed: onBack, child: const Text('Back')),
        const Text('Tasks Creation UI goes here'),
      ],
    );
  }
}
