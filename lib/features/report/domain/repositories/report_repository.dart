import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../data/model/report_pagination_model.dart';

abstract class ReportRepository {
  Future<Either<Failure, ReportPaginationModel>> getSentReports({
    required int page,
    required int size,
  });

  Future<Either<Failure, ReportPaginationModel>> getReceivedReports({
    required int page,
    required int size,
  });

  Future<Either<Failure, ReportPaginationModel>> getMilestoneReports(
    String milestoneId, {
    required int page,
    required int size,
  });
}
