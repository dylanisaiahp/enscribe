import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';
import 'data/card.dart';
import 'pages/loading_page.dart';
import 'data/themes.dart';
import 'nav.dart';
import 'data/storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EnscribeApp());
}

class EnscribeApp extends StatefulWidget {
  const EnscribeApp({super.key});

  @override
  State<EnscribeApp> createState() => _EnscribeAppState();
}

class _EnscribeAppState extends State<EnscribeApp> {
  final CardStorage _cardStorage = CardStorage();
  final ValueNotifier<List<CardData>> _cardNotifier = ValueNotifier([]);

  EnscribeTheme _selectedTheme = EnscribeTheme.graphene;
  bool _isGridView = false;
  bool _isLoading = true;
  bool _showCategory = true;
  bool _showDateTime = true;

  // NEW: NavBar position state
  NavBarPosition _selectedNavBarPosition = NavBarPosition.bottom;

  @override
  void initState() {
    super.initState();
    _initializeAppData();
  }

  @override
  void dispose() {
    _cardNotifier.dispose();
    _cardStorage.dispose();
    super.dispose();
  }

  Future<void> _initializeAppData() async {
    final stopwatch = Stopwatch()..start();

    await _loadPreferences();
    await _loadCards();

    const int minDurationMs = 400;
    final elapsed = stopwatch.elapsedMilliseconds;
    final remaining = minDurationMs - elapsed;
    if (remaining > 0) await Future.delayed(Duration(milliseconds: remaining));

    stopwatch.stop();

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadPreferences() async {
    final themeName = await _cardStorage.getPreference('selectedTheme');
    if (themeName != null) {
      _selectedTheme = EnscribeTheme.values.firstWhere(
        (e) => e.toString() == 'EnscribeTheme.$themeName',
        orElse: () => EnscribeTheme.graphene,
      );
    }

    _isGridView = (await _cardStorage.getPreference('isGridView')) == 'true';
    _showCategory =
        (await _cardStorage.getPreference('showCategory')) == 'true';
    _showDateTime =
        (await _cardStorage.getPreference('showDateTime')) == 'true';

    // NEW: Load saved NavBar position, default to bottom if null
    final navBarPositionString = await _cardStorage.getPreference(
      'navBarPosition',
    );
    if (navBarPositionString != null) {
      _selectedNavBarPosition = NavBarPosition.values.firstWhere(
        (e) => e.toString() == 'NavBarPosition.$navBarPositionString',
        orElse: () => NavBarPosition.bottom,
      );
    }

    if (mounted) setState(() {});
  }

  Future<void> _savePreference(String key, String value) async {
    await _cardStorage.savePreference(key, value);
    await _loadPreferences();
  }

  Future<void> _loadCards() async {
    final loadedCards = await _cardStorage.getCards();
    _cardNotifier.value = loadedCards;
  }

  Future<void> _onCardCreated(CardData newCard) async {
    await _cardStorage.addCard(newCard);
    await _loadCards();
  }

  Future<void> _onCardModified(
    String originalCardId,
    CardData? modifiedCard,
  ) async {
    if (modifiedCard == null) {
      await _cardStorage.deleteCard(originalCardId);
    } else {
      await _cardStorage.updateCard(modifiedCard);
    }
    await _loadCards();
  }

  void _onThemeChanged(EnscribeTheme newTheme) {
    setState(() => _selectedTheme = newTheme);
    _savePreference('selectedTheme', newTheme.name);
  }

  void _onToggleGridView(bool value) {
    setState(() => _isGridView = value);
    _savePreference('isGridView', value.toString());
  }

  void _onToggleCategory(bool value) {
    setState(() => _showCategory = value);
    _savePreference('showCategory', value.toString());
  }

  void _onToggleDateTime(bool value) {
    setState(() => _showDateTime = value);
    _savePreference('showDateTime', value.toString());
  }

  // NEW: Handle nav bar position changes
  void _onNavBarPositionChanged(NavBarPosition newPosition) {
    setState(() => _selectedNavBarPosition = newPosition);
    _savePreference('navBarPosition', newPosition.name);
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = EnscribeThemes.themeData[_selectedTheme]!;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Enscribe',
      theme: currentTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: _isLoading
          ? const LoadingPage()
          : ValueListenableBuilder<List<CardData>>(
              valueListenable: _cardNotifier,
              builder: (context, cards, child) {
                return HomeNavigation(
                  cards: cards,
                  onCardCreated: _onCardCreated,
                  onCardModified: _onCardModified,
                  selectedTheme: _selectedTheme,
                  onThemeChanged: _onThemeChanged,
                  isGridView: _isGridView,
                  onToggleGridView: _onToggleGridView,
                  onToggleCategory: _onToggleCategory,
                  onToggleDateTime: _onToggleDateTime,
                  showCategory: _showCategory,
                  showDateTime: _showDateTime,
                  selectedNavBarPosition: _selectedNavBarPosition,
                  onNavBarPositionChanged: _onNavBarPositionChanged,
                );
              },
            ),
    );
  }
}
