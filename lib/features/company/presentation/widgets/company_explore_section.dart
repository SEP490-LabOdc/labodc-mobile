import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:labodc_mobile/core/get_it/get_it.dart';
import '../cubit/company_cubit.dart';
import '../cubit/company_state.dart';
import 'company_card.dart';

class CompanyExploreSection extends StatelessWidget {
  const CompanyExploreSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CompanyCubit>()..fetchActiveCompanies(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Đối Tác Công Ty',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
          const SizedBox(height: 16),

          BlocBuilder<CompanyCubit, CompanyState>(
            builder: (context, state) {
              if (state is CompanyLoading) {
                // Hiển thị loading chỉ ở phần này
                return const Center(child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator.adaptive(),
                ));
              }
              if (state is CompanyError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Lỗi tải danh sách công ty: ${state.message}', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ),
                );
              }
              if (state is CompanyLoaded) {
                // Hiển thị tất cả công ty đã tải
                final displayCompanies = state.companies;

                if (displayCompanies.isEmpty) {
                  return _buildEmptyState(context);
                }

                // Chuyển sang ListView để hiển thị Card to hơn, dạng danh sách
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(), // Để cuộn cùng ScrollView cha
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: displayCompanies.length,
                  separatorBuilder: (ctx, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return CompanyCard(company: displayCompanies[index]);
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(height: 20.0),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.business_center_outlined, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            "Chưa có công ty đối tác nào đang hoạt động.",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}