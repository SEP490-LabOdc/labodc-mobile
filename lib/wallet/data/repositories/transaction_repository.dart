import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/transaction_model.dart';

abstract class TransactionRepository {
  Future<Either<Failure, List<TransactionModel>>> getMyTransactions({
    required int page,
    required int size,
  });
}