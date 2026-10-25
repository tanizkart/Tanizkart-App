import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';

class SearchInputBar extends StatelessWidget {
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final String hintText;

  const SearchInputBar({
    super.key,
    this.onTap,
    this.onChanged,
    this.readOnly = false,
    this.hintText = 'Search "milk", "eggs", "oil", "snacks"...',
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: TanizColors.borderSubtle,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search_rounded,
              color: TanizColors.primaryBlue,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: readOnly
                  ? Text(
                      hintText,
                      style: TanizTypography.bodyMedium.copyWith(
                        color: TanizColors.textMuted,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    )
                  : TextField(
                      onChanged: onChanged,
                      decoration: InputDecoration(
                        hintText: hintText,
                        hintStyle: TanizTypography.bodyMedium.copyWith(
                          color: TanizColors.textMuted,
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
            ),
            Row(
              children: [
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
                const SizedBox(width: 8),
                const Icon(
                  Icons.qr_code_scanner_rounded,
                  color: TanizColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
