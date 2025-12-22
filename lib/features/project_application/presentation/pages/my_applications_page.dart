import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/get_it/get_it.dart';
import '../../../../core/router/route_constants.dart';
import '../../../hiring_projects/presentation/utils/project_data_formatter.dart';
import '../../data/models/my_application_model.dart';
import '../cubit/my_applications_cubit.dart';
import '../widgets/application_detail_modal.dart'; // Import modal mới tách

class MyApplicationsPage extends StatelessWidget {
  const MyApplicationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return BlocProvider(
      create: (_) => getIt<MyApplicationsCubit>()..loadApplications(),
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Đơn ứng tuyển của tôi",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            centerTitle: false,
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
            bottom: const TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: TextStyle(fontWeight: FontWeight.bold),
              tabs: [
                Tab(text: "Tất cả"),
                Tab(text: "Đang chờ"),
                Tab(text: "Đã duyệt"),
                Tab(text: "Từ chối/Hủy"),
              ],
            ),
          ),
          body: BlocBuilder<MyApplicationsCubit, MyApplicationsState>(
            builder: (context, state) {
              if (state is MyApplicationsLoading) {
                return const Center(child: CircularProgressIndicator.adaptive());
              }
              if (state is MyApplicationsError) {
                return Center(child: Text(state.message));
              }
              if (state is MyApplicationsLoaded) {
                return TabBarView(
                  children: [
                    _buildTabContent(context, state.applications),
                    _buildTabContent(context, state.applications.where((a) => a.status == 'PENDING').toList()),
                    _buildTabContent(context, state.applications.where((a) => a.status == 'APPROVED').toList()),
                    _buildTabContent(context, state.applications.where((a) => a.status == 'REJECTED' || a.status == 'CANCELED').toList()),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(BuildContext context, List<MyApplicationModel> list) {
    if (list.isEmpty) {
      return const Center(child: Text("Không tìm thấy đơn ứng tuyển nào."));
    }
    return RefreshIndicator(
      onRefresh: () => context.read<MyApplicationsCubit>().loadApplications(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _buildApplicationItem(context, list[index]),
      ),
    );
  }

  Widget _buildApplicationItem(BuildContext context, MyApplicationModel app) {
    final statusColor = ProjectDataFormatter.getApplicationStatusColor(app.status);
    final statusText = ProjectDataFormatter.translateApplicationStatus(app.status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
            title: Text(app.projectName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatusBadge(statusText, statusColor),
                    const SizedBox(width: 12),
                    Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(ProjectDataFormatter.formatDate(app.appliedAt),
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  ],
                ),
              ],
            ),
            trailing: _buildPopupMenu(context, app),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Cập nhật: ${ProjectDataFormatter.formatDate(app.updatedAt)}",
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
                const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context, MyApplicationModel app) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.grey),
      onSelected: (value) => _handleMenuAction(context, value, app),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'cv', child: _MenuLabel(Icons.description_outlined, "Xem CV")),
        const PopupMenuItem(value: 'detail', child: _MenuLabel(Icons.info_outline, "Xem chi tiết")),
        const PopupMenuItem(value: 'project', child: _MenuLabel(Icons.rocket_launch_outlined, "Xem dự án")),
      ],
    );
  }

  void _handleMenuAction(BuildContext context, String action, MyApplicationModel app) {
    switch (action) {
      case 'detail':
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => ApplicationDetailModal(app: app),
        );
        break;
      case 'project':
        context.pushNamed(Routes.projectDetailName, pathParameters: {'id': app.projectId});
        break;
      case 'cv':
      // Logic mở URL CV (Sử dụng url_launcher)
        break;
    }
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10)),
    );
  }
}

class _MenuLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MenuLabel(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 18, color: Colors.grey.shade700),
      const SizedBox(width: 12),
      Text(label, style: const TextStyle(fontSize: 14)),
    ]);
  }
}