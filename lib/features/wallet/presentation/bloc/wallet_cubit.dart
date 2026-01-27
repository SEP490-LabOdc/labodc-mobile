import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:labodc_mobile/features/wallet/presentation/bloc/wallet_state.dart';

import '../../data/models/withdraw_request.dart';
import '../../data/models/bank_info_request.dart';
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
    result.fold((failure) => emit(WalletError(failure.message)), (success) {
      loadWallet();
    });
  }

  /// Add bank info to wallet
  Future<void> addBankInfo(BankInfoRequest request) async {
    emit(WalletLoading());
    final result = await repository.addBankInfo(request);
    result.fold(
      (failure) => emit(WalletError(failure.message)),
      (success) => loadWallet(), // Reload wallet to get updated bank list
    );
  }
}
