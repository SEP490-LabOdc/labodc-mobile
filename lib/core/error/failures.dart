// lib/core/error/failures.dart

abstract class Failure {
  final String message;
  const Failure(this.message);
}

// 1. Lỗi liên quan đến Network và Server
class ServerFailure extends Failure {
  final int statusCode;
  const ServerFailure(String message, this.statusCode) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure() : super("Không có kết nối mạng. Vui lòng kiểm tra lại đường truyền.");
}

// 2. Lỗi Nghiệp Vụ Cụ Thể (từ mã trạng thái HTTP 4xx)
class UnAuthorizedFailure extends ServerFailure {
  const UnAuthorizedFailure([String message = "Phiên đăng nhập hết hạn hoặc không hợp lệ."]) : super(message, 401);
}

class InvalidInputFailure extends ServerFailure {
  const InvalidInputFailure([String message = "Dữ liệu nhập vào không hợp lệ."]) : super(message, 400);
}

class NotFoundFailure extends ServerFailure {
  const NotFoundFailure([String message = "Không tìm thấy tài nguyên yêu cầu."]) : super(message, 404);
}

// 3. Lỗi Không Xác Định
class UnknownFailure extends Failure {
  const UnknownFailure([String message = "Đã xảy ra lỗi không xác định. Vui lòng thử lại sau."])
      : super(message);
}