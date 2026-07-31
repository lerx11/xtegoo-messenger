import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/core.dart';

/// Виджет кружочка сторис с сегментированной градиентной обводкой.
///
/// Количество сегментов = количество сторис пользователя (1-4+, при 4+ рисуем 4).
/// Внутри — аватарка/иконка. Для «Моей истории» — плюсик в правом нижнем углу.
class StorySegmentedRing extends StatelessWidget {
  /// Имя (для тултипа/доступности)
  final String name;

  /// true, если это «Моя история» — рисуем плюсик
  final bool isMine;

  /// Количество сторис (определяет число сегментов обводки)
  final int storiesCount;

  /// Размер кружочка (диаметр)
  final double size;

  /// URL аватарки (опционально)
  final String? avatarUrl;

  /// Обработчик нажатия
  final VoidCallback onTap;

  /// Показывать ли имя под кружочком
  final bool showName;

  const StorySegmentedRing({
    super.key,
    required this.name,
    this.isMine = false,
    this.storiesCount = 1,
    this.size = AppSizes.storySize,
    this.avatarUrl,
    required this.onTap,
    this.showName = true,
  });

  @override
  Widget build(BuildContext context) {
    // Число сегментов: 1..4 (при 4+ фиксируем 4)
    final segments = storiesCount.clamp(1, 4);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Сегментированная обводка + содержимое
                CustomPaint(
                  size: Size(size, size),
                  painter: _SegmentedRingPainter(segments: segments),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.storyBorderWidth),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: _buildInnerContent(),
                    ),
                  ),
                ),
                // Плюсик в правом нижнем углу для «Моей истории»
                if (isMine)
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: size * 0.32,
                      height: size * 0.32,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 14),
                    ),
                  ),
              ],
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

  // Внутреннее содержимое кружочка: аватарка или иконка
  Widget _buildInnerContent() {
    if (avatarUrl != null) {
      return ClipOval(
        child: Image.network(
          avatarUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.person,
            color: AppColors.textTertiary,
          ),
        ),
      );
    }
    return isMine
        ? const Icon(Icons.person, color: AppColors.textTertiary)
        : const Icon(Icons.person, color: AppColors.textTertiary);
  }
}

/// CustomPainter для сегментированной градиентной обводки.
class _SegmentedRingPainter extends CustomPainter {
  /// Количество сегментов (1..4)
  final int segments;

  _SegmentedRingPainter({required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) / 2) - AppSizes.storyBorderWidth;

    // Градиентная кисть #218D8C → #66D7D3
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.primary, AppColors.primaryLight],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // Полный круг = 2π. Зазор между сегментами.
    const gapAngle = 0.15; // ~8.6°
    final totalGap = gapAngle * segments;
    final segmentAngle = (2 * math.pi - totalGap) / segments;

    // Стартуем сверху (-π/2)
    double startAngle = -math.pi / 2;
    for (int i = 0; i < segments; i++) {
      canvas.drawArc(
        rect,
        startAngle,
        segmentAngle,
        false,
        paint,
      );
      startAngle += segmentAngle + gapAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _SegmentedRingPainter oldDelegate) =>
      oldDelegate.segments != segments;
}
