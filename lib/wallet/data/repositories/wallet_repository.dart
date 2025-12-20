import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/wallet_model.dart';

abstract class WalletRepository {
  Future<Either<Failure, WalletModel>> getMyWallet();
}