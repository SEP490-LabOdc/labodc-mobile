import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/transaction_repository.dart';
import 'transaction_history_state.dart';

class TransactionHistoryCubit extends Cubit<TransactionHistoryState> {
  final TransactionRepository repository;
  TransactionHistoryCubit(this.repository) : super(TransactionHistoryInitial());

  Future<void> loadTransactions() async {
    emit(TransactionHistoryLoading());
    final result = await repository.getMyTransactions(page: 0, size: 20);
    result.fold(
          (failure) => emit(TransactionHistoryError(failure.message)),
          (transactions) => emit(TransactionHistoryLoaded(transactions)),
    );
  }
}