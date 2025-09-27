import 'package:flutter/material.dart';
import 'package:labodc_mobile/features/mentor/presentation/pages/task_detail_page.dart';

import 'candidate_detail_page.dart';


class MentorApprovalsPage extends StatefulWidget {
  const MentorApprovalsPage({super.key});

  @override
  State<MentorApprovalsPage> createState() => _MentorApprovalsPageState();
}

class _MentorApprovalsPageState extends State<MentorApprovalsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phê duyệt'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tasks'),
            Tab(text: 'Ứng viên'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const _TaskApprovalList(),
          const _CandidateApprovalList(),
        ],
      ),
    );
  }
}

class _TaskApprovalList extends StatelessWidget {
  const _TaskApprovalList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: 5,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _TaskCard(
          taskName: 'Task ${index + 1}: Implement Login Feature',
          talentName: 'Nguyen Van A',
          projectName: 'Mobile App Project',
          timeSubmitted: '2 giờ trước',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TaskDetailPage(taskId: index),
              ),
            );
          },
        );
      },
    );
  }
}

class _CandidateApprovalList extends StatelessWidget {
  const _CandidateApprovalList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: 3,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _CandidateCard(
          candidateName: 'Candidate ${index + 1}',
          skills: ['ReactJS', 'Flutter', 'UI/UX'],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CandidateDetailPage(candidateId: index),
              ),
            );
          },
        );
      },
    );
  }
}

class _TaskCard extends StatelessWidget {
  final String taskName;
  final String talentName;
  final String projectName;
  final String timeSubmitted;
  final VoidCallback? onTap;

  const _TaskCard({
    required this.taskName,
    required this.talentName,
    required this.projectName,
    required this.timeSubmitted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                taskName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(talentName, style: const TextStyle(fontSize: 14)),
                        Text(
                          projectName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Chờ duyệt',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                timeSubmitted,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
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