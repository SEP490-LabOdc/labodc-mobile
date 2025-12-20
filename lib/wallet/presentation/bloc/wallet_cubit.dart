import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:labodc_mobile/wallet/presentation/bloc/wallet_state.dart';

import '../../data/repositories/wallet_repository.dart';

class WalletCubit extends Cubit<WalletState> {
  final WalletRepository repository; // Hoặc WalletRepository
  WalletCubit(this.repository) : super(WalletInitial());

  Future<void> loadWallet() async {
    emit(WalletLoading());
    final result = await repository.getMyWallet(); // Triển khai tương tự Transaction Repo
    result.fold(
          (failure) => emit(WalletError(failure.message)),
          (wallet) => emit(WalletLoaded(wallet)),
    );
  }
}