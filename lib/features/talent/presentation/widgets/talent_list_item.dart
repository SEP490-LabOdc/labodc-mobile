// lib/shared/widgets/talent_list_item.dart

import 'package:flutter/material.dart';
import '../../../../shared/widgets/network_image_with_fallback.dart';
import '../../../../shared/widgets/service_chip.dart';


class TalentListItem extends StatelessWidget {
  final String name;
  final String role;
  final String avatarUrl;
  final List<String> skills;
  final VoidCallback? onTap;

  const TalentListItem({
    super.key,
    required this.name,
    required this.role,
    required this.avatarUrl,
    required this.skills,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar
                NetworkImageWithFallback(
                  imageUrl: avatarUrl,
                  width: 50,
                  height: 50,
                  borderRadius: BorderRadius.circular(25),
                  fallbackIcon: Icons.person,
                ),
                const SizedBox(width: 12),

                // Name and Role
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        role,
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),

                // Nút theo dõi (ví dụ)
                IconButton(
                  icon: Icon(Icons.star_border, color: theme.colorScheme.primary),
                  onPressed: () {},
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Skills/Services
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills.map((skill) => ServiceChip(
                name: skill,
                color: "#4CAF50",
                small: true,
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}