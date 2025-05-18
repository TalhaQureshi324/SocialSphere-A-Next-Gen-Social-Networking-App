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
    final colorScheme = currentTheme.colorScheme;
    final bool isWeb = kIsWeb;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Choose post type',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        surfaceTintColor: Colors.transparent,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isWeb ? 600 : double.infinity,
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                _buildPostTypeCard(
                  context: context,
                  icon: Icons.image_outlined,
                  label: 'Image Post',
                  description: 'Share photos or artwork',
                  type: 'image',
                  colorScheme: colorScheme,
                  iconColor: Colors.blueAccent,
                ),
                const SizedBox(height: 16),
                _buildPostTypeCard(
                  context: context,
                  icon: Icons.video_camera_back_outlined,
                  label: 'Video Post',
                  description: 'Share videos or clips',
                  type: 'video',
                  colorScheme: colorScheme,
                  iconColor: Colors.redAccent,
                ),
                const SizedBox(height: 16),
                _buildPostTypeCard(
                  context: context,
                  icon: Icons.text_fields_rounded,
                  label: 'Text Post',
                  description: 'Write your thoughts',
                  type: 'text',
                  colorScheme: colorScheme,
                  iconColor: Colors.greenAccent,
                ),
                const SizedBox(height: 16),
                _buildPostTypeCard(
                  context: context,
                  icon: Icons.link_rounded,
                  label: 'Link Post',
                  description: 'Share interesting links',
                  type: 'link',
                  colorScheme: colorScheme,
                  iconColor: Colors.purpleAccent,
                ),
                const SizedBox(height: 24),
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
    required ColorScheme colorScheme,
    required Color iconColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => navigateToType(context, type),
        splashFactory: InkRipple.splashFactory,
        overlayColor: MaterialStateProperty.resolveWith<Color?>(
              (states) => states.contains(MaterialState.pressed)
              ? colorScheme.primary.withOpacity(0.1)
              : null,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: colorScheme.outlineVariant.withOpacity(0.5),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconColor.withOpacity(0.15),
                ),
                child: Icon(
                  icon,
                  size: 26,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 26,
                color: colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}