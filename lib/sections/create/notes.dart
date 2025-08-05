import 'dart:io';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../data/card.dart';

class CreateNotesView extends StatefulWidget {
  final void Function(CardData) onSave;
  final VoidCallback onBack;
  final List<String> categories;

  const CreateNotesView({
    super.key,
    required this.onSave,
    required this.onBack,
    required this.categories,
  });

  @override
  State<CreateNotesView> createState() => _CreateNotesViewState();
}

class _CreateNotesViewState extends State<CreateNotesView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _categoryController = TextEditingController();
  final FocusNode _categoryFocusNode = FocusNode();

  String _title = '';
  String? _category;
  Color? _categoryColor;
  String _content = '';
  Color? _backgroundColor;
  int _imageIsBackground = 0;
  String? _imagePath;
  final bool _reminderEnabled = false;
  DateTime? _reminderDateTime;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() => _imagePath = pickedFile.path);
    }
  }

  void _showColorPickerDialog(
    Color? currentColor,
    ValueChanged<Color> onColorSelected,
  ) {
    Color pickerColor = currentColor ?? Colors.blue;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Pick a color"),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: (color) => pickerColor = color,
            enableAlpha: false,
            labelTypes: const [],
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).textTheme.bodyMedium!.color,
              backgroundColor: Colors.white.withAlpha(64),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).textTheme.bodyMedium!.color,
              backgroundColor: Colors.white.withAlpha(64),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              onColorSelected(pickerColor);
              Navigator.of(context).pop();
            },
            child: const Text("Select"),
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

  Future<void> _pickReminderDateTime() async {
    final now = DateTime.now();

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_reminderDateTime ?? now),
    );

    if (!mounted || pickedTime == null) return;

    final newDateTime = DateTime(
      _reminderDateTime?.year ?? now.year,
      _reminderDateTime?.month ?? now.month,
      _reminderDateTime?.day ?? now.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      _reminderDateTime = newDateTime;
    });
  }

  void _saveNote() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondary = theme.colorScheme.secondary;
    final onSecondary = theme.colorScheme.onSecondary;
    final textColor = theme.colorScheme.onSurface;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('Create Note', style: TextStyle(color: textColor)),
          leading: BackButton(onPressed: widget.onBack, color: textColor),
          actions: [
            IconButton(
              onPressed: _saveNote,
              icon: Icon(Symbols.save_rounded, color: textColor, fill: 1.0),
              tooltip: 'Save',
            ),
          ],
          iconTheme: IconThemeData(color: textColor),
        ),
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Symbols.image_rounded, fill: 1.0),
                            label: const Text('Image'),
                            onPressed: _pickImage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: secondary,
                              foregroundColor: onSecondary,
                            ),
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(
                              Symbols.format_color_fill_rounded,
                              fill: 1.0,
                            ),
                            label: const Text('Background'),
                            onPressed: _pickBackgroundColor,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: secondary,
                              foregroundColor: onSecondary,
                            ),
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(
                              Symbols.access_time_rounded,
                              fill: 1.0,
                            ),
                            label: const Text('Reminder'),
                            onPressed: _pickReminderDateTime,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: secondary,
                              foregroundColor: onSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (_imagePath != null)
                        Column(
                          children: [
                            Stack(
                              alignment: Alignment.topRight,
                              children: [
                                Image.file(File(_imagePath!), height: 120),
                                IconButton(
                                  icon: const Icon(
                                    Symbols.close_rounded,
                                    fill: 1.0,
                                  ),
                                  onPressed: () =>
                                      setState(() => _imagePath = null),
                                  color: textColor,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Checkbox(
                                  value: _imageIsBackground == 1,
                                  onChanged: (bool? value) {
                                    _toggleImageIsBackground(
                                      value == true ? 1 : 0,
                                    );
                                  },
                                  fillColor: WidgetStateProperty.all(secondary),
                                ),
                                Text(
                                  'Fill as background',
                                  style: TextStyle(color: textColor),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),

                      // Title field
                      TextFormField(
                        textCapitalization: TextCapitalization.sentences,
                        autocorrect: true,
                        decoration: InputDecoration(
                          labelText: 'Title',
                          filled: true,
                          fillColor: secondary,
                          labelStyle: TextStyle(color: textColor),
                          border: const OutlineInputBorder(),
                        ),
                        style: TextStyle(color: textColor),
                        validator: (val) => val == null || val.isEmpty
                            ? 'Title required'
                            : null,
                        onSaved: (val) => _title = val ?? '',
                      ),
                      const SizedBox(height: 16),

                      // Category field with dropdown + color picker as suffix icons
                      TextFormField(
                        controller: _categoryController,
                        focusNode: _categoryFocusNode,
                        textCapitalization: TextCapitalization.sentences,
                        autocorrect: true,
                        enableSuggestions: true,
                        maxLength: 20,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          counterText: '',
                          labelText: 'Category',
                          filled: true,
                          fillColor: secondary,
                          labelStyle: TextStyle(color: textColor),
                          border: const OutlineInputBorder(),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Category dropdown
                              PopupMenuButton<String>(
                                icon: Icon(
                                  Symbols.category_rounded,
                                  color: textColor,
                                  fill: 1.0,
                                ),
                                tooltip: 'Select category',
                                onSelected: (selectedCategory) {
                                  _categoryController.text = selectedCategory;
                                  _categoryFocusNode.unfocus();
                                },
                                itemBuilder: (context) {
                                  final cats =
                                      widget.categories.toSet().toList()
                                        ..sort();
                                  if (cats.isEmpty) {
                                    return [
                                      const PopupMenuItem<String>(
                                        enabled: false,
                                        child: Text(
                                          'No categories created yet',
                                        ),
                                      ),
                                    ];
                                  }
                                  return cats
                                      .map(
                                        (cat) => PopupMenuItem<String>(
                                          value: cat,
                                          child: Text(cat),
                                        ),
                                      )
                                      .toList();
                                },
                              ),
                              // Color picker
                              IconButton(
                                icon: Icon(
                                  Symbols.color_lens_rounded,
                                  color: textColor,
                                  fill: 1.0,
                                ),
                                tooltip: 'Pick category color',
                                onPressed: _pickCategoryColor,
                              ),
                            ],
                          ),
                        ),
                        onSaved: (val) =>
                            _category = val?.isEmpty ?? true ? null : val,
                      ),
                      const SizedBox(height: 16),

                      // Content field expanding down
                      Expanded(
                        child: TextFormField(
                          textCapitalization: TextCapitalization.sentences,
                          autocorrect: true,
                          decoration: InputDecoration(
                            labelText: 'Note Content',
                            alignLabelWithHint: true,
                            filled: true,
                            fillColor: secondary,
                            labelStyle: TextStyle(color: textColor),
                            border: const OutlineInputBorder(),
                          ),
                          textAlignVertical: TextAlignVertical.top,
                          style: TextStyle(color: textColor),
                          maxLines: null,
                          expands: true,
                          onSaved: (val) => _content = val ?? '',
                        ),
                      ),
                      const SizedBox(height: 16),

                      if (_reminderEnabled && _reminderDateTime != null)
                        Center(
                          child: Text(
                            'Reminder set for: ${_reminderDateTime!.toLocal()}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: textColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
