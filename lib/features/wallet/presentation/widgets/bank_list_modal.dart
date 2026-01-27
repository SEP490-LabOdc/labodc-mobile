import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:labodc_mobile/features/wallet/presentation/widgets/bank_setup_modal.dart';

import '../../data/models/wallet_model.dart';
import '../bloc/wallet_cubit.dart';

class BankListModal extends StatelessWidget {
  final WalletModel wallet;

  const BankListModal({super.key, required this.wallet});

  void _showAddBankModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const BankSetupModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 48), // Spacer for centering
                Text(
                  "Danh sách ngân hàng",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // List
          if (wallet.bankInfos.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Chưa có ngân hàng liên kết",
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Thêm ngân hàng để rút tiền nhanh chóng",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                shrinkWrap: true,
                itemCount: wallet.bankInfos.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final bank = wallet.bankInfos[index];
                  // Construct logo URL from bank code (stored in bankName)
                  // Assuming bankName is the bank code like "MB", "VCB"
                  final logoUrl =
                      'https://img.vietqr.io/image/${bank.bankName}-logo.png';

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(11),
                            child: CachedNetworkImage(
                              imageUrl: logoUrl,
                              fit: BoxFit.contain,
                              placeholder: (context, url) => const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              errorWidget: (context, url, error) => const Icon(
                                Icons.account_balance,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bank.bankName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                bank.accountNumber, // Mask account number?
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontFamily: 'Monospace',
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                bank.accountHolderName.toUpperCase(),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (index == 0 && wallet.bankInfos.length > 1)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.green.shade100),
                            ),
                            child: Text(
                              'Mặc định',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),

          // Add Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showAddBankModal(context),
                icon: const Icon(Icons.add),
                label: const Text("Thêm ngân hàng mới"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
