import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/provider/auth_provider.dart';
import '../../websocket/cubit/websocket_notification_cubit.dart';


class WebSocketManager extends StatefulWidget {
  final Widget child;
  const WebSocketManager({super.key, required this.child});

  @override
  State<WebSocketManager> createState() => _WebSocketManagerState();
}

class _WebSocketManagerState extends State<WebSocketManager> {
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();
    // Thử kết nối ngay lần đầu tiên mount
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkConnection());
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    super.dispose();
  }

  void _checkConnection() {
    final auth = context.read<AuthProvider>();
    final cubit = context.read<WebSocketNotificationCubit>();

    final user = auth.currentUser;
    final token = auth.accessToken;

    if (user != null && token != null && token.isNotEmpty) {
      // Gọi connect (Cubit đã có logic check trùng lặp nên gọi nhiều lần không sao)
      cubit.connect(user.userId, token);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        // Mỗi khi Auth thay đổi (Login/Logout/Refresh Token), check lại kết nối
        // Dùng addPostFrameCallback để tránh lỗi setState during build
        if (auth.isAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _checkConnection());
        }
        return widget.child;
      },
    );
  }
}