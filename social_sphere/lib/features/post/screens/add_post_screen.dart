import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_sphere/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';

class AddPostScreen extends ConsumerWidget {
  const AddPostScreen({super.key});

  void navigateToType(BuildContext context, String type) {
    Routemaster.of(context).push('/add-post/$type');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeNotifierProvider);
    final bool isDark = currentTheme.brightness == Brightness.dark;
    final bool isWeb = kIsWeb;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create New Post',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isWeb ? 150 : 20,
              vertical: 20,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Choose post type',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                _buildPostTypeCard(
                  context: context,
                  icon: Icons.image_outlined,
                  label: 'Image Post',
                  description: 'Share photos or artwork',
                  type: 'image',
                  theme: currentTheme,
                  isDark: isDark,
                  isWeb: isWeb,
                ),
                const SizedBox(height: 20),
                _buildPostTypeCard(
                  context: context,
                  icon: Icons.font_download_outlined,
                  label: 'Text Post',
                  description: 'Write your thoughts',
                  type: 'text',
                  theme: currentTheme,
                  isDark: isDark,
                  isWeb: isWeb,
                ),
                const SizedBox(height: 20),
                _buildPostTypeCard(
                  context: context,
                  icon: Icons.link_outlined,
                  label: 'Link Post',
                  description: 'Share interesting links',
                  type: 'link',
                  theme: currentTheme,
                  isDark: isDark,
                  isWeb: isWeb,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPostTypeCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String description,
    required String type,
    required ThemeData theme,
    required bool isDark,
    required bool isWeb,
  }) {
    return GestureDetector(
      onTap: () => navigateToType(context, type),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color:
                isDark
                    ? Colors.grey.shade900.withOpacity(0.6)
                    : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.withOpacity(0.1),
                ),
                child: Icon(icon, size: 30, color: Colors.blue),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
