import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Add this to your pubspec.yaml
import 'package:social_sphere/theme/pallete.dart';

class OfflineScreen extends StatelessWidget {
  const OfflineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: isDark ? colorScheme.surface : Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
              colorScheme.surface,
              Pallete.blueColor.withOpacity(0.1),
            ]
                : [
              Colors.white,
              Pallete.blueColor.withOpacity(0.1),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Lottie animation with dark mode support
                Lottie.asset(
                  'assets/animations/no-internet.json',
                  width: 250,
                  height: 250,
                  fit: BoxFit.contain,
                  repeat: true,
                  frameRate: FrameRate(60),
                ),

                const SizedBox(height: 32),

                Text(
                  'Connection Lost',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Pallete.blueColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),

                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Oops! It seems you\'re offline. Please check your internet connection and try again.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isDark ? colorScheme.onSurfaceVariant : Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Retry button
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh, size: 20),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Pallete.blueColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                      ),
                      onPressed: () {
                        // Add retry logic here
                      },
                    ),

                    const SizedBox(width: 16),

                    // Help button
                    OutlinedButton.icon(
                      icon: const Icon(Icons.help_outline, size: 20),
                      label: const Text('Help'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Pallete.blueColor,
                        side: BorderSide(color: Pallete.blueColor),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: () {
                        // Add help logic here
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Troubleshooting tips
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: isDark
                        ? colorScheme.surfaceContainerHigh
                        : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? colorScheme.outlineVariant.withOpacity(0.3)
                          : Colors.grey[200]!,
                    ),
                  ),
                  child: ExpansionTile(
                    title: Text(
                      'Troubleshooting Tips',
                      style: TextStyle(
                        color: Pallete.blueColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTipItem(
                              context,
                              '1. Check your Wi-Fi or mobile data',
                              isDark: isDark,
                            ),
                            _buildTipItem(
                              context,
                              '2. Restart your router',
                              isDark: isDark,
                            ),
                            _buildTipItem(
                              context,
                              '3. Toggle airplane mode',
                              isDark: isDark,
                            ),
                            _buildTipItem(
                              context,
                              '4. Move to a better signal area',
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTipItem(BuildContext context, String text, {required bool isDark}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.circle,
            size: 8,
            color: Pallete.blueColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? theme.colorScheme.onSurfaceVariant
                    : Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}