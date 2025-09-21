import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/domain/entity/theme_entity.dart';
import '../../../auth/presentation/provider/auth_provider.dart';
import '../../../user/presentation/pages/profile_page.dart';
import '../../../../core/config/networks/config.dart';
import '../../../../core/theme/bloc/theme_bloc.dart';
import '../../../../core/theme/bloc/theme_events.dart';
import '../../../../core/theme/bloc/theme_state.dart';
import 'post_detail_page.dart';

class NewsItem {
  final int userId;
  final int id;
  final String title;
  final String body;

  NewsItem({
    required this.userId,
    required this.id,
    required this.title,
    required this.body,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
      body: json['body'],
    );
  }
}

Future<List<NewsItem>> fetchNews() async {
  final url = Uri.parse('https://jsonplaceholder.typicode.com/posts');
  final response = await http.get(
    url,
    headers: {
      "Accept": "application/json",
      "Content-Type": "application/json",
      "User-Agent": "LabOdcApp/1.0"
    },
  );

  print('Status code: ${response.statusCode}');
  print('Response body: ${response.body}');

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((item) => NewsItem.fromJson(item)).toList();
  } else {
    throw Exception('Failed to load posts: ${response.statusCode}');
  }
}


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  late Future<List<NewsItem>> _newsFuture;

  @override
  void initState() {
    super.initState();
    // Initialize the future once to avoid rebuilding on every setState
    _newsFuture = fetchNews();
  }

  Widget _buildHomeContent() {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _newsFuture = fetchNews();
        });
      },
      child: FutureBuilder<List<NewsItem>>(
        future: _newsFuture,
        builder: (context, snapshot) {
          print('ConnectionState: ${snapshot.connectionState}');
          print('Has data: ${snapshot.hasData}');
          print('Has error: ${snapshot.hasError}');

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Đang tải tin tức...'),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Lỗi tải dữ liệu',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _newsFuture = fetchNews();
                        });
                      },
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Không có dữ liệu'),
            );
          }

          final news = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: news.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text('${news[index].id}'),
                  ),
                  title: Text(news[index].title),
                  subtitle: Text(news[index].body),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    context.push(
                      '/home/post_detail',
                      extra: news[index],
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final themeBloc = context.read<ThemeBloc>();
    final isDark = context.watch<ThemeBloc>().state.themeEntity?.themeType == ThemeType.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentIndex == 0 ? 'Tin tức' : 'Hồ sơ'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
            tooltip: isDark ? 'Chuyển sang chế độ sáng' : 'Chuyển sang chế độ tối',
            onPressed: () {
              themeBloc.add(ToggleThemeEvent());
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeContent(),
          authProvider.isAuthenticated
              ? const ProfilePage()
              : const Center(
            child: Text("Bạn cần đăng nhập để xem trang này"),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 1 && !authProvider.isAuthenticated) {
            context.goNamed('login');
          } else {
            setState(() => _currentIndex = index);
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Trang chủ",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Hồ sơ",
          ),
        ],
      ),
    );
  }
}