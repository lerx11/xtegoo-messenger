import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/core.dart';
import '../../../data/services/user_service.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  List<dynamic> _results = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      setState(() {
        _results = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final userService = ref.read(userServiceProvider);
      final users = await userService.search(query);
      setState(() {
        _results = users;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          onChanged: _search,
          decoration: const InputDecoration(
            hintText: 'Поиск по нику или телефону',
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                setState(() => _results = []);
              },
            ),
        ],
      ),
      body: _isSearching
          ? const Center(child: CircularProgressIndicator())
          : _results.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final user = _results[index];
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.secondarySurface,
                        child: Icon(Icons.person, color: AppColors.textTertiary),
                      ),
                      title: Text(user.fullName ?? 'Пользователь'),
                      subtitle: Text(user.username ?? ''),
                      trailing: TextButton(
                        onPressed: () {
                          context.push('/chat/${user.id}');
                        },
                        child: const Text('Написать'),
                      ),
                      onTap: () => context.push('/profile/${user.id}'),
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search, size: 64, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text(
            'Найдите пользователей, бизнесы, каналы',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
