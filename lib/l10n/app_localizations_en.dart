// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Enscribe';

  @override
  String get home => 'Home';

  @override
  String get create => 'Create';

  @override
  String get settings => 'Settings';

  @override
  String get note => 'Note';

  @override
  String get task => 'Task';

  @override
  String get verse => 'Verse';

  @override
  String get prayer => 'Prayer';

  @override
  String get title => 'Title';

  @override
  String get titleRequired => 'Title is required';

  @override
  String get titleTooShort => 'Title must be at least 2 characters long';

  @override
  String get titleTooLong => 'Title must be less than 100 characters';

  @override
  String get category => 'Category';

  @override
  String get categoryTooShort => 'Category must be at least 2 characters';

  @override
  String get categoryTooLong => 'Category must be less than 20 characters';

  @override
  String get noteContent => 'Note Content';

  @override
  String get contentTooLong => 'Content must be less than 10,000 characters';

  @override
  String get noContent => 'No content';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get selectCategory => 'Select category';

  @override
  String get imageNotFound => 'Selected image file could not be found';

  @override
  String imageSelectionError(String error) {
    return 'Error selecting image: $error';
  }

  @override
  String reminderSetFor(String dateTime) {
    return 'Reminder set for: $dateTime';
  }

  @override
  String get updateDownloaded => 'Update downloaded. Launching installer...';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';
}
