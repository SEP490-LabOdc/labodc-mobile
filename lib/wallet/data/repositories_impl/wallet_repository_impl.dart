import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../features/auth/data/token/auth_token_storage.dart';
import '../data_sources/transaction_remote_data_source.dart';
import '../models/wallet_model.dart';
import '../repositories/wallet_repository.dart';

class WalletRepositoryImpl implements WalletRepository {
  final TransactionRemoteDataSource remoteDataSource;
  final AuthTokenStorage tokenStorage;

  WalletRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenStorage,
  });

  @override
  Future<Either<Failure, WalletModel>> getMyWallet() async {
    try {
      // 1. Lấy Access Token từ storage
      final token = await tokenStorage.getAccessToken();

      if (token == null) {
        return const Left(UnAuthorizedFailure("Phiên làm việc đã hết hạn."));
      }

      // 2. Gọi Remote Data Source để lấy dữ liệu ví
      final wallet = await remoteDataSource.getMyWallet(token);

      return Right(wallet);
    } on Failure catch (e) {
      // Trả về lỗi đã được xử lý tại Data Source
      return Left(e);
    } catch (e) {
      // Trả về lỗi không xác định
      return Left(UnknownFailure(e.toString()));
    }
  }
}