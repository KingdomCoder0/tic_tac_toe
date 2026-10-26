import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  Future<void> _openPrivacyPolicy(BuildContext context) async {
    final uri = Uri.parse(
      'https://kingdomcoder0.github.io/tic_tac_toe/privacy-policy',
    );
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the privacy policy.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.grid_3x3, size: 64),
                  SizedBox(height: 16),
                  Text('Tic-Tac-Toe', style: TextStyle(fontSize: 28)),
                  SizedBox(height: 8),
                  Text(
                    'A Tic-Tac-Toe game built with Flutter.',
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Play against the computer or another player.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => _openPrivacyPolicy(context),
            icon: const Icon(Icons.privacy_tip_outlined),
            label: const Text('Privacy Policy'),
          ),
        ],
      ),
    );
  }
}
