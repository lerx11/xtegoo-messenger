import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/core.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _firstNameController = TextEditingController(text: 'Иван');
  final _lastNameController = TextEditingController(text: 'Иванов');
  final _usernameController = TextEditingController(text: '@ivan_ivanov');
  final _bioController = TextEditingController(text: 'Разработчик мобильных приложений');
  String _selectedLanguage = 'Русский';
  bool _isBusiness = false;

  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _pickAvatar() async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // Обновление аватара
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактировать профиль'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppPadding.screen),
        children: [
          // Аватар
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickAvatar,
                  child: const CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.secondarySurface,
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Icon(Icons.person, size: 50, color: AppColors.textTertiary),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.primary,
                            child: Icon(Icons.camera_alt, size: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _pickAvatar,
                  child: const Text('Изменить фото'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Имя
          const Text('Имя', style: AppTextStyles.caption),
          const SizedBox(height: 8),
          TextField(
            controller: _firstNameController,
            decoration: const InputDecoration(
              hintText: 'Имя',
            ),
          ),
          const SizedBox(height: 16),
          // Фамилия
          const Text('Фамилия', style: AppTextStyles.caption),
          const SizedBox(height: 8),
          TextField(
            controller: _lastNameController,
            decoration: const InputDecoration(
              hintText: 'Фамилия',
            ),
          ),
          const SizedBox(height: 16),
          // Ник
          const Text('Никнейм', style: AppTextStyles.caption),
          const SizedBox(height: 8),
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(
              hintText: '@username',
              prefixText: '@ ',
            ),
          ),
          const SizedBox(height: 16),
          // О себе
          const Text('О себе', style: AppTextStyles.caption),
          const SizedBox(height: 8),
          TextField(
            controller: _bioController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Расскажите о себе',
            ),
          ),
          const SizedBox(height: 24),
          // Язык
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Язык приложения'),
            subtitle: Text(_selectedLanguage),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showLanguagePicker(),
          ),
          const Divider(height: 1),
          // Бизнес аккаунт
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Бизнес-аккаунт'),
            subtitle: const Text('Включите для продвижения бизнеса'),
            value: _isBusiness,
            onChanged: (value) {
              setState(() => _isBusiness = value);
            },
          ),
          if (_isBusiness) ...[
            const SizedBox(height: 8),
            const Text('Название бизнеса', style: AppTextStyles.caption),
            const SizedBox(height: 8),
            const TextField(
              decoration: InputDecoration(hintText: 'Название компании'),
            ),
            const SizedBox(height: 16),
            const Text('Описание', style: AppTextStyles.caption),
            const SizedBox(height: 8),
            const TextField(
              maxLines: 2,
              decoration: InputDecoration(hintText: 'Чем занимаетесь?'),
            ),
          ],
          const SizedBox(height: 32),
          // Сохранить
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Профиль сохранён')),
                );
                context.pop();
              },
              child: const Text('Сохранить'),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker() {
    final languages = ['Русский', 'English', '中文', 'Español', 'Français', 'Deutsch'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.bottomSheet)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppPadding.screen),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Выберите язык', style: AppTextStyles.navigation),
            const SizedBox(height: 16),
            ...languages.map(
              (lang) => ListTile(
                title: Text(lang),
                trailing: _selectedLanguage == lang
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  setState(() => _selectedLanguage = lang);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
