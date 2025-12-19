import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:labodc_mobile/shared/widgets/network_image_with_fallback.dart';
import '../../../../core/router/route_constants.dart';
import '../../domain/entities/company_entity.dart';
import '../../../../shared/widgets/reusable_card.dart'; // Giữ lại import này

class CompanyCard extends StatelessWidget {
  final CompanyEntity company;

  const CompanyCard({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    // Lấy theme để đồng bộ màu sắc
    final theme = Theme.of(context);

    // Giả định số dự án đang chạy là một giá trị tĩnh hoặc cần API bổ sung
    // Tạm thời dùng giá trị 0
    const int activeProjectsCount = 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            context.pushNamed(Routes.companyDetailName, pathParameters: {'id': company.id});
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Xem Hồ sơ chi tiết của ${company.name}')),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === HEADER: LOGO VÀ TÊN ===
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo/Icon
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: NetworkImageWithFallback(
                        imageUrl: company.logoUrl ?? '',
                        fallbackAsset: 'assets/images/logo.png',
                        width: 24,
                        height: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Tên Công ty và Địa chỉ
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            company.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  company.address,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // === MÔ TẢ (DESCRIPTION) ===
                Text(
                  company.description?.isNotEmpty == true
                      ? company.description!
                      : "Công ty đối tác uy tín của LabOdc, chuyên về các giải pháp công nghệ.",
                  style: TextStyle(color: Colors.grey.shade700, height: 1.5, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(height: 1, thickness: 0.5),
                ),

                // === FOOTER (METRICS) ===
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildFooterItem(
                      icon: Icons.work_outline,
                      text: "$activeProjectsCount Dự án đang tuyển",
                      color: Colors.green.shade700,
                      bgColor: Colors.green.shade50,
                    ),
                    _buildFooterItem(
                      icon: Icons.verified_user_outlined,
                      text: company.status == 'ACTIVE' ? "Đã Xác minh" : "Chưa xác minh",
                      color: company.status == 'ACTIVE' ? Colors.blue.shade700 : Colors.orange.shade700,
                      bgColor: company.status == 'ACTIVE' ? Colors.blue.shade50 : Colors.orange.shade50,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget phụ trợ cho Footer Item (Giống Project Card)
  Widget _buildFooterItem({
    required IconData icon,
    required String text,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}