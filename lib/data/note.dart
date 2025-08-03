import 'package:intl/intl.dart';

/// An enumeration to define the various ways a list of notes can be sorted.
enum NoteSortOrder {
  /// Sorts notes by the most recently modified date first.
  modifiedNewest,

  /// Sorts notes by the oldest modified date first.
  modifiedOldest,

  /// Sorts notes alphabetically by title, from A to Z.
  titleAscending,

  /// Sorts notes alphabetically by category, from A to Z.
  categoryAscending,
}

/// A data class representing a single note.
class Note {
  /// A unique identifier for the note.
  final String id;

  /// The title of the note.
  final String title;

  /// The category the note belongs to.
  final String category;

  /// The main content of the note.
  final String content;

  /// The timestamp when the note was first created.
  final DateTime created;

  /// The timestamp when the note was last modified.
  final DateTime modified;

  /// Constructs a new Note instance.
  ///
  /// `created` and `modified` timestamps default to the current time if not provided.
  Note({
    required this.id,
    required this.title,
    required this.category,
    required this.content,
    DateTime? created,
    DateTime? modified,
  }) : created = created ?? DateTime.now(),
       modified = modified ?? created ?? DateTime.now();

  /// Creates a new Note instance with updated values for some fields.
  ///
  /// This is useful for immutably updating a note.
  Note copyWith({
    String? title,
    String? category,
    String? content,
    DateTime? newModified,
    DateTime? newCreated,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      category: category ?? this.category,
      content: content ?? this.content,
      created: newCreated ?? created,
      modified: newModified ?? modified,
    );
  }

  /// Converts the Note object into a JSON map.
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'content': content,
    'created': created.toIso8601String(),
    'modified': modified.toIso8601String(),
  };

  /// Creates a Note object from a JSON map.
  ///
  /// The factory constructor handles parsing the `DateTime` strings.
  factory Note.fromJson(Map<String, dynamic> json) => Note(
    id: json['id'] as String,
    title: json['title'] as String,
    category: json['category'] as String,
    content: json['content'] as String,
    created: DateTime.tryParse(json['created'] as String) ?? DateTime.now(),
    modified: DateTime.tryParse(json['modified'] as String) ?? DateTime.now(),
  );
}

/// Formats a given `DateTime` into a human-readable string.
///
/// The output format changes based on how recent the date is:
/// - "Today, HH:MM AM/PM"
/// - "Yesterday, HH:MM AM/PM"
/// - "MMM d, y, HH:MM AM/PM" (for dates in the current year)
/// - "MMM d, y, yyyy, HH:MM AM/PM" (for dates in previous years)
String formatDynamicDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = now.subtract(Duration(days: 1));
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
