import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/core.dart';

class StoryViewerScreen extends StatefulWidget {
  final String userId;

  const StoryViewerScreen({super.key, required this.userId});

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentIndex = 0;

  final List<String> _stories = [
    '', '', '', // 3 сториса
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _nextStory();
        }
      });
    _controller.forward();
  }

  void _nextStory() {
    if (_currentIndex < _stories.length - 1) {
      setState(() => _currentIndex++);
      _controller.reset();
      _controller.forward();
    } else {
      context.pop();
    }
  }

  void _previousStory() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Контент сториса
            GestureDetector(
              onTapUp: (details) {
                final width = MediaQuery.of(context).size.width;
                if (details.globalPosition.dx < width / 3) {
                  _previousStory();
                } else {
                  _nextStory();
                }
              },
              child: Container(
                color: AppColors.primaryDark,
                child: const Center(
                  child: Icon(Icons.image, size: 100, color: Colors.white24),
                ),
              ),
            ),
            // Верхний прогресс-бар
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: List.generate(
                  _stories.length,
                  (index) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: _buildProgressBar(index),
                    ),
                  ),
                ),
              ),
            ),
            // Информация о пользователе
            Positioned(
              top: 32,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Иван Иванов',
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
            ),
            // Ответ внизу
            Positioned(
              bottom: 20,
              left: AppPadding.screen,
              right: AppPadding.screen,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Text(
                        'Отправить сообщение',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.favorite_border, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(int index) {
    double value;
    if (index < _currentIndex) {
      value = 1.0;
    } else if (index == _currentIndex) {
      value = _controller.value;
    } else {
      value = 0.0;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return LinearProgressIndicator(
          value: value,
          backgroundColor: Colors.white24,
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          borderRadius: BorderRadius.circular(2),
          minHeight: 2,
        );
      },
    );
  }
}
