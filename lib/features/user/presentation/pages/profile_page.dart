import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/provider/auth_provider.dart';
import '../provider/user_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final userProvider = context.watch<UserProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Center(
        child: userProvider.isLoading
            ? const CircularProgressIndicator()
            : userProvider.user == null
            ? ElevatedButton(
          onPressed: () {
            if (auth.accessToken != null) {
              userProvider.fetchProfile(auth.accessToken!);
            }
          },
          child: const Text("Load Profile"),
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("ID: ${userProvider.user!.id}"),
            Text("Username: ${userProvider.user!.username}"),
            Text("Email: ${userProvider.user!.email}"),
            Text("Role: ${userProvider.user!.role}"),
          ],
        ),
      ),
    );
  }
}
