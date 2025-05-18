import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_sphere/theme/pallete.dart';

class ModToolsScreen extends ConsumerWidget {
  final String name;
  const ModToolsScreen({super.key, required this.name});

  void navigateToEditCommunity(BuildContext context) {
    Routemaster.of(context).push('/edit-community/$name');
  }

  void navigateToAddMods(BuildContext context) {
    Routemaster.of(context).push('/add-mods/$name');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeNotifierProvider);
    final isDark = theme.brightness == Brightness.dark;

    // Color scheme matching previous files
    final cardColor = isDark
        ? Color.lerp(theme.cardColor, Colors.black, 0.3)!
        : Color.lerp(theme.cardColor, Colors.white, 0.95)!;

    final hoverColor = isDark
        ? Colors.blue.shade900.withOpacity(0.2)
        : Colors.blue.shade100.withOpacity(0.3);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Admin Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: theme.textTheme.titleLarge?.color,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: IconThemeData(
          color: theme.iconTheme.color,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              icon: Icon(Icons.help_outline, color: theme.iconTheme.color),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Community Header
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Managing: $name',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.textTheme.titleLarge?.color?.withOpacity(0.8),
                ),
              ),
            ),

            // Tools List
            _ModOptionTile(
              icon: Icons.add_moderator,
              label: 'Add Admins',
              description: 'Manage group admins',
              onTap: () => navigateToAddMods(context),
              theme: theme,
              cardColor: isDark ? theme.colorScheme.surfaceVariant.withOpacity(0.3) : theme.colorScheme.surfaceVariant.withOpacity(0.5),
              hoverColor: hoverColor,
              iconColor: Pallete.blueColor,
            ),
            const SizedBox(height: 12),
            _ModOptionTile(
              icon: Icons.edit,
              label: 'Edit Groups',
              description: 'Change name, description & settings',
              onTap: () => navigateToEditCommunity(context),
              theme: theme,
              cardColor: isDark ? theme.colorScheme.surfaceVariant.withOpacity(0.3) : theme.colorScheme.surfaceVariant.withOpacity(0.5),
              hoverColor: hoverColor,
              iconColor: Colors.blue.shade400,
            ),
            const SizedBox(height: 12),
            _ModOptionTile(
              icon: Icons.people,
              label: 'Member Controls',
              description: 'Manage bans and approvals',
              onTap: () {},
              theme: theme,
              cardColor: isDark ? theme.colorScheme.surfaceVariant.withOpacity(0.3) : theme.colorScheme.surfaceVariant.withOpacity(0.5),
              hoverColor: hoverColor,
              iconColor: Colors.blue.shade300,
              comingSoon: true,
            ),

            // Spacer and version info
            const Spacer(),
            Divider(
              color: theme.dividerColor.withOpacity(0.2),
              height: 1,
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                'Community Admin Tools v1.0',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodyLarge?.color?.withOpacity(0.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModOptionTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;
  final ThemeData theme;
  final Color cardColor;
  final Color hoverColor;
  final Color iconColor;
  final bool comingSoon;

  const _ModOptionTile({
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
    required this.theme,
    required this.cardColor,
    required this.hoverColor,
    required this.iconColor,
    this.comingSoon = false,
  });

  @override
  State<_ModOptionTile> createState() => _ModOptionTileState();
}

class _ModOptionTileState extends State<_ModOptionTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _isHovered ? widget.hoverColor : widget.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isHovered
                ? widget.iconColor.withOpacity(0.3)
                : widget.theme.dividerColor.withOpacity(0.1),
            width: 0.5,
          ),
          boxShadow: [
            if (_isHovered)
              BoxShadow(
                color: widget.iconColor.withOpacity(0.05),
                blurRadius: 8,
                spreadRadius: 1,
              ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: widget.comingSoon
              ? () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${widget.label} coming in next update!'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: widget.theme.snackBarTheme.backgroundColor,
              ),
            );
          }
              : widget.onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon with gradient background
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.iconColor.withOpacity(0.1),
                        widget.iconColor.withOpacity(0.05),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.icon,
                    size: 24,
                    color: widget.iconColor,
                  ),
                ),
                const SizedBox(width: 16),

                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.label,
                        style: widget.theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: widget.theme.textTheme.titleMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.description,
                        style: widget.theme.textTheme.bodyMedium?.copyWith(
                          color: widget.theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                // Coming soon badge or arrow
                if (widget.comingSoon)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: widget.theme.colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Soon',
                      style: widget.theme.textTheme.labelSmall?.copyWith(
                        color: widget.theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                else
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: widget.theme.iconTheme.color?.withOpacity(0.6),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}