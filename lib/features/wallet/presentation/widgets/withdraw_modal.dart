import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/bank_info_entity.dart';
import '../../data/models/withdraw_request.dart';
import '../bloc/wallet_cubit.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (newText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final value = int.parse(newText);
    final formatter = NumberFormat('#,###', 'vi_VN');
    String newString = formatter.format(value);

    return newValue.copyWith(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }
}

class WithdrawModal extends StatefulWidget {
  final List<BankInfoEntity> bankInfos;
  final double availableBalance;

  const WithdrawModal({
    super.key,
    required this.bankInfos,
    required this.availableBalance,
  });

  @override
  State<WithdrawModal> createState() => _WithdrawModalState();
}

class _WithdrawModalState extends State<WithdrawModal> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  final _balanceFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'VND');

  final _numberFormat = NumberFormat('#,###', 'vi_VN');

  late BankInfoEntity _selectedBank;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.bankInfos.isNotEmpty) {
      _selectedBank = widget.bankInfos.first;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _setAmount(double value) {
    if (value > widget.availableBalance) {
      value = widget.availableBalance;
    }
    _amountController.text = _numberFormat.format(value.toInt());

    _amountController.selection = TextSelection.fromPosition(
      TextPosition(offset: _amountController.text.length),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);


    final cleanAmount = _amountController.text.replaceAll('.', '');
    final amount = double.tryParse(cleanAmount) ?? 0;

    final request = WithdrawRequest(
      amount: amount,
      bankName: _selectedBank.bankName,
      accountNumber: _selectedBank.accountNumber,
      accountName: _selectedBank.accountHolderName,
    );

    context.read<WalletCubit>().withdrawMoney(request);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewInsets = MediaQuery.of(context).viewInsets;

    if (widget.bankInfos.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        height: 250,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.credit_card_off_outlined, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            const Text(
              "Chưa có tài khoản ngân hàng",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text("Vui lòng liên kết ngân hàng trước khi rút tiền."),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Rút tiền về",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.account_balance_wallet, size: 16, color: theme.colorScheme.primary),
                          const SizedBox(width: 6),
                          Text(
                            _balanceFormat.format(widget.availableBalance),
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // --- Bank Selection (Giữ nguyên) ---
                Text("Tài khoản nhận", style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedBank.accountNumber,
                        isExpanded: true,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        items: widget.bankInfos.map((bank) {
                          return DropdownMenuItem<String>(
                            value: bank.accountNumber,
                            child: Text(
                              bank.bankName,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedBank = widget.bankInfos.firstWhere(
                                    (e) => e.accountNumber == value,
                              );
                            });
                          }
                        },
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Số tài khoản", style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                                Text(
                                  _maskAccountNumber(_selectedBank.accountNumber),
                                  style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("Chủ tài khoản", style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                                Text(
                                  _selectedBank.accountHolderName.toUpperCase(),
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // --- 4. Input Số Tiền (Đã cập nhật Formatter) ---
                Text("Số tiền muốn rút", style: theme.textTheme.labelLarge),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                  // Thay đổi Formatter tại đây
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // Chỉ cho nhập số
                    CurrencyInputFormatter(), // Tự động thêm dấu chấm
                  ],
                  decoration: InputDecoration(
                    hintText: '0',
                    suffixText: 'VND',
                    suffixStyle: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.credit_card, color: theme.colorScheme.primary),
                        ],
                      ),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Vui lòng nhập số tiền';
                    // Xóa dấu chấm trước khi validate
                    final cleanValue = value.replaceAll('.', '');
                    final amount = double.tryParse(cleanValue) ?? 0;

                    if (amount < 10000) return 'Tối thiểu 10.000VND';
                    if (amount > widget.availableBalance) return 'Vượt quá số dư ví';
                    return null;
                  },
                ),

                const SizedBox(height: 12),


                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                        : const Text(
                      'Xác nhận rút tiền',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }






  String _maskAccountNumber(String accountNumber) {
    if (accountNumber.length <= 4) return accountNumber;
    final lastFour = accountNumber.substring(accountNumber.length - 4);
    return '**** $lastFour';
  }
}