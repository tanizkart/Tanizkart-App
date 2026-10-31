import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/motion.dart';
import '../../core/theme/typography.dart';

/// Ultra-Resilient, High-Performance Image Widget for TanizKart
///
/// Features:
/// 1. Dual-Engine Rendering:
///    - Web: Uses native `Image.network` which delegates to the browser's native `<img>`
///      loader, completely bypassing CORS `HttpRequest` blocks.
///    - Mobile/Desktop: Uses `CachedNetworkImage` for local disk & memory caching.
/// 2. Controlled Retries with Backoff:
///    - Automatically retries loading on failure up to [maxRetries] with exponential backoff.
/// 3. Layout Shift Prevention:
///    - Shows exact-dimension [TanizShimmerBox] placeholder during load.
/// 4. Polished Fallback Product Thumbnail:
///    - Never displays raw icons, blank cards, or broken-image glyphs.
///    - Renders a clean, high-end branded fallback thumbnail.
class TanizImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final String? heroTag;
  final String? fallbackEmoji;
  final String? fallbackLabel;
  final Widget? customPlaceholder;
  final Widget? customFallback;
  final int maxRetries;

  const TanizImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.heroTag,
    this.fallbackEmoji,
    this.fallbackLabel,
    this.customPlaceholder,
    this.customFallback,
    this.maxRetries = 2,
  });

  @override
  State<TanizImage> createState() => _TanizImageState();
}

class _TanizImageState extends State<TanizImage> {
  int _retryCount = 0;
  bool _hasError = false;
  Timer? _retryTimer;
  Key _imageKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _validateUrl();
  }

  @override
  void didUpdateWidget(covariant TanizImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _retryTimer?.cancel();
      _retryCount = 0;
      _hasError = false;
      _imageKey = UniqueKey();
      _validateUrl();
    }
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    super.dispose();
  }

  void _validateUrl() {
    if (widget.imageUrl.trim().isEmpty) {
      _hasError = true;
    }
  }

  void _handleImageError() {
    if (!mounted) return;
    if (_retryCount < widget.maxRetries) {
      _retryCount++;
      final delayMs = 600 * _retryCount;
      _retryTimer?.cancel();
      _retryTimer = Timer(Duration(milliseconds: delayMs), () {
        if (mounted) {
          setState(() {
            _hasError = false;
            _imageKey = UniqueKey();
          });
        }
      });
    } else {
      setState(() {
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_hasError) {
      content = _buildPolishedFallback();
    } else if (kIsWeb) {
      content = _buildWebImage();
    } else {
      content = _buildNativeImage();
    }

    if (widget.borderRadius != null) {
      content = ClipRRect(
        borderRadius: widget.borderRadius!,
        child: content,
      );
    }

    if (widget.heroTag != null) {
      return Hero(
        tag: widget.heroTag!,
        child: content,
      );
    }

    return content;
  }

  Widget _buildWebImage() {
    return Image.network(
      widget.imageUrl,
      key: _imageKey,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      gaplessPlayback: true,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildPlaceholder();
      },
      errorBuilder: (context, error, stackTrace) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _handleImageError());
        return _buildPolishedFallback();
      },
    );
  }

  Widget _buildNativeImage() {
    return CachedNetworkImage(
      key: _imageKey,
      imageUrl: widget.imageUrl,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      placeholder: (context, url) => _buildPlaceholder(),
      errorWidget: (context, url, error) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _handleImageError());
        return _buildPolishedFallback();
      },
    );
  }

  Widget _buildPlaceholder() {
    if (widget.customPlaceholder != null) {
      return widget.customPlaceholder!;
    }
    return TanizShimmerBox(
      width: widget.width ?? double.infinity,
      height: widget.height ?? double.infinity,
      borderRadius: widget.borderRadius != null ? 0 : 0,
    );
  }

  Widget _buildPolishedFallback() {
    if (widget.customFallback != null) {
      return widget.customFallback!;
    }

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFF8FAFC),
            TanizColors.surfaceLow,
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background delicate brand accent
          Positioned(
            bottom: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: TanizColors.primaryBlue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'TANIZ FRESH',
                style: TanizTypography.caption.copyWith(
                  color: TanizColors.primaryBlue.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w800,
                  fontSize: 8,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ),

          // Central Emoji / Label Badge
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.fallbackEmoji != null && widget.fallbackEmoji!.isNotEmpty)
                Text(
                  widget.fallbackEmoji!,
                  style: const TextStyle(fontSize: 28),
                )
              else
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🛒', style: TextStyle(fontSize: 20)),
                  ),
                ),
              if (widget.fallbackLabel != null && widget.fallbackLabel!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    widget.fallbackLabel!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TanizTypography.caption.copyWith(
                      color: TanizColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 9.5,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
