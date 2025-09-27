import 'package:flutter/material.dart';
import '../../../../shared/widgets/expandable_text.dart';
import '../../../../shared/widgets/network_image_with_fallback.dart';
import '../../../../shared/widgets/reusable_card.dart';
import '../../../../shared/widgets/service_chip.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar + Basic Info
            ReusableCard(
              child: Row(
                children: [
                  NetworkImageWithFallback(
                    imageUrl:
                    "https://github.com/shadcn.png",
                    width: 80,
                    height: 80,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Bội Anh Cúc",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "boianhcuc@example.com",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Bio / Description
            ReusableCard(
              child: const ExpandableText(
                text:
                "Mình là một lập trình viên Flutter, yêu thích xây dựng ứng dụng "
                    "di động và khám phá công nghệ mới. Trong thời gian rảnh, "
                    "mình thường đọc sách, nghe nhạc và tham gia các dự án mã nguồn mở.",
                maxLines: 3,
              ),
            ),

            const SizedBox(height: 16),

            // Services / Skills
            ReusableCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Kỹ năng & Dịch vụ",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      ServiceChip(name: "Flutter", color: "#42A5F5"),
                      ServiceChip(name: "Firebase", color: "#FFCA28"),
                      ServiceChip(name: "REST API", color: "#66BB6A"),
                      ServiceChip(name: "UI/UX Design", color: "#AB47BC"),
                      ServiceChip(name: "Cloud Deployment", color: "#29B6F6"),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
