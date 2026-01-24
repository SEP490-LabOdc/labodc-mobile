import 'package:dartz/dartz.dart';
import 'package:labodc_mobile/features/wallet/data/models/transaction_detail_model.dart';
import 'package:labodc_mobile/features/wallet/data/models/withdraw_request.dart';
import '../../../../../core/error/failures.dart';

import '../../../auth/data/token/auth_token_storage.dart';
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

  Future<Either<Failure, String>> _getAuthenticatedToken() async {
    final token = await tokenStorage.getAccessToken();
    if (token == null) {
      return const Left(UnAuthorizedFailure("Phiên làm việc hết hạn. Vui lòng đăng nhập lại."));
    }
    return Right(token);
  }

  @override
  Future<Either<Failure, List<TransactionModel>>> getMyTransactions({
    required int page,
    required int size,
  }) async {
    try {
      final tokenRes = await _getAuthenticatedToken();
      return await tokenRes.fold(
            (failure) async => Left(failure),
            (token) async {
          final transactions = await remoteDataSource.getMyTransactions(
            token,
            page: page,
            size: size,
          );
          return Right(transactions);
        },
      );
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> withdraw(WithdrawRequest request) async {
    try {
      final tokenRes = await _getAuthenticatedToken();
      return await tokenRes.fold(
            (failure) async => Left(failure),
            (token) async {
          final success = await remoteDataSource.withdraw(token, request);
          return Right(success);
        },
      );
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TransactionDetailModel>> getTransactionDetail(String transactionId) async {
    try {
      final tokenRes = await _getAuthenticatedToken();
      return await tokenRes.fold(
            (failure) async => Left(failure),
            (token) async {
          final transaction = await remoteDataSource.getTransactionDetail(token, transactionId);
          return Right(transaction);
        },
      );
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}