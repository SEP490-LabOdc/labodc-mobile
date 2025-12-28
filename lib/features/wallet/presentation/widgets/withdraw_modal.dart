import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/withdraw_request.dart';
import '../bloc/wallet_cubit.dart';

class WithdrawModal extends StatefulWidget {
  const WithdrawModal({super.key});

  @override
  State<WithdrawModal> createState() => _WithdrawModalState();
}

class _WithdrawModalState extends State<WithdrawModal> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _accountNameController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _accountNameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final request = WithdrawRequest(
        amount: double.parse(_amountController.text),
        bankName: _bankNameController.text,
        accountNumber: _accountNumberController.text,
        accountName: _accountNameController.text,
      );

      // Gọi Cubit để xử lý logic rút tiền
      context.read<WalletCubit>().withdrawMoney(request);

      // Đóng modal sau khi submit
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sử dụng Padding với MediaQuery để Modal không bị bàn phím che khuất
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Yêu cầu rút tiền",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Trường nhập số tiền
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Số tiền rút (VNĐ)', prefixIcon: Icon(Icons.money)),
                keyboardType: TextInputType.number,
                validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập số tiền' : null,
              ),
              const SizedBox(height: 12),

              // Trường nhập tên ngân hàng
              TextFormField(
                controller: _bankNameController,
                decoration: const InputDecoration(labelText: 'Tên ngân hàng (ví dụ: VCB)', prefixIcon: Icon(Icons.account_balance)),
                validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập tên ngân hàng' : null,
              ),
              const SizedBox(height: 12),

              // Trường nhập số tài khoản
              TextFormField(
                controller: _accountNumberController,
                decoration: const InputDecoration(labelText: 'Số tài khoản', prefixIcon: Icon(Icons.numbers)),
                keyboardType: TextInputType.number,
                validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập số tài khoản' : null,
              ),
              const SizedBox(height: 12),

              // Trường nhập tên chủ tài khoản
              TextFormField(
                controller: _accountNameController,
                decoration: const InputDecoration(labelText: 'Tên chủ tài khoản', prefixIcon: Icon(Icons.person)),
                textCapitalization: TextCapitalization.characters,
                validator: (value) => (value == null || value.isEmpty) ? 'Vui lòng nhập tên chủ tài khoản' : null,
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text("Xác nhận rút tiền"),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}