import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/motion.dart';

class SearchInputBar extends StatelessWidget {
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool readOnly;
  final String hintText;
  final VoidCallback? onClear;
  final VoidCallback? onClose;
  final bool showCloseButton;

  const SearchInputBar({
    super.key,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.controller,
    this.focusNode,
    this.autofocus = false,
    this.readOnly = false,
    this.hintText = 'Search for atta, dal, milk and more',
    this.onClear,
    this.onClose,
    this.showCloseButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (!readOnly && (focusNode?.hasFocus ?? false))
              ? TanizColors.primaryBlue
              : TanizColors.borderSubtle,
          width: (!readOnly && (focusNode?.hasFocus ?? false)) ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (showCloseButton && onClose != null)
            TanizTappable(
              onTap: onClose,
              child: const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: TanizColors.primaryBlue,
                  size: 20,
                ),
              ),
            )
          else
            const Icon(
              Icons.search_rounded,
              color: TanizColors.primaryBlue,
              size: 22,
            ),
          const SizedBox(width: 8),
          Expanded(
            child: readOnly
                ? GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onTap,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        hintText,
                        style: TanizTypography.bodyMedium.copyWith(
                          color: TanizColors.textMuted,
                          fontSize: 13.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                : TextField(
                    controller: controller,
                    focusNode: focusNode,
                    autofocus: autofocus,
                    onChanged: onChanged,
                    onSubmitted: onSubmitted,
                    textInputAction: TextInputAction.search,
                    style: TanizTypography.bodyMedium.copyWith(
                      color: TanizColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                    ),
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: TanizTypography.bodyMedium.copyWith(
                        color: TanizColors.textMuted,
                        fontSize: 13.5,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
          ),
          if (!readOnly && (controller?.text.isNotEmpty ?? false))
            TanizTappable(
              onTap: onClear ?? () {
                controller?.clear();
                onChanged?.call('');
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: TanizColors.surfaceLow,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: TanizColors.textSecondary,
                ),
              ),
            )
          else ...[
            Container(
              width: 1,
              height: 20,
              color: TanizColors.borderSubtle,
              margin: const EdgeInsets.symmetric(horizontal: 8),
            ),
            const Icon(
              Icons.mic_none_rounded,
              color: TanizColors.textSecondary,
              size: 20,
            ),
          ],
        ],
      ),
    );
  }
}
