import 'package:flutter/material.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Nhiệm vụ của bạn 📝"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "To Do (5)"),
              Tab(text: "In Progress (2)"),
              Tab(text: "Done"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _TaskList(status: "To Do"),
            _TaskList(status: "In Progress"),
            _TaskList(status: "Done"),
          ],
        ),
      ),
    );
  }
}

class _TaskList extends StatelessWidget {
  final String status;

  const _TaskList({required this.status});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: const [
        Card(child: ListTile(title: Text("[API] Tích hợp thanh toán"), subtitle: Text("Dự án X - Hôm nay"))),
        Card(child: ListTile(title: Text("[UI] Thiết kế trang chủ"), subtitle: Text("Dự án Y - Ngày mai"))),
        Card(child: ListTile(title: Text("[BUG] Sửa lỗi hiển thị mobile"), subtitle: Text("Dự án X - 25/09"))),
      ],
    );
  }
}
