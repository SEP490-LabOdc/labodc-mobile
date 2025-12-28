import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/wallet_model.dart';
import '../models/withdraw_request.dart';

abstract class WalletRepository {
  Future<Either<Failure, WalletModel>> getMyWallet();
  Future<Either<Failure, bool>> withdraw(WithdrawRequest request);
}