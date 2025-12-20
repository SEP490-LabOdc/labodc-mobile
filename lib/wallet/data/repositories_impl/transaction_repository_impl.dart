import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

import '../../../features/auth/data/token/auth_token_storage.dart';
import '../data_sources/transaction_remote_data_source.dart';
import '../models/transaction_model.dart';
import '../repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource remoteDataSource;
  final AuthTokenStorage tokenStorage;

  TransactionRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenStorage,
  });

  @override
  Future<Either<Failure, List<TransactionModel>>> getMyTransactions({
    required int page,
    required int size,
  }) async {
    try {
      // 1. Lấy token từ bộ nhớ local
      final token = await tokenStorage.getAccessToken();
      if (token == null) {
        return const Left(UnAuthorizedFailure("Phiên làm việc hết hạn. Vui lòng đăng nhập lại."));
      }

      // 2. Gọi API từ Remote Data Source
      final transactions = await remoteDataSource.getMyTransactions(
        token,
        page: page,
        size: size,
      );

      return Right(transactions);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}