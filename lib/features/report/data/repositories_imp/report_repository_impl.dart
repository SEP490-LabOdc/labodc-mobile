import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/report_repository.dart';
import '../data_sources/report_remote_data_source.dart';
import '../model/report_pagination_model.dart';


class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource remote;

  ReportRepositoryImpl({required this.remote});

  @override
  Future<Either<Failure, ReportPaginationModel>> getSentReports({
    required int page,
    required int size,
  }) async {
    try {
      final result = await remote.getSentReports(page: page, size: size);
      return Right(result);
    } on NetworkException catch (_) {
      return Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message,  e.statusCode ?? 500));
    } catch (e, st) {
      debugPrint("❌ [ReportRepository] Lỗi không xác định ở danh sách thông báo đã gửi: $e\n$st");
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReportPaginationModel>> getReceivedReports({
    required int page,
    required int size,
  }) async {
    try {
      final result = await remote.getReceivedReports(page: page, size: size);
      return Right(result);
    } on NetworkException catch (_) {
      return Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message,  e.statusCode ?? 500));
    } catch (e, st) {
      debugPrint("❌ [ReportRepository] Lỗi không xác định ở danh sách thông báo được nhận: $e\n$st");
      return Left(UnknownFailure(e.toString()));
    }
  }
}
