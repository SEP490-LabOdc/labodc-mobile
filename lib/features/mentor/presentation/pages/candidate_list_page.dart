import 'package:flutter/material.dart';

class CandidateListPage extends StatelessWidget {
  const CandidateListPage({super.key, required int candidateId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ứng viên mới'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: 5,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _CandidateCard(
            candidateName: 'Ứng viên ${index + 1}',
            skills: ['ReactJS', 'Flutter', 'UI/UX'],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CandidateListPage(candidateId: index),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _CandidateCard extends StatelessWidget {
  final String candidateName;
  final List<String> skills;
  final VoidCallback? onTap;

  const _CandidateCard({
    required this.candidateName,
    required this.skills,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      candidateName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: skills.map((skill) => Chip(
                        label: Text(
                          skill,
                          style: const TextStyle(fontSize: 12),
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      )).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}