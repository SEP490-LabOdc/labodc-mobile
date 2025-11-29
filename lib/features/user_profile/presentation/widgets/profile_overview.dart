// lib/features/user_profile/presentation/widgets/profile_overview.dart
import 'package:flutter/material.dart';

import '../../../../shared/widgets/expandable_text.dart';
import '../../../../shared/widgets/network_image_with_fallback.dart';
import '../../../../shared/widgets/reusable_card.dart';
import '../../../../shared/widgets/service_chip.dart';

class ProfileOverview extends StatelessWidget {
  final String fullName;
  final String avatarUrl;
  final String roleLabel;

  final String email;
  final String phone;
  final String birthDateText;
  final String genderText;
  final String address;

  // final String? bio;
  // final List<ServiceChip> skillChips;

  final List<Widget> actions;

  final List<Widget> extraSections;

  const ProfileOverview({
    super.key,
    required this.fullName,
    required this.avatarUrl,
    required this.roleLabel,
    required this.email,
    required this.phone,
    required this.birthDateText,
    required this.genderText,
    required this.address,
    // this.bio,
    // this.skillChips = const [],
    this.actions = const [],
    this.extraSections = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Dùng màu card từ theme cho cả light & dark
    final cardColor = theme.cardTheme.color ?? colorScheme.surface;

    final isDark = theme.brightness == Brightness.dark;
    final roleBgColor = isDark
        ? colorScheme.secondary.withOpacity(0.25)
        : colorScheme.primary.withOpacity(0.12);
    final roleBorderColor = isDark
        ? colorScheme.secondary
        : colorScheme.primary.withOpacity(0.5);
    final roleTextColor = isDark
        ? colorScheme.secondary
        : colorScheme.primary;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ========== HEADER ==========
                  ReusableCard(
                    backgroundColor: cardColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            NetworkImageWithFallback(
                              imageUrl: avatarUrl.startsWith('http')
                                  ? avatarUrl
                                  : '',
                              width: 96,
                              height: 96,
                              borderRadius: BorderRadius.circular(48),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fullName.isNotEmpty
                                        ? fullName
                                        : 'Chưa cập nhật tên',
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: roleBgColor,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: roleBorderColor,
                                      ),
                                    ),
                                    child: Text(
                                      roleLabel.toUpperCase(),
                                      style: theme.textTheme.labelMedium?.copyWith(
                                        color: roleTextColor,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ========== THÔNG TIN CƠ BẢN ==========
                  ReusableCard(
                    backgroundColor: cardColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Thông tin cá nhân",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          context: context,
                          icon: Icons.email_outlined,
                          label: "Email",
                          value: email,
                        ),
                        _buildInfoRow(
                          context: context,
                          icon: Icons.phone_outlined,
                          label: "Điện thoại",
                          value: phone,
                        ),
                        _buildInfoRow(
                          context: context,
                          icon: Icons.cake_outlined,
                          label: "Ngày sinh",
                          value: birthDateText,
                        ),
                        _buildInfoRow(
                          context: context,
                          icon: Icons.person_outline,
                          label: "Giới tính",
                          value: genderText,
                        ),
                        _buildInfoRow(
                          context: context,
                          icon: Icons.home_outlined,
                          label: "Địa chỉ",
                          value: address.isNotEmpty
                              ? address
                              : 'Chưa cập nhật',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // // ========== BIO / GIỚI THIỆU (nếu cần dùng lại) ==========
                  // if (bio != null && bio!.trim().isNotEmpty) ...[
                  //   ReusableCard(
                  //     backgroundColor: cardColor,
                  //     child: Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Text(
                  //           "Giới thiệu",
                  //           style: theme.textTheme.titleMedium?.copyWith(
                  //             fontWeight: FontWeight.w700,
                  //             color: colorScheme.onSurface,
                  //           ),
                  //         ),
                  //         const SizedBox(height: 8),
                  //         ExpandableText(
                  //           text: bio!,
                  //           maxLines: 4,
                  //           style: theme.textTheme.bodyMedium?.copyWith(
                  //             color: colorScheme.onSurface,
                  //             height: 1.5,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  //   const SizedBox(height: 20),
                  // ],

                  // ========== KỸ NĂNG / DỊCH VỤ ==========
                  // if (skillChips.isNotEmpty)
                  //   ReusableCard(
                  //     backgroundColor: cardColor,
                  //     child: Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Text(
                  //           "Kỹ năng & dịch vụ",
                  //           style: theme.textTheme.titleMedium?.copyWith(
                  //             fontWeight: FontWeight.w700,
                  //             color: colorScheme.onSurface,
                  //           ),
                  //         ),
                  //         const SizedBox(height: 8),
                  //         Wrap(
                  //           spacing: 8,
                  //           runSpacing: 8,
                  //           children: skillChips,
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  //
                  // if (skillChips.isNotEmpty) const SizedBox(height: 20),

                  // ========== EXTRA SECTIONS ==========
                  ...extraSections.map(
                        (w) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: w,
                    ),
                  ),

                  // ========== ACTIONS ==========
                  if (actions.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        for (int i = 0; i < actions.length; i++) ...[
                          Expanded(child: actions[i]),
                          if (i != actions.length - 1)
                            const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isNotEmpty ? value : 'Chưa cập nhật',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
