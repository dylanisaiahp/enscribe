import 'dart:io';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

// The URL for your GitHub repository.
final Uri _gitHubUrl = Uri.parse('https://github.com/dylanisaiahp/enscribe');

// The GitHub API URL to get the latest release information.
const String _githubApiUrl =
    'https://api.github.com/repos/dylanisaiahp/enscribe/releases/latest';

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

  // A helper function to launch the URL safely.
  Future<void> _launchUrl(Uri url) async {
    final theme = Theme.of(context);

    // Check if the URL can be launched on the device.
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open the URL: $url'),
          backgroundColor: theme.colorScheme.error,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  /// Helper function to get the device's ABI.
  Future<String?> _getDeviceAbi() async {
    // We only need to check for Android devices.
    if (Platform.isAndroid) {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      // The deviceInfo.supportedAbis will give a list of supported ABIs,
      // with the best one at the front of the list. We'll use the first one.
      if (deviceInfo.supportedAbis.isNotEmpty) {
        return deviceInfo.supportedAbis.first;
      }
    }
    return null;
  }

  /// Downloads the APK and triggers the installer.
  Future<void> _downloadAndInstallApk(String url) async {
    final theme = Theme.of(context);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Downloading update...'),
        duration: Duration(seconds: 4),
      ),
    );

    try {
      // Get the application's temporary directory.
      final directory = await getTemporaryDirectory();

      // Extract the filename from the URL to use as the local file name.
      final fileName = url.split('/').last;
      final filePath = '${directory.path}/$fileName';

      // Download the file.
      final response = await http.get(Uri.parse(url));

      // Check if the download was successful.
      if (response.statusCode == 200) {
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Update downloaded. Launching installer...'),
            duration: Duration(seconds: 4),
          ),
        );

        // Request the permission and store the result.
        final status = await Permission.requestInstallPackages.request();
        if (status.isGranted) {
          // If permission is granted, proceed to open the file.
          final result = await OpenFilex.open(filePath);
          if (result.type != ResultType.done) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to open APK: ${result.message}'),
                backgroundColor: theme.colorScheme.error,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        } else if (status.isPermanentlyDenied) {
          // If permission is permanently denied, inform the user to go to settings.
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Permission to install apps is permanently denied. Please enable it in your device settings.',
              ),
              backgroundColor: theme.colorScheme.error,
              duration: const Duration(seconds: 6),
            ),
          );
        } else {
          // If permission is denied for any other reason, inform the user.
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Permission to install apps denied.'),
              backgroundColor: theme.colorScheme.error,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download update: ${response.statusCode}'),
            backgroundColor: theme.colorScheme.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred during download: $e'),
          backgroundColor: theme.colorScheme.error,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  // The main asynchronous function to check for updates from GitHub.
  Future<void> _checkForUpdates() async {
    final theme = Theme.of(context);

    // Show a snack bar indicating an update check is in progress.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Checking for updates...'),
        duration: Duration(seconds: 2),
      ),
    );

    // Get the current version of the app from pubspec.yaml.
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String currentVersion = packageInfo.version;

    try {
      // Get the device's ABI to find the correct APK.
      final String? deviceAbi = await _getDeviceAbi();
      if (deviceAbi == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not determine device architecture.'),
            backgroundColor: theme.colorScheme.error,
            duration: const Duration(seconds: 4),
          ),
        );
        return;
      }

      // Make a GET request to the GitHub API to get the latest release info.
      final response = await http.get(Uri.parse(_githubApiUrl));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final String latestVersion = jsonResponse['tag_name'].replaceAll(
          'v',
          '',
        );
        final List assets = jsonResponse['assets'] as List? ?? [];

        // Find the specific APK asset that matches the device's ABI.
        final String? apkUrl =
            assets.firstWhere(
                  (asset) =>
                      asset['name'].endsWith('.apk') &&
                      asset['name'].contains(deviceAbi),
                  orElse: () => null,
                )?['browser_download_url']
                as String?;

        if (apkUrl != null && latestVersion.compareTo(currentVersion) > 0) {
          // If an update is available and we have an APK URL, start the download.
          _downloadAndInstallApk(apkUrl);
        } else {
          // If the current version is the same or newer, or no APK is found.
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You are on the latest version.'),
              duration: Duration(seconds: 4),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to check for updates: ${response.statusCode}',
            ),
            backgroundColor: theme.colorScheme.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: theme.colorScheme.error,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
              leading: const Icon(Icons.system_update_rounded, fill: 1.0),
              title: const Text('Updates'),
              onTap: () => _checkForUpdates(),
            ),
            // ListTile to show the application's licenses.
            ListTile(
              leading: const Icon(Symbols.description_rounded, fill: 1.0),
              title: const Text('Licenses'),
              onTap: () => showLicensePage(context: context),
            ),
            // ListTile for source code information
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('Source'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Opening browser: $_gitHubUrl'),
                    duration: Duration(seconds: 2),
                  ),
                );

                // Call the function to launch the URL.
                _launchUrl(_gitHubUrl);
              },
            ),
          ],
        ),
      ),
    );
  }
}
