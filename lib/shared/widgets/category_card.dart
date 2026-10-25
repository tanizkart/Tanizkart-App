import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/motion.dart';
import '../../data/models/category_model.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TanizTappable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Fixed-aspect ClipRRect with radius: 16 and BoxFit.cover
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Color(category.backgroundColorValue),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: TanizColors.primaryBlue.withValues(alpha: 0.08),
                  width: 1,
                ),
                boxShadow: [TanizColors.cardShadow],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Hero(
                  tag: 'cat_img_${category.id}',
                  child: CachedNetworkImage(
                    imageUrl: category.iconUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const TanizShimmerBox(
                      width: 72,
                      height: 72,
                      borderRadius: 16,
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: TanizColors.surfaceLow,
                      child: const Center(
                        child: Icon(
                          Icons.category_rounded,
                          size: 28,
                          color: TanizColors.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8), // Standard 8px spacing
            Text(
              category.name,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TanizTypography.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: TanizColors.textPrimary,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
