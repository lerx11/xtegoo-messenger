import 'package:flutter/material.dart';
import '../../../core/core.dart';

class StoryRingWidget extends StatelessWidget {
  final String name;
  final bool isMine;
  final bool isExpanded;
  final VoidCallback onTap;

  const StoryRingWidget({
    super.key,
    required this.name,
    this.isMine = false,
    this.isExpanded = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = isExpanded ? AppSizes.storySize : 32.0;
    final showName = isExpanded;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isMine
                  ? null
                  : const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.storyBorderWidth),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: isMine
                    ? const Icon(Icons.add, color: AppColors.primary, size: 20)
                    : const Icon(Icons.person, color: AppColors.textTertiary, size: 24),
              ),
            ),
          ),
          if (showName) ...[
            const SizedBox(height: 6),
            SizedBox(
              width: size,
              child: Text(
                name,
                style: AppTextStyles.small.copyWith(color: AppColors.textPrimary),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
