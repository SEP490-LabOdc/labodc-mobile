import 'package:equatable/equatable.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/transaction_detail_model.dart';

abstract class TransactionHistoryState extends Equatable {
  const TransactionHistoryState();
  @override
  List<Object?> get props => [];
}

class TransactionHistoryInitial extends TransactionHistoryState {}
class TransactionHistoryLoading extends TransactionHistoryState {}

class TransactionHistoryLoaded extends TransactionHistoryState {
  final List<TransactionModel> transactions;
  const TransactionHistoryLoaded(this.transactions);
  @override
  List<Object?> get props => [transactions];
}

// State mới cho chi tiết giao dịch
class TransactionDetailLoaded extends TransactionHistoryState {
  final TransactionDetailModel detail;
  const TransactionDetailLoaded(this.detail);
  @override
  List<Object?> get props => [detail];
}

class TransactionHistoryError extends TransactionHistoryState {
  final String message;
  const TransactionHistoryError(this.message);
  @override
  List<Object?> get props => [message];
}