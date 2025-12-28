import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:labodc_mobile/features/wallet/presentation/bloc/wallet_state.dart';

import '../../data/models/withdraw_request.dart';
import '../../data/repositories/wallet_repository.dart';

class WalletCubit extends Cubit<WalletState> {
  final WalletRepository repository;
  WalletCubit(this.repository) : super(WalletInitial());

  Future<void> loadWallet() async {
    emit(WalletLoading());
    final result = await repository.getMyWallet();
    result.fold(
          (failure) => emit(WalletError(failure.message)),
          (wallet) => emit(WalletLoaded(wallet)),
    );
  }


  Future<void> withdrawMoney(WithdrawRequest request) async {
    emit(WalletLoading());
    final result = await repository.withdraw(request);
    result.fold(
          (failure) => emit(WalletError(failure.message)),
          (success) {
        // Sau khi rút thành công, nên load lại ví để cập nhật số dư mới
        loadWallet();
      },
    );
  }
}