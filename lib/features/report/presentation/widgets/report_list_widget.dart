import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:labodc_mobile/features/report/presentation/widgets/report_list_item.dart';

import '../cubit/report_cubit.dart';
import '../cubit/report_state.dart';


class ReportListWidget extends StatefulWidget {
  const ReportListWidget({super.key});

  @override
  State<ReportListWidget> createState() => _ReportListWidgetState();
}

class _ReportListWidgetState extends State<ReportListWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      final cubit = context.read<ReportCubit>();

      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        cubit.loadMore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<ReportCubit, ReportState>(
      builder: (context, state) {
        if (state.status == ReportStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == ReportStatus.failure) {
          return Center(
            child: Text(state.errorMessage ?? "Lỗi tải dữ liệu"),
          );
        }

        if (state.items.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.report_off_outlined,
                    size: 70, color: theme.colorScheme.onSurface.withOpacity(0.4)),
                const SizedBox(height: 14),
                Text(
                  "Không có báo cáo",
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => context.read<ReportCubit>().refreshReports(),
          child: ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.all(12),
            itemCount: state.items.length + (state.hasNext ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, index) {
              if (index == state.items.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final report = state.items[index];
              return ReportListItem(report: report);
            },
          ),
        );
      },
    );
  }
}
