import 'package:flutter/material.dart';

import 'chat_detail_page.dart';

class MentorChatPage extends StatelessWidget {
  const MentorChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tin nhắn'),
      ),
      body: ListView.separated(
        itemCount: 8,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          return _ChatListItem(
            name: 'Talent ${index + 1}',
            lastMessage: 'Tin nhắn cuối cùng từ cuộc trò chuyện...',
            time: '${index + 1}h trước',
            hasUnread: index < 3,
            unreadCount: index < 3 ? index + 1 : 0,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatDetailPage(
                    contactName: 'Talent ${index + 1}',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ChatListItem extends StatelessWidget {
  final String name;
  final String lastMessage;
  final String time;
  final bool hasUnread;
  final int unreadCount;
  final VoidCallback? onTap;

  const _ChatListItem({
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.hasUnread,
    required this.unreadCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Stack(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.grey,
            child: Icon(Icons.person),
          ),
          if (hasUnread)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        name,
        style: TextStyle(
          fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: hasUnread ? Colors.black87 : Colors.grey.shade600,
        ),
      ),
      trailing: Text(
        time,
        style: TextStyle(
          color: Colors.grey.shade500,
          fontSize: 12,
        ),
      ),
      onTap: onTap,
    );
  }
}