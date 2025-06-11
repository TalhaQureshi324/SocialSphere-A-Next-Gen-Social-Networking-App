import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImageSlider extends ConsumerStatefulWidget {
  final List<String> imageUrls;
  const ImageSlider({super.key, required this.imageUrls});

  @override
  ConsumerState<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends ConsumerState<ImageSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // Image Slider
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: widget.imageUrls.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Image.network(
                      widget.imageUrls[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: colorScheme.surfaceContainerHighest,
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / 
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            color: colorScheme.primary,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: colorScheme.surfaceContainerHighest,
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.broken_image,
                            color: colorScheme.onSurfaceVariant,
                            size: 40,
                          ),
                        );
                      },
                    );
                  },
                ),
                
                // Page Indicator
                if (widget.imageUrls.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.imageUrls.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentPage == index
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant.withOpacity(0.4),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        
        // Navigation Arrows (only show if multiple images)
        if (widget.imageUrls.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.chevron_left, size: 32),
                  onPressed: _currentPage > 0
                      ? () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: Icon(Icons.chevron_right, size: 32),
                  onPressed: _currentPage < widget.imageUrls.length - 1
                      ? () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
                ),
              ],
            ),
          ),
      ],
    );
  }
}