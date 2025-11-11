import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    _closeDropdown();
    super.dispose();
  }

  void _toggleDropdown(BuildContext context) {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _overlayEntry = _createOverlayEntry(context);
      Overlay.of(context).insert(_overlayEntry!);
      setState(() => _isOpen = true);
    }
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => _isOpen = false);
  }

  OverlayEntry _createOverlayEntry(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // ✅ Dropdown width
    const dropdownWidth = 360.0;
    const dropdownMaxHeight = 500.0;

    // ✅ Calculate position - align to right edge of bell icon
    // Make sure dropdown doesn't go off-screen
    final left = (offset.dx + size.width - dropdownWidth).clamp(8.0, screenWidth - dropdownWidth - 8);
    final top = offset.dy + size.height + 8;

    // ✅ Check if dropdown would go off bottom of screen
    final availableHeight = screenHeight - top - 16;
    final dropdownHeight = availableHeight.clamp(200.0, dropdownMaxHeight);

    return OverlayEntry(
      builder: (overlayCtx) => Stack(
        children: [
          // ✅ Backdrop to close dropdown when tapping outside
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _closeDropdown,
              child: Container(color: Colors.transparent),
            ),
          ),

          // ✅ Dropdown card
          Positioned(
            left: left,
            top: top,
            width: dropdownWidth,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).cardColor,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: dropdownHeight,
                ),
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
                        // ✅ Header with tabs
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildTab("Tất cả", 0),
                              _buildTab("Chưa đọc (${unread.length})", 1),
                            ],
                          ),
                        ),

                        const Divider(height: 1),

                        // ✅ Notification list
                        if (displayedList.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Column(
                              children: [
                                Icon(Icons.notifications_off_outlined,
                                    size: 48, color: Colors.grey),
                                SizedBox(height: 12),
                                Text(
                                  "Không có thông báo nào",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Flexible(
                            child: ListView.separated(
                              shrinkWrap: true,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: displayedList.length,
                              separatorBuilder: (_, __) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final n = displayedList[index];
                                return InkWell(
                                  onTap: () {
                                    final cubit = context.read<WebSocketNotificationCubit>();
                                    cubit.markAsRead(n.notificationRecipientId);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    color: n.readStatus
                                        ? Colors.transparent
                                        : Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.05),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // ✅ Unread indicator
                                        Container(
                                          width: 8,
                                          height: 8,
                                          margin: const EdgeInsets.only(top: 4, right: 12),
                                          decoration: BoxDecoration(
                                            color: n.readStatus
                                                ? Colors.transparent
                                                : Theme.of(context).primaryColor,
                                            shape: BoxShape.circle,
                                          ),
                                        ),

                                        // ✅ Notification content
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                n.title,
                                                style: TextStyle(
                                                  fontWeight: n.readStatus
                                                      ? FontWeight.normal
                                                      : FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                n.content,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.color,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
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
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? Theme.of(context).primaryColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 13,
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
      child: BlocBuilder<WebSocketNotificationCubit, List<NotificationEntity>>(
        builder: (context, notifications) {
          final unreadCount = notifications.where((n) => !n.readStatus).length;

          return InkWell(
            onTap: () => _toggleDropdown(context),
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

                  // ✅ Badge with unread count
                  if (unreadCount > 0)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Theme.of(context).scaffoldBackgroundColor,
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