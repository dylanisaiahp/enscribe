import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// A stateful widget that represents the About settings section.
/// This section provides information about the application, such as its version and licenses.
class AboutSection extends StatefulWidget {
  /// The background color for the section.
  final Color background;

  /// The accent color used for the title.
  final Color accent;

  /// The text style for the section title.
  final TextStyle titleStyle;

  const AboutSection({
    super.key,
    required this.background,
    required this.accent,
    required this.titleStyle,
  });

  @override
  State<AboutSection> createState() => _AboutSectionState();
}

class _AboutSectionState extends State<AboutSection> {
  /// State variable to toggle the visibility of the description subtitle.
  bool _showDescriptionSubtitle = false;

  /// State variable to toggle the visibility of the version subtitle.
  bool _showVersionSubtitle = false;

  /// The application version string, fetched asynchronously.
  String? _appVersion;

  /// Fetches the application version from the platform's package info.
  Future<String> getAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    return info.version;
  }

  @override
  Widget build(BuildContext context) {
    // Local variables for better readability.
    final background = widget.background;
    final accent = widget.accent;
    final titleStyle = widget.titleStyle;

    return DecoratedBox(
      // Container for the entire section with background and rounded corners.
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text('About', style: titleStyle.copyWith(color: accent)),
            ),
            const SizedBox(height: 4),
            // ListTile for the application description.
            ListTile(
              leading: const Icon(Symbols.description_rounded, fill: 1.0),
              title: const Text('Description'),
              onTap: () {
                // Toggles the description subtitle's visibility on tap.
                setState(() {
                  _showDescriptionSubtitle = !_showDescriptionSubtitle;
                });
              },
              subtitle: _showDescriptionSubtitle
                  ? const Text('Enscribe notes, tasks, and scripture.')
                  : null,
            ),
            // ListTile for the application version.
            ListTile(
              leading: const Icon(Symbols.info_rounded, fill: 1.0),
              title: const Text('Version'),
              onTap: () async {
                // Toggles the version subtitle's visibility on tap.
                setState(() {
                  _showVersionSubtitle = !_showVersionSubtitle;
                });

                // Fetches the app version if it's not already loaded.
                if (_showVersionSubtitle && _appVersion == null) {
                  final version = await getAppVersion();
                  setState(() {
                    _appVersion = version;
                  });
                }
              },
              subtitle: _showVersionSubtitle
                  ? Text(_appVersion ?? 'Loading...')
                  : null,
            ),
            // ListTile for checking updates.
            ListTile(
              leading: const Icon(Symbols.system_update_rounded, fill: 1.0),
              title: const Text('Updates'),
              onTap: () {
                final scaffoldMessenger = ScaffoldMessenger.of(context);

                // Shows a snack bar indicating an update check is in progress.
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Checking for updates...'),
                    duration: Duration(seconds: 2),
                  ),
                );

                // Simulates a network delay and then shows a second snack bar.
                Future.delayed(const Duration(seconds: 2)).then((_) {
                  if (!mounted) return;

                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('You are on the latest version.'),
                    ),
                  );
                });
              },
            ),
            // ListTile to show the application's licenses.
            ListTile(
              leading: const Icon(Symbols.description_rounded, fill: 1.0),
              title: const Text('Licenses'),
              onTap: () => showLicensePage(context: context),
            ),
            // ListTile for open source information (onTap is a placeholder).
            ListTile(
              leading: const Icon(Symbols.code_rounded, fill: 1.0),
              title: const Text('Open Source'),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
