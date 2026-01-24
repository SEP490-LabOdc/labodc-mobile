import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../models/transaction_detail_model.dart';
import '../models/transaction_model.dart';
import '../models/withdraw_request.dart';

abstract class TransactionRepository {
  Future<Either<Failure, List<TransactionModel>>> getMyTransactions({
    required int page,
    required int size,
  });
  Future<Either<Failure, bool>> withdraw(WithdrawRequest request);
  Future<Either<Failure, TransactionDetailModel>> getTransactionDetail(String transactionId);
}