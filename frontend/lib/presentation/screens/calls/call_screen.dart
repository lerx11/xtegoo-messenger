import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/core.dart';

class CallScreen extends ConsumerStatefulWidget {
  final String userId;

  const CallScreen({super.key, required this.userId});

  @override
  ConsumerState<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen> {
  bool _isMuted = false;
  bool _isSpeakerOn = false;
  bool _isVideoEnabled = true;
  bool _isConnecting = true;
  int _callDuration = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _isConnecting = false);
      _startCallTimer();
    });
  }

  void _startCallTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() => _callDuration++);
        return true;
      }
      return false;
    });
  }

  String _formatDuration(int seconds) {
    final min = seconds ~/ 60;
    final sec = seconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SafeArea(
        child: Column(
          children: [
            // Верхняя часть с информацией
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person, size: 60, color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Анна Иванова',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isConnecting ? 'Соединение...' : _formatDuration(_callDuration),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            // Кнопки управления
            Padding(
              padding: const EdgeInsets.all(AppPadding.screen),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCallButton(
                    icon: _isMuted ? Icons.mic_off : Icons.mic,
                    label: 'Микрофон',
                    onPressed: () {
                      setState(() => _isMuted = !_isMuted);
                    },
                    isActive: !_isMuted,
                  ),
                  _buildCallButton(
                    icon: Icons.call_end,
                    label: 'Завершить',
                    onPressed: () => context.pop(),
                    isEndCall: true,
                  ),
                  _buildCallButton(
                    icon: _isVideoEnabled ? Icons.videocam : Icons.videocam_off,
                    label: 'Видео',
                    onPressed: () {
                      setState(() => _isVideoEnabled = !_isVideoEnabled);
                    },
                    isActive: _isVideoEnabled,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppPadding.screen),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCallButton(
                    icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_down,
                    label: 'Динамик',
                    onPressed: () {
                      setState(() => _isSpeakerOn = !_isSpeakerOn);
                    },
                    isActive: _isSpeakerOn,
                  ),
                  _buildCallButton(
                    icon: Icons.switch_camera,
                    label: 'Камера',
                    onPressed: () {},
                    isActive: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCallButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isActive = true,
    bool isEndCall = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isEndCall
                  ? AppColors.error
                  : isActive
                      ? Colors.white.withOpacity(0.2)
                      : Colors.white10,
            ),
            child: Icon(
              icon,
              color: isEndCall ? Colors.white : Colors.white,
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
