import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/get_it/get_it.dart';
import '../../../../core/services/cubit/bank_cubit.dart';
import '../../../../core/models/vietqr_bank_model.dart';
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
  final _searchController = TextEditingController();

  VietQRBank? _selectedBank;
  bool _isSubmitting = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _accountNumberController.dispose();
    _accountHolderNameController.dispose();
    _searchController.dispose();
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

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (_) => getIt<BankCubit>()..loadBanks(),
      child: Form(
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
              _buildHeader(theme),
              const SizedBox(height: 24),
              _buildBankDropdown(theme),
              const SizedBox(height: 20),
              _buildAccountNumberField(theme),
              const SizedBox(height: 20),
              _buildAccountHolderNameField(theme),
              const SizedBox(height: 24),
              _buildInfoNote(theme),
              const SizedBox(height: 24),
              _buildSubmitButton(theme),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
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
                "Hỗ trợ chuyển khoản qua VietQR",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBankDropdown(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Ngân hàng *",
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        BlocBuilder<BankCubit, BankState>(
          builder: (context, state) {
            if (state is BankLoading) {
              return Container(
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(child: CircularProgressIndicator()),
              );
            }

            if (state is BankError) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.message,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () => context.read<BankCubit>().loadBanks(
                        forceRefresh: true,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is BankLoaded) {
              final banks = state.transferSupportedBanks
                  .where(
                    (bank) =>
                        bank.shortName.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ) ||
                        bank.code.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ) ||
                        bank.name.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ),
                  )
                  .toList();

              return Column(
                children: [
                  // Dropdown
                  DropdownButtonFormField<VietQRBank>(
                    value: _selectedBank,
                    isExpanded: true,
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
                    items: banks.map((bank) {
                      return DropdownMenuItem<VietQRBank>(
                        value: bank,
                        child: Row(
                          children: [
                            // Bank logo
                            CachedNetworkImage(
                              imageUrl: bank.logo,
                              width: 32,
                              height: 32,
                              placeholder: (_, __) => const SizedBox(
                                width: 32,
                                height: 32,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Icon(
                                  Icons.account_balance,
                                  size: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '${bank.code} - ${bank.shortName}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (bank) => setState(() => _selectedBank = bank),
                    validator: (value) =>
                        value == null ? 'Vui lòng chọn ngân hàng' : null,
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildAccountNumberField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            hintText: 'Số tài khoản',
            prefixIcon: Icon(
              Icons.credit_card,
              color: theme.colorScheme.primary,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
      ],
    );
  }

  Widget _buildAccountHolderNameField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            hintText: 'Tên chủ tài khoản (NGUYEN VAN A)',
            prefixIcon: Icon(
              Icons.person_outline,
              color: theme.colorScheme.primary,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
      ],
    );
  }

  Widget _buildInfoNote(ThemeData theme) {
    return Container(
    );
  }

  Widget _buildSubmitButton(ThemeData theme) {
    return FilledButton(
      onPressed: _isSubmitting ? null : _submit,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: _isSubmitting
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text(
              'Xác nhận',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    );
  }
}
