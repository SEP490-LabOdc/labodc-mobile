// lib/features/admin/presentation/pages/admin_profile_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_constants.dart';

class AdminProfilePage extends StatelessWidget {
  const AdminProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
              "Hồ sơ Quản trị viên",
              style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'Cài đặt',
              onPressed: () {
                context.push(Routes.setting);
              },
            ),
          ],
        ),
        body: const Center(
          child: Text("Admin Profile Page Content"),
        ));
  }
}