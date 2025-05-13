import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Add this to your pubspec.yaml
import 'package:social_sphere/theme/pallete.dart';

class OfflineScreen extends StatelessWidget {
  const OfflineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
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
                // Lottie animation (replace with your own asset if needed)
                Lottie.asset(
                  'assets/animations/no-internet.json', // Add this file to your assets
                  width: 250,
                  height: 250,
                  fit: BoxFit.contain,
                  repeat: true,
                ),
                
                const SizedBox(height: 32),
                
                Text(
                  'Connection Lost',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
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
                ExpansionTile(
                  title: Text(
                    'Troubleshooting Tips',
                    style: TextStyle(
                      color: Pallete.blueColor,
                      fontWeight: FontWeight.w500,
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
                          ),
                          _buildTipItem(
                            context,
                            '2. Restart your router',
                          ),
                          _buildTipItem(
                            context,
                            '3. Toggle airplane mode',
                          ),
                          _buildTipItem(
                            context,
                            '4. Move to a better signal area',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTipItem(BuildContext context, String text) {
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
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}