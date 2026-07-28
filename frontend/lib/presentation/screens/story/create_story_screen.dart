import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/core.dart';

class CreateStoryScreen extends StatefulWidget {
  const CreateStoryScreen({super.key});

  @override
  State<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _pickFromGallery() async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      // Публикация сториса
      context.pop();
    }
  }

  Future<void> _takePhoto() async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
    if (image != null && mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Создать сторис', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(AppPadding.screen),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: const Center(
                  child: Icon(Icons.photo_camera, size: 100, color: Colors.white24),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppPadding.screen),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildOptionButton(
                    icon: Icons.photo_library,
                    label: 'Галерея',
                    onTap: _pickFromGallery,
                  ),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, size: 32, color: Colors.black),
                      onPressed: _takePhoto,
                    ),
                  ),
                  _buildOptionButton(
                    icon: Icons.videocam,
                    label: 'Видео',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Colors.white12,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}
