import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';

/// Service quản lý Android Home Widget
///
/// Widget hiển thị số lượng thông báo chưa đọc trên màn hình chính Android
/// Chỉ cập nhật khi user mở ứng dụng (không dùng background service)
class NotificationWidgetService {
  static const String _widgetName = 'NotificationWidgetProvider';
  static const String _unreadCountKey = 'unread_count';
  static const String _lastUpdatedKey = 'last_updated';

  /// Khởi tạo widget service
  ///
  /// Nên gọi trong main() function khi app khởi động
  static Future<void> initialize() async {
    try {
      // Set App Group ID để share data giữa app và widget
      await HomeWidget.setAppGroupId('com.labodc.mobile');
      debugPrint('✅ [Widget Service] Initialized successfully');
    } catch (e) {
      debugPrint('❌ [Widget Service] Failed to initialize: $e');
    }
  }

  /// Cập nhật số lượng thông báo chưa đọc lên widget
  ///
  /// [count] - Số lượng thông báo chưa đọc
  ///
  /// Gọi mỗi khi có thay đổi trong danh sách thông báo
  static Future<void> updateUnreadCount(int count) async {
    try {
      // Lưu data vào SharedPreferences (home_widget sẽ access được)
      await HomeWidget.saveWidgetData<int>(_unreadCountKey, count);

      // Lưu thời gian cập nhật cuối cùng
      final now = DateTime.now();
      final formattedTime = DateFormat('HH:mm').format(now);
      await HomeWidget.saveWidgetData<String>(_lastUpdatedKey, formattedTime);

      // Trigger widget reload
      await HomeWidget.updateWidget(
        name: _widgetName,
        androidName: _widgetName,
      );

      debugPrint(
        '✅ [Widget Service] Updated: $count unread notifications at $formattedTime',
      );
    } catch (e) {
      debugPrint('❌ [Widget Service] Failed to update widget: $e');
    }
  }

  /// Lấy URI khi widget được tap (deep linking)
  ///
  /// Returns URI nếu app được mở từ widget, null nếu không
  ///
  /// Gọi trong main() để kiểm tra xem app có được mở từ widget không
  static Future<Uri?> getWidgetUri() async {
    try {
      final uri = await HomeWidget.initiallyLaunchedFromHomeWidget();
      if (uri != null) {
        debugPrint('🔗 [Widget Service] Opened from widget: $uri');
      }
      return uri;
    } catch (e) {
      debugPrint('❌ [Widget Service] Failed to get widget URI: $e');
      return null;
    }
  }

  /// Reset widget về trạng thái mặc định
  ///
  /// Gọi khi user logout để clear thông tin cá nhân
  static Future<void> reset() async {
    try {
      await updateUnreadCount(0);
      debugPrint('✅ [Widget Service] Reset to default state');
    } catch (e) {
      debugPrint('❌ [Widget Service] Failed to reset: $e');
    }
  }
}
