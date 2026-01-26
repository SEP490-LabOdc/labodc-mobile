/// Project milestone status enum matching backend definition
enum ProjectMilestoneStatus {
  PENDING,
  PENDING_START,
  UPDATE_REQUIRED,
  ON_GOING,
  PENDING_COMPLETED,
  COMPLETED,
  PAID,
  DISTRIBUTED;

  /// Get display text in Vietnamese
  String get displayText {
    switch (this) {
      case ProjectMilestoneStatus.PENDING:
        return 'Chờ duyệt';
      case ProjectMilestoneStatus.PENDING_START:
        return 'Chờ bắt đầu';
      case ProjectMilestoneStatus.UPDATE_REQUIRED:
        return 'Cần cập nhật';
      case ProjectMilestoneStatus.ON_GOING:
        return 'Đang thực hiện';
      case ProjectMilestoneStatus.PENDING_COMPLETED:
        return 'Chờ hoàn thành';
      case ProjectMilestoneStatus.COMPLETED:
        return 'Hoàn thành';
      case ProjectMilestoneStatus.PAID:
        return 'Đã thanh toán';
      case ProjectMilestoneStatus.DISTRIBUTED:
        return 'Đã phân bổ';
    }
  }

  /// Parse from string (case-insensitive)
  static ProjectMilestoneStatus fromString(String status) {
    final upperStatus = status.toUpperCase();
    return ProjectMilestoneStatus.values.firstWhere(
      (e) => e.name == upperStatus,
      orElse: () => ProjectMilestoneStatus.PENDING,
    );
  }

  /// Check if milestone is in active state
  bool get isActive {
    return this == ProjectMilestoneStatus.ON_GOING ||
        this == ProjectMilestoneStatus.PENDING_START;
  }

  /// Check if milestone is completed or beyond
  bool get isCompletedOrBeyond {
    return this == ProjectMilestoneStatus.COMPLETED ||
        this == ProjectMilestoneStatus.PAID ||
        this == ProjectMilestoneStatus.DISTRIBUTED;
  }

  /// Check if milestone can be edited
  bool get isEditable {
    return this == ProjectMilestoneStatus.PENDING ||
        this == ProjectMilestoneStatus.UPDATE_REQUIRED ||
        this == ProjectMilestoneStatus.ON_GOING;
  }
}
