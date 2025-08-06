import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../l10n/app_localizations.dart';
import '../data/card.dart';

enum NoteEditorMode { create, edit }

class NoteEditor extends StatefulWidget {
  final NoteEditorMode mode;
  final CardData? note;
  final void Function(CardData) onSave;
  final VoidCallback onBack;
  final List<String> categories;
  final VoidCallback? onReturnHome;

  /// Creates a note editor in create mode
  factory NoteEditor.create({
    Key? key,
    required void Function(CardData) onSave,
    required VoidCallback onBack,
    required List<String> categories,
    VoidCallback? onReturnHome,
  }) {
    return NoteEditor._(
      key: key,
      mode: NoteEditorMode.create,
      note: null,
      onSave: onSave,
      onBack: onBack,
      categories: categories,
      onReturnHome: onReturnHome,
    );
  }

  /// Creates a note editor in edit mode
  factory NoteEditor.edit({
    Key? key,
    required CardData note,
    required void Function(CardData) onSave,
    required VoidCallback onBack,
    required List<String> categories,
  }) {
    return NoteEditor._(
      key: key,
      mode: NoteEditorMode.edit,
      note: note,
      onSave: onSave,
      onBack: onBack,
      categories: categories,
      onReturnHome: null,
    );
  }

  const NoteEditor._({
    super.key,
    required this.mode,
    this.note,
    required this.onSave,
    required this.onBack,
    required this.categories,
    this.onReturnHome,
  }) : assert(mode == NoteEditorMode.edit ? note != null : true);

  @override
  State<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final FocusNode _categoryFocusNode = FocusNode();

  late String _title;
  String? _category;
  Color? _categoryColor;
  late String _content;
  Color? _backgroundColor;
  late int _imageIsBackground;
  String? _imagePath;
  bool _reminderEnabled = false;
  DateTime? _reminderDateTime;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    // Initialize with existing note data in edit mode or defaults in create mode
    _title = widget.note?.title ?? '';
    _category = widget.note?.category;
    _categoryColor = widget.note?.categoryColor;
    _content = widget.note?.content ?? '';
    _backgroundColor = widget.note?.backgroundColor;
    _imageIsBackground = widget.note?.imageIsBackground ?? 0;
    _imagePath = widget.note?.imageUrl;
    _reminderDateTime = widget.note?.notification;
    _reminderEnabled = _reminderDateTime != null;

    _titleController.text = _title;
    _categoryController.text = _category ?? '';
    _contentController.text = _content;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _contentController.dispose();
    _categoryFocusNode.dispose();
    super.dispose();
  }

  Future<bool> _fileExists(String? path) async {
    if (path == null) return false;
    return await File(path).exists();
  }

  Future<void> _pickImage() async {
    if (!mounted) return;

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        if (await file.exists()) {
          if (!mounted) return;
          setState(() => _imagePath = pickedFile.path);
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.imageNotFound),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.imageSelectionError(e.toString()),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showColorPickerDialog(
    Color? initialColor,
    ValueChanged<Color> onColorChanged,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: initialColor ?? Colors.blue,
            onColorChanged: onColorChanged,
            pickerAreaHeightPercent: 0.8,
            enableAlpha: false,
            displayThumbColor: true,
            labelTypes: const [],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _pickCategoryColor() {
    _showColorPickerDialog(_categoryColor, (color) {
      setState(() => _categoryColor = color);
    });
  }

  void _pickBackgroundColor() {
    _showColorPickerDialog(_backgroundColor, (color) {
      setState(() {
        _backgroundColor = color;
        _imageIsBackground = 0;
      });
    });
  }

  void _toggleImageIsBackground(int? value) {
    setState(() {
      _imageIsBackground = value ?? 0;
      if (_imageIsBackground == 1) {
        _backgroundColor = null;
      }
    });
  }

  void _saveNote() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (widget.mode == NoteEditorMode.create) {
      final newNote = CardData(
        id: UniqueKey().toString(),
        type: CardType.note,
        title: _title,
        category: _category,
        categoryColor: _categoryColor,
        content: _content,
        backgroundColor: _backgroundColor,
        imageUrl: _imagePath,
        imageIsBackground: _imageIsBackground,
        notification: _reminderEnabled ? _reminderDateTime : null,
      );
      widget.onSave(newNote);
      widget.onReturnHome?.call();
    } else {
      final updatedNote = widget.note!.copyWith(
        title: _title.isNotEmpty ? _title : 'Untitled',
        category: _category?.isNotEmpty == true ? _category : null,
        categoryColor: _categoryColor,
        content: _content,
        backgroundColor: _backgroundColor,
        clearBackgroundColor:
            _backgroundColor == null && widget.note!.backgroundColor != null,
        imageUrl: _imagePath,
        imageIsBackground: _imageIsBackground,
        notification: _reminderEnabled ? _reminderDateTime : null,
        newModified: DateTime.now(),
      );
      widget.onSave(updatedNote);
      widget.onBack();
    }
  }

  Future<void> _handleSetReminder() async {
    final now = DateTime.now();
    final initialDate = _reminderDateTime ?? now.add(const Duration(hours: 1));

    // Show Date Picker
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: DateTime(2101),
    );

    if (date == null) return; // User canceled

    // IMPORTANT: Check if the widget is still mounted after the first await.
    if (!mounted) return;

    // Show Time Picker
    final initialTime = TimeOfDay.fromDateTime(
      _reminderDateTime ?? now.add(const Duration(hours: 1)),
    );
    final time = await showTimePicker(
      context: context, // This is now safe because we checked for mounted.
      initialTime: initialTime,
    );

    if (time == null) return; // User canceled

    // IMPORTANT: Check mounted again before calling setState.
    if (!mounted) return;

    setState(() {
      _reminderDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      _reminderEnabled = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Define text styles
    final titleStyle = theme.textTheme.titleLarge?.copyWith(
      color: theme.colorScheme.onPrimary,
      fontWeight: FontWeight.w600,
    );

    final onSurfaceColor = theme.colorScheme.onSecondary;
    final bodyStyle = theme.textTheme.bodyLarge?.copyWith(
      color: onSurfaceColor.withAlpha(230),
      height: 1.5,
    );

    final labelStyle = theme.textTheme.titleMedium?.copyWith(
      color: onSurfaceColor.withAlpha(178),
      fontWeight: FontWeight.w500,
    );

    return Theme(
      data: theme.copyWith(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: theme.colorScheme.secondary.withAlpha(isDark ? 50 : 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          hintStyle: theme.textTheme.bodyLarge?.copyWith(
            color: theme.hintColor,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: theme.colorScheme.secondary.withAlpha(isDark ? 50 : 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Scaffold(
          backgroundColor: theme.colorScheme.primary,
          appBar: AppBar(
            backgroundColor: theme.colorScheme.primary,
            elevation: 0,
            title: Text(
              widget.mode == NoteEditorMode.create ? 'Create Note' : 'Edit Note',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_rounded,
                color: theme.colorScheme.onPrimary,
              ),
              onPressed: widget.onBack,
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.save_rounded, color: theme.colorScheme.onPrimary),
                onPressed: _saveNote,
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Reminder and Background Options
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: Text('Set reminder', style: labelStyle),
                          value: _reminderEnabled,
                          activeColor: theme.colorScheme.onPrimary,
                          onChanged: (value) {
                            if (value) {
                              _handleSetReminder();
                            } else {
                              setState(() {
                                _reminderEnabled = false;
                                _reminderDateTime = null;
                              });
                            }
                          },
                          secondary: Icon(
                            _reminderEnabled
                                ? Icons.notifications_active_rounded
                                : Icons.notifications_none_rounded,
                            color: _reminderEnabled
                                ? theme.colorScheme.onPrimary
                                : theme.hintColor,
                          ),
                        ),
                        if (_reminderDateTime != null)
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 72, // Align with title
                              bottom: 16,
                              right: 16,
                            ),
                            child: Text(
                              'Reminder: ${_reminderDateTime!.toString().substring(0, 16)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Icon(
                            Icons.image_rounded,
                            color: theme.colorScheme.onPrimary,
                          ),
                          title: Text('Background', style: labelStyle),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.add_photo_alternate_outlined,
                                  color: theme.colorScheme.onPrimary,
                                ),
                                onPressed: _pickImage,
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.color_lens_outlined,
                                  color: _backgroundColor ?? theme.hintColor,
                                ),
                                onPressed: _pickBackgroundColor,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Title field
                  TextFormField(
                    controller: _titleController,
                    style: titleStyle,
                    decoration: InputDecoration(
                      hintText: 'Title',
                      hintStyle: titleStyle?.copyWith(color: theme.hintColor),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    onSaved: (value) => _title = value?.trim() ?? '',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Content
                  Expanded(
                    child: TextFormField(
                      controller: _contentController,
                      maxLines: null,
                      expands: true,
                      style: bodyStyle,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: InputDecoration(
                        hintText: 'Start writing...',
                        hintStyle: bodyStyle?.copyWith(color: theme.hintColor),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      onSaved: (value) => _content = value ?? '',
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
