import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/payos_banks.dart';
import '../../data/models/bank_info_request.dart';
import '../bloc/wallet_cubit.dart';

class BankSetupModal extends StatefulWidget {
  const BankSetupModal({super.key});

  @override
  State<BankSetupModal> createState() => _BankSetupModalState();
}

class _BankSetupModalState extends State<BankSetupModal> {
  final _formKey = GlobalKey<FormState>();
  final _accountNumberController = TextEditingController();
  final _accountHolderNameController = TextEditingController();

  PayOSBank? _selectedBank;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _accountNumberController.dispose();
    _accountHolderNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedBank == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng chọn ngân hàng')));
      return;
    }

    setState(() => _isSubmitting = true);

    final request = BankInfoRequest(
      bankName: _selectedBank!.code,
      accountNumber: _accountNumberController.text.trim(),
      accountHolderName: _accountHolderNameController.text.trim().toUpperCase(),
    );

    context.read<WalletCubit>().addBankInfo(request);

    // Close modal after submission
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.account_balance,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Thiết lập tài khoản rút",
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Hỗ trợ PayOS",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withOpacity(
                            0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Bank selection dropdown
            Text(
              "Ngân hàng *",
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<PayOSBank>(
              value: _selectedBank,
              isExpanded: true, // ✅ quan trọng
              decoration: InputDecoration(
                hintText: 'Chọn ngân hàng',
                prefixIcon: Icon(
                  Icons.account_balance_outlined,
                  color: theme.colorScheme.primary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: theme.brightness == Brightness.dark
                    ? theme.colorScheme.surface
                    : Colors.grey.shade50,
              ),
              items: PayOSBanks.supported.map((bank) {
                return DropdownMenuItem<PayOSBank>(
                  value: bank,
                  child: Row(
                    children: [
                      Text(bank.logo, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Flexible( // ✅ thay Expanded bằng Flexible
                        fit: FlexFit.loose,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              bank.code,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              bank.fullName,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (bank) => setState(() => _selectedBank = bank),
              validator: (value) => value == null ? 'Vui lòng chọn ngân hàng' : null,
            ),

            const SizedBox(height: 20),

            // Account number
            Text(
              "Số tài khoản *",
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _accountNumberController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(20),
              ],
              decoration: InputDecoration(
                hintText: '1234567890',
                prefixIcon: Icon(
                  Icons.credit_card,
                  color: theme.colorScheme.primary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: theme.brightness == Brightness.dark
                    ? theme.colorScheme.surface
                    : Colors.grey.shade50,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập số tài khoản';
                }
                if (value.length < 6) {
                  return 'Số tài khoản quá ngắn';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Account holder name
            Text(
              "Tên chủ tài khoản *",
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _accountHolderNameController,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                LengthLimitingTextInputFormatter(50),
              ],
              decoration: InputDecoration(
                hintText: 'NGUYEN VAN A',
                prefixIcon: Icon(
                  Icons.person_outline,
                  color: theme.colorScheme.primary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: theme.brightness == Brightness.dark
                    ? theme.colorScheme.surface
                    : Colors.grey.shade50,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập tên chủ tài khoản';
                }
                if (value.trim().length < 3) {
                  return 'Tên quá ngắn';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Info note
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Thông tin này sẽ được lưu an toàn cho các lần rút tiền sau',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Submit button
            FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Xác nhận',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
