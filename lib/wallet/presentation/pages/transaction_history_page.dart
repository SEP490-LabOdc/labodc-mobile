import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/get_it/get_it.dart';
import '../../../shared/widgets/reusable_card.dart';
import '../../data/models/transaction_model.dart';
import '../bloc/transaction_history_cubit.dart';
import '../bloc/transaction_history_state.dart';

class TransactionHistoryPage extends StatelessWidget {
  const TransactionHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<TransactionHistoryCubit>()..loadTransactions(),
      child: const _TransactionHistoryView(),
    );
  }
}

class _TransactionHistoryView extends StatelessWidget {
  const _TransactionHistoryView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lịch sử giao dịch"),
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocBuilder<TransactionHistoryCubit, TransactionHistoryState>(
        builder: (context, state) {
          if (state is TransactionHistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TransactionHistoryError) {
            return _buildErrorState(state.message, context);
          }

          if (state is TransactionHistoryLoaded) {
            return RefreshIndicator(
              onRefresh: () => context.read<TransactionHistoryCubit>().loadTransactions(),
              child: state.transactions.isEmpty
                  ? _buildEmptyState(theme)
                  : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.transactions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return TransactionItemCard(transaction: state.transactions[index]);
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_wallet_outlined, size: 80, color: theme.disabledColor),
          const SizedBox(height: 16),
          Text("Chưa có giao dịch nào", style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(message, textAlign: TextAlign.center),
          ),
          ElevatedButton(
            onPressed: () => context.read<TransactionHistoryCubit>().loadTransactions(),
            child: const Text("Thử lại"),
          )
        ],
      ),
    );
  }
}

class TransactionItemCard extends StatelessWidget {
  final TransactionModel transaction;
  const TransactionItemCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isIncome = transaction.direction == 'CREDIT';
    final color = isIncome ? Colors.green : Colors.redAccent;
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return ReusableCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Icon biểu tượng
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIncome ? Icons.add_chart_rounded : Icons.account_balance_wallet,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Thông tin Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _mapTypeToTitle(transaction.type),
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('HH:mm - dd/MM/yyyy').format(transaction.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                ),
                if (transaction.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    transaction.description!,
                    style: theme.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ]
              ],
            ),
          ),
          // Số tiền và Trạng thái
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${isIncome ? '+' : '-'}${currencyFormat.format(transaction.amount)}",
                style: theme.textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              _StatusBadge(status: transaction.status),
            ],
          )
        ],
      ),
    );
  }

  String _mapTypeToTitle(String type) {
    switch (type) {
      case 'TRANSACTION_TYPE_DISBURSEMENT': return "Giải ngân";
      case 'WITHDRAWAL': return "Rút tiền";
      case 'DEPOSIT': return "Nạp tiền";
      case 'MILESTONE_PAYMENT': return "Thanh toán Milestone";
      default: return "Giao dịch khác";
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isDone = status == 'COMPLETED' || status == 'SUCCESS';
    final color = isDone ? Colors.green : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        isDone ? "Thành công" : "Chờ xử lý",
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}