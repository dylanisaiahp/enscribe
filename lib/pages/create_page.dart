import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../nav.dart';
import '../data/card.dart';
import '../components/note_editor.dart';
import '../sections/create/tasks.dart';
import '../sections/create/verse.dart';
import '../sections/create/prayer.dart';

enum CreateType { none, notes, tasks, verse, prayer }

class CreatePage extends StatefulWidget {
  final NavBarPosition selectedNavBarPosition;
  final void Function(CardData) onCardCreated;
  final List<String> categories;
  final void Function()? onReturnHome;

  const CreatePage({
    super.key,
    required this.selectedNavBarPosition,
    required this.onCardCreated,
    required this.categories,
    this.onReturnHome,
  });

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  CreateType _selected = CreateType.none;

  void _selectType(CreateType type) {
    setState(() {
      _selected = type;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isNavBarTop = widget.selectedNavBarPosition == NavBarPosition.top;

    return Scaffold(
      body: SafeArea(
        top: !isNavBarTop,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: _buildContent(theme),
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    switch (_selected) {
      case CreateType.notes:
        return NoteEditor.create(
          onBack: () => _selectType(CreateType.none),
          onSave: (cardData) {
            widget.onCardCreated(cardData);
            widget.onReturnHome?.call();
          },
          categories: widget.categories,
          onReturnHome: widget.onReturnHome,
        );
      case CreateType.tasks:
        return CreateTasksView(onBack: () => _selectType(CreateType.none));
      case CreateType.verse:
        return CreateVerseView(onBack: () => _selectType(CreateType.none));
      case CreateType.prayer:
        return CreatePrayerView(onBack: () => _selectType(CreateType.none));
      case CreateType.none:
        return _buildSelector(theme);
    }
  }

  Widget _buildSelector(ThemeData theme) {
    final background = theme.colorScheme.secondary;
    final accent = theme.colorScheme.tertiary;
    final onSurface = theme.colorScheme.onSurface;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Create New Entry',
            style: theme.textTheme.titleLarge?.copyWith(color: accent),
          ),
          const SizedBox(height: 24),
          Container(
            width: 260,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildCreateButton(
                  icon: Symbols.note_add_rounded,
                  label: 'Note',
                  color: onSurface,
                  labelStyle: theme.textTheme.labelLarge,
                  onTap: () => _selectType(CreateType.notes),
                ),
                const SizedBox(height: 12),
                _buildCreateButton(
                  icon: Symbols.checklist_rounded,
                  label: 'Task',
                  color: onSurface,
                  labelStyle: theme.textTheme.labelLarge,
                  onTap: () => _selectType(CreateType.tasks),
                ),
                const SizedBox(height: 12),
                _buildCreateButton(
                  icon: Symbols.auto_stories_rounded,
                  label: 'Verse',
                  color: onSurface,
                  labelStyle: theme.textTheme.labelLarge,
                  onTap: () => _selectType(CreateType.verse),
                ),
                const SizedBox(height: 12),
                _buildCreateButton(
                  icon: Symbols.folded_hands_rounded,
                  label: 'Prayer',
                  color: onSurface,
                  labelStyle: theme.textTheme.labelLarge,
                  onTap: () => _selectType(CreateType.prayer),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton({
    required IconData icon,
    required String label,
    required Color color,
    required TextStyle? labelStyle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(icon, color: color, fill: 1.0),
            const SizedBox(width: 12),
            Text(label, style: labelStyle),
          ],
        ),
      ),
    );
  }
}
