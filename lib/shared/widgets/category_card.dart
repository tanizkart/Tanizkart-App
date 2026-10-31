import 'package:flutter/material.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/motion.dart';
import '../../data/models/category_model.dart';
import 'taniz_image.dart';

/// Ultra-Modern Blinkit-Style Category Card
/// Features rounded pastel squircle container, specular glass border,
/// crisp product category image with fallback emoji badge, and clean bold typography.
class CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;
  final double width;
  final double height;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
    this.width = 76,
    this.height = 76,
  });

  @override
  Widget build(BuildContext context) {
    return TanizTappable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      scaleTo: 0.94,
      child: SizedBox(
        width: width + 4,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Container with pastel background, glossy white border, and soft shadow
            Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: Color(category.backgroundColorValue),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.95),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                  BoxShadow(
                    color: Color(category.backgroundColorValue).withValues(alpha: 0.5),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // High-Res Image
                  TanizImage(
                    imageUrl: category.iconUrl,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(19),
                    fallbackEmoji: category.emoji ?? '🛒',
                    fallbackLabel: category.name,
                  ),

                  // Top-Right Unique Emoji Badge
                  if (category.emoji != null)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Text(
                          category.emoji!,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),

                  // Bottom mini badge if present (e.g. "Daily", "Party")
                  if (category.badge != null)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xCC0F172A),
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(19)),
                        ),
                        child: Text(
                          category.badge!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 1,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 7),

            // Category Name (Clean 2-line centered label)
            Text(
              category.name,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TanizTypography.caption.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 11,
                color: const Color(0xFF0F172A),
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
