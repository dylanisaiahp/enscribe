import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatDynamicDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = now.subtract(const Duration(days: 1));
  final targetDay = DateTime(date.year, date.month, date.day);

  if (targetDay.isAtSameMomentAs(today)) {
    return DateFormat.jm().format(date);
  } else if (targetDay.isAtSameMomentAs(
    DateTime(yesterday.year, yesterday.month, yesterday.day),
  )) {
    return 'Yesterday, ${DateFormat.jm().format(date)}';
  } else if (date.year == now.year) {
    return DateFormat.yMMMd().add_jm().format(date);
  } else {
    return DateFormat.yMMMd().add_y().add_jm().format(date);
  }
}

enum CardType { note, task, verse, prayer }

class CardData {
  final String id;
  final CardType type;
  final String title;
  final String? category;
  final Color? categoryColor;
  final String? content; // For note, verse, prayer
  final List<TaskItem>? tasks; // For task only
  final DateTime created;
  final DateTime modified;
  final DateTime? notification; // Optional reminder date/time
  final Color? backgroundColor;
  final String? imageUrl; // Optional image (could be url or asset path)
  final int imageIsBackground; // if true, image fills background with overlay

  CardData({
    required this.id,
    required this.type,
    required this.title,
    this.category,
    this.categoryColor,
    this.content,
    this.tasks,
    DateTime? created,
    DateTime? modified,
    this.notification,
    this.backgroundColor,
    this.imageUrl,
    this.imageIsBackground = 0,
  }) : created = created ?? DateTime.now(),
       modified = modified ?? created ?? DateTime.now();

  CardData copyWith({
    String? title,
    String? category,
    Color? categoryColor,
    String? content,
    List<TaskItem>? tasks,
    DateTime? newModified,
    DateTime? newCreated,
    DateTime? notification,
    Color? backgroundColor,
    String? imageUrl,
    int? imageIsBackground,
  }) {
    return CardData(
      id: id,
      type: type,
      title: title ?? this.title,
      category: category ?? this.category,
      categoryColor: categoryColor ?? this.categoryColor,
      content: content ?? this.content,
      tasks: tasks ?? this.tasks,
      created: newCreated ?? created,
      modified: newModified ?? modified,
      notification: notification ?? this.notification,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      imageUrl: imageUrl ?? this.imageUrl,
      imageIsBackground: imageIsBackground ?? this.imageIsBackground,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.index,
    'title': title,
    'category': category,
    'categoryColor': categoryColor?.toARGB32(),
    'content': content,
    'tasks': tasks?.map((t) => t.toJson()).toList(),
    'created': created.toIso8601String(),
    'modified': modified.toIso8601String(),
    'notification': notification?.toIso8601String(),
    'backgroundColor': backgroundColor?.toARGB32(),
    'imageUrl': imageUrl,
    'imageIsBackground': imageIsBackground,
  };

  factory CardData.fromJson(Map<String, dynamic> json) => CardData(
    id: json['id'] as String,
    type: CardType.values[json['type'] as int],
    title: json['title'] as String,
    category: json['category'] as String?,
    categoryColor: json['categoryColor'] != null
        ? Color(json['categoryColor'])
        : null,
    content: json['content'] as String?,
    tasks: json['tasks'] != null
        ? (json['tasks'] as List).map((t) => TaskItem.fromJson(t)).toList()
        : null,
    created: DateTime.tryParse(json['created'] as String) ?? DateTime.now(),
    modified: DateTime.tryParse(json['modified'] as String) ?? DateTime.now(),
    notification: json['notification'] != null
        ? DateTime.tryParse(json['notification'])
        : null,
    backgroundColor: json['backgroundColor'] != null
        ? Color(json['backgroundColor'])
        : null,
    imageUrl: json['imageUrl'] as String?,
    imageIsBackground: json['imageIsBackground'] as int? ?? 0,
  );
}

class TaskItem {
  final String id;
  final String text;
  final bool isDone;

  TaskItem({required this.id, required this.text, this.isDone = false});

  TaskItem copyWith({String? text, bool? isDone}) {
    return TaskItem(
      id: id,
      text: text ?? this.text,
      isDone: isDone ?? this.isDone,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'text': text, 'isDone': isDone};

  factory TaskItem.fromJson(Map<String, dynamic> json) => TaskItem(
    id: json['id'] as String,
    text: json['text'] as String,
    isDone: json['isDone'] as bool,
  );
}
