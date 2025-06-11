import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_sphere/core/common/loader.dart';
import 'package:social_sphere/core/common/sign_button.dart';
import 'package:social_sphere/core/constants/constants.dart';
import 'package:social_sphere/features/auth/controller/auth_controller.dart';
import 'package:social_sphere/responsive/responsive.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  void signInAsGuest(WidgetRef ref, BuildContext context) {
    ref.read(authControllerProvider.notifier).signInAsGuest(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authControllerProvider);
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final isMobile = Responsive.isMobile(context);

    // Enhanced color scheme with social/energetic vibe
    final ColorScheme colorScheme = isDarkMode
        ? const ColorScheme.dark(
            primary: Color(0xFF9C27B0), // Vibrant purple
            secondary: Color(0xFF00E5FF), // Cyan accent
            surface: Color(0xFF121212),
            background: Color(0xFF000000),
          )
        : const ColorScheme.light(
            primary: Color(0xFF6200EE), // Deep purple
            secondary: Color(0xFF03DAC6), // Teal accent
            surface: Colors.white,
            background: Color(0xFFF5F5F5),
          );

    // Responsive values
    final double logoHeight = math.min(
      size.height * (isMobile ? 0.25 : 0.33),
      isMobile ? 200 : 300,
    );
    
    final double cardHeight = size.height * (isMobile ? 0.6 : 0.5);
    final double cardHorizontalMargin = isMobile ? 16 : 24;
    final double cardBottomMargin = isMobile ? 16 : 24;

    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? const Loader()
            : Stack(
                children: [
                  // Dynamic gradient background
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 800),
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: isDarkMode
                            ? [
                                colorScheme.primary.withOpacity(0.2),
                                colorScheme.background,
                                Colors.black,
                              ]
                            : [
                                colorScheme.primary.withOpacity(0.1),
                                colorScheme.background,
                                Colors.white,
                              ],
                        center: Alignment.topRight,
                        radius: 1.5,
                        stops: const [0.1, 0.5, 1.0],
                      ),
                    ),
                  ),

                  // Animated floating particles
                  ..._buildFloatingParticles(size, colorScheme, isMobile),

                  // App logo with subtle glow
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.only(top: size.height * 0.05),
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.2),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Hero(
                          tag: 'app-logo',
                          child: Image.asset(
                            Constants.logopath,
                            height: logoHeight,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Glassmorphic card
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      height: cardHeight,
                      margin: EdgeInsets.only(
                        left: cardHorizontalMargin,
                        right: cardHorizontalMargin,
                        bottom: cardBottomMargin,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.black.withOpacity(0.4)
                                  : Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  colorScheme.surface.withOpacity(0.6),
                                  colorScheme.surface.withOpacity(0.3),
                                ],
                              ),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 20 : 24,
                              vertical: isMobile ? 16 : 24,
                            ),
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: _buildCardContent(
                                  context, theme, colorScheme, ref, isMobile),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  List<Widget> _buildFloatingParticles(
      Size size, ColorScheme colorScheme, bool isMobile) {
    final double particleSize = size.width * (isMobile ? 0.2 : 0.3);

    return [
      // Primary color particles
      _AnimatedParticle(
        size: particleSize,
        color: colorScheme.primary.withOpacity(0.15),
        duration: const Duration(seconds: 15),
        begin: const Alignment(0.8, -0.6),
        end: const Alignment(-0.8, 0.6),
      ),
      _AnimatedParticle(
        size: particleSize,
        color: colorScheme.primary.withOpacity(0.1),
        duration: const Duration(seconds: 20),
        begin: const Alignment(-0.5, -0.7),
        end: const Alignment(0.5, 0.7),
      ),
      // Secondary color particles
      _AnimatedParticle(
        size: particleSize,
        color: colorScheme.secondary.withOpacity(0.1),
        duration: const Duration(seconds: 25),
        begin: const Alignment(0.3, -0.8),
        end: const Alignment(-0.3, 0.8),
      ),
    ];
  }

  Widget _buildCardContent(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    WidgetRef ref,
    bool isMobile,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Welcome text with gradient
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              colorScheme.primary,
              colorScheme.secondary,
            ],
          ).createShader(bounds),
          child: Column(
            children: [
              Text(
                "Welcome to",
                style: TextStyle(
                  fontSize: isMobile ? 22 : 24,
                  fontWeight: FontWeight.w300,
                ),
              ),
              Text(
                "Social Sphere",
                style: TextStyle(
                  fontSize: isMobile ? 30 : 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Connect. Share. Grow.",
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
            fontStyle: FontStyle.italic,
          ),
        ),
        SizedBox(height: isMobile ? 30 : 40),
        // Sign in button with subtle gradient
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [
                colorScheme.primary,
                colorScheme.secondary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Responsive(child: SignInButton()),
        ),
        SizedBox(height: isMobile ? 20 : 30),
        // Guest login option
        Column(
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => signInAsGuest(ref, context),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: isMobile ? 6 : 8,
                    horizontal: isMobile ? 12 : 16,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colorScheme.secondary.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    "Continue as Guest",
                    style: TextStyle(
                      color: colorScheme.secondary.withOpacity(0.7),
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "No account? No problem!",
              style: TextStyle(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                fontSize: isMobile ? 12 : 13,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AnimatedParticle extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;
  final Alignment begin;
  final Alignment end;

  const _AnimatedParticle({
    required this.size,
    required this.color,
    required this.duration,
    required this.begin,
    required this.end,
  });

  @override
  _AnimatedParticleState createState() => _AnimatedParticleState();
}

class _AnimatedParticleState extends State<_AnimatedParticle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);
    _animation = AlignmentTween(
      begin: widget.begin,
      end: widget.end,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Positioned.fill(
          child: Align(
            alignment: _animation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
              ),
            ),
          ),
        );
      },
    );
  }
}