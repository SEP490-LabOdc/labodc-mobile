import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/router/route_constants.dart';
import '../../domain/entities/notification_entity.dart';
import '../../websocket/cubit/websocket_notification_cubit.dart';

class NotificationBell extends StatefulWidget {
  final double iconSize;
  const NotificationBell({super.key, this.iconSize = 26});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  bool _isOpen = false;
  int _tabIndex = 0;

  @override
  void dispose() {
    // Không gọi setState trong dispose
    _removeOverlaySafely();
    super.dispose();
  }

  void _removeOverlaySafely() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  void _toggleDropdown(BuildContext context) {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown(context);
    }
  }

  void _openDropdown(BuildContext context) {
    if (_overlayEntry != null) return;

    final entry = _createOverlayEntry(context);
    Overlay.of(context).insert(entry);
    _overlayEntry = entry;

    if (mounted) {
      setState(() => _isOpen = true);
    }
  }

  void _closeDropdown() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }

    if (mounted) {
      setState(() => _isOpen = false);
    }
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return "Vừa xong";
    if (diff.inMinutes < 60) return "${diff.inMinutes} phút trước";
    if (diff.inHours < 24) return "${diff.inHours} giờ trước";
    if (diff.inDays == 1) return "Hôm qua";
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  OverlayEntry _createOverlayEntry(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    const dropdownWidth = 380.0;
    const dropdownMaxHeight = 520.0;

    final left = (offset.dx + size.width - dropdownWidth)
        .clamp(8.0, screenWidth - dropdownWidth - 8);
    final top = offset.dy + size.height + 8;

    final availableHeight = screenHeight - top - 16;
    final dropdownHeight = availableHeight.clamp(200.0, dropdownMaxHeight);

    return OverlayEntry(
      builder: (overlayCtx) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _closeDropdown,
            ),
          ),
          Positioned(
            left: left,
            top: top,
            width: dropdownWidth,
            child: Material(
              elevation: 10,
              borderRadius: BorderRadius.circular(14),
              color: Theme.of(context).cardColor,
              child: Container(
                constraints: BoxConstraints(maxHeight: dropdownHeight),
                child: BlocBuilder<WebSocketNotificationCubit,
                    List<NotificationEntity>>(
                  builder: (context, notifications) {
                    final unread =
                    notifications.where((n) => !n.readStatus).toList();
                    final displayedList =
                    _tabIndex == 0 ? notifications : unread;

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildTab("Tất cả", 0),
                              _buildTab("Chưa đọc (${unread.length})", 1),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        if (displayedList.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Column(
                              children: [
                                Icon(Icons.notifications_off_outlined,
                                    size: 48, color: Colors.grey),
                                SizedBox(height: 12),
                                Text("Không có thông báo nào",
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 14)),
                              ],
                            ),
                          )
                        else
                          Flexible(
                            child: ListView.separated(
                              shrinkWrap: true,
                              padding:
                              const EdgeInsets.symmetric(vertical: 8),
                              itemCount: displayedList.length,
                              separatorBuilder: (_, __) =>
                              const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final n = displayedList[index];
                                return InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () {
                                    context
                                        .read<WebSocketNotificationCubit>()
                                        .markAsRead(
                                        n.notificationRecipientId);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 14),
                                    color: n.readStatus
                                        ? Colors.transparent
                                        : Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.06),
                                    child: Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          margin: const EdgeInsets.only(
                                              top: 6, right: 12),
                                          decoration: BoxDecoration(
                                            color: n.readStatus
                                                ? Colors.transparent
                                                : Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                n.title,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 15,
                                                  color: n.readStatus
                                                      ? Theme.of(context)
                                                      .textTheme
                                                      .bodyLarge
                                                      ?.color
                                                      : Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                ),
                                                maxLines: 2,
                                                overflow:
                                                TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                n.content,
                                                style: TextStyle(
                                                  fontSize: 13.5,
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.color
                                                      ?.withOpacity(0.85),
                                                ),
                                                maxLines: 3,
                                                overflow:
                                                TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                _formatTime(n.sentAt),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isActive = _tabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _tabIndex = index);
          _overlayEntry?.markNeedsBuild();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.grey[700],
              fontWeight: FontWeight.w600,
              fontSize: 13.5,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: BlocBuilder<WebSocketNotificationCubit,
          List<NotificationEntity>>(
        builder: (context, notifications) {
          final unreadCount =
              notifications.where((n) => !n.readStatus).length;

          return InkWell(
            // onTap: () => _toggleDropdown(context),
            onTap: () {
              context.push(Routes.notifications);
            },
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    _isOpen
                        ? Icons.notifications_active_rounded
                        : Icons.notifications_none_rounded,
                    size: widget.iconSize,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Theme.of(context)
                                .scaffoldBackgroundColor,
                            width: 2,
                          ),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Center(
                          child: Text(
                            unreadCount > 99 ? "99+" : "$unreadCount",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
