import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/get_it/get_it.dart';
import '../../../../shared/widgets/network_image_with_fallback.dart';
import '../../data/models/company_model.dart';
import '../cubit/company_detail_cubit.dart';
import '../cubit/company_detail_state.dart';

class CompanyDetailPage extends StatelessWidget {
  final String companyId;

  const CompanyDetailPage({required this.companyId, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CompanyDetailCubit>(
      create: (context) => getIt<CompanyDetailCubit>()..fetchCompanyDetail(companyId),
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: const Text("Hồ sơ Doanh nghiệp", style: TextStyle(fontWeight: FontWeight.w600)),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0.5,
        ),
        body: BlocBuilder<CompanyDetailCubit, CompanyDetailState>(
          builder: (context, state) {
            if (state is CompanyDetailLoading) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }

            if (state is CompanyDetailError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                      const SizedBox(height: 16),
                      Text("Đã xảy ra lỗi tải trang", style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      // Hiển thị chi tiết lỗi để debug (có thể bỏ trong production)
                      Text(state.message, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    ],
                  ),
                ),
              );
            }

            if (state is CompanyDetailLoaded) {
              final company = state.company;
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCompanyHeader(context, company),
                    const SizedBox(height: 20),
                    _buildSectionContainer(
                      context,
                      title: "Giới thiệu chung",
                      icon: Icons.business,
                      children: [
                        Text(
                          (company.description != null && company.description!.isNotEmpty)
                              ? company.description!
                              : "Chưa có mô tả chi tiết về doanh nghiệp này.",
                          style: TextStyle(color: Colors.grey.shade700, height: 1.5, fontSize: 15),
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildLegalInfo(context, company),
                    const SizedBox(height: 16),
                    _buildContactInfo(context, company),
                    const SizedBox(height: 30),
                  ],
                ),
              );
            }
            return const Center(child: Text("Không tìm thấy dữ liệu."));
          },
        ),
      ),
    );
  }

  // --- WIDGET LOGIC ---

  Widget _buildCompanyHeader(BuildContext context, CompanyModel company) {
    final bool isActive = company.status == 'ACTIVE';

    // === LOGIC TƯƠNG LAI ===
    // 1. Hiện tại company.logoUrl là null -> safeLogoUrl = '' -> Hiện ảnh fallback (logo.png)
    // 2. Sau này BE trả về link ảnh -> safeLogoUrl = link -> Hiện ảnh mạng
    // 3. Nếu BE trả về link PDF -> safeLogoUrl = '' -> Hiện ảnh fallback (tránh lỗi)
    String safeLogoUrl = '';
    if (company.logoUrl != null && company.logoUrl!.isNotEmpty) {
      if (!company.logoUrl!.toLowerCase().endsWith('.pdf')) {
        safeLogoUrl = company.logoUrl!;
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: NetworkImageWithFallback(
                    imageUrl: safeLogoUrl,
                    fallbackAsset: 'assets/images/logo.png', // Đảm bảo bạn có file này
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.green.shade50 : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isActive ? Colors.green.shade200 : Colors.orange.shade200,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isActive ? Icons.check_circle : Icons.pending,
                            size: 14,
                            color: isActive ? Colors.green.shade700 : Colors.orange.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isActive ? "Đang hoạt động" : "Chờ xác minh",
                            style: TextStyle(
                              color: isActive ? Colors.green.shade700 : Colors.orange.shade700,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (company.website != null && company.website!.isNotEmpty) ...[
            const Divider(height: 24),
            InkWell(
              onTap: () {
                // Logic mở web
              },
              child: Row(
                children: [
                  Icon(Icons.language, size: 18, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      company.website!,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.arrow_outward, size: 16, color: Colors.grey.shade400),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildSectionContainer(BuildContext context, {required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
              ),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildLegalInfo(BuildContext context, CompanyModel company) {
    return _buildSectionContainer(
      context,
      title: "Thông tin Pháp lý",
      icon: Icons.gavel,
      children: [
        _buildInfoRow(context, "Mã số thuế:", company.taxCode ?? "Đang cập nhật", isCopyable: true),
        if (company.address.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: _buildInfoRow(context, "Địa chỉ trụ sở:", company.address),
          ),
      ],
    );
  }

  Widget _buildContactInfo(BuildContext context, CompanyModel company) {
    return _buildSectionContainer(
      context,
      title: "Người liên hệ",
      icon: Icons.contact_phone_outlined,
      children: [
        if (company.contactPersonName != null && company.contactPersonName!.isNotEmpty)
          _buildContactRow(Icons.person, "Người đại diện", company.contactPersonName!),
        if (company.email.isNotEmpty)
          _buildContactRow(Icons.email_outlined, "Email công ty", company.email),
        if (company.contactPersonEmail != null && company.contactPersonEmail != company.email)
          _buildContactRow(Icons.alternate_email, "Email cá nhân", company.contactPersonEmail!),
        if (company.contactPersonPhone != null && company.contactPersonPhone!.isNotEmpty)
          _buildContactRow(Icons.phone_outlined, "Điện thoại", company.contactPersonPhone!),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, {bool isCopyable = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 110, child: Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 14))),
        Expanded(
          child: Row(
            children: [
              Expanded(child: Text(value, style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w500))),
              if (isCopyable) Icon(Icons.copy, size: 14, color: Colors.grey.shade400)
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade500),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}