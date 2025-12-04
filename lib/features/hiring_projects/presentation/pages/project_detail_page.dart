import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// 1. Core, Auth
import '../../../../core/get_it/get_it.dart';
import '../../../../core/error/failures.dart';
import '../../../../shared/widgets/network_image_with_fallback.dart';
import '../../../auth/presentation/provider/auth_provider.dart';

// 2. Hiring Project Feature
import '../../../project_application/domain/repositories/project_application_repository.dart';
import '../../../project_application/presentation/pages/project_applicants_page.dart';
import '../../domain/repositories/project_repository.dart';
import '../../data/models/project_detail_model.dart';

// 3. Project Application Feature
import '../../../project_application/presentation/cubit/project_application_cubit.dart';
import '../../../project_application/presentation/widgets/apply_confirmation_modal.dart';
import '../../../project_application/data/models/submitted_cv_model.dart';
import '../../../project_application/domain/use_cases/upload_cv_use_case.dart';

// 4. Shared Widgets & Utils
import '../../../../shared/widgets/reusable_card.dart';
import '../../../../shared/widgets/expandable_text.dart';
import '../../../../shared/widgets/service_chip.dart';
import '../cubit/related_projects_preview_cubit.dart';
import '../cubit/related_projects_preview_state.dart';
import '../utils/project_data_formatter.dart';
import '../widgets/related_project_miniCard.dart';

class ProjectDetailPage extends StatelessWidget {
  final String projectId;

  const ProjectDetailPage({
    super.key,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('[ProjectDetailPage] build, projectId = $projectId');
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProjectApplicationCubit>(
          create: (_) => getIt<ProjectApplicationCubit>(),
        ),
        BlocProvider<RelatedProjectsPreviewCubit>(
          create: (_) => getIt<RelatedProjectsPreviewCubit>()
            ..loadPreview(projectId),
        ),
      ],
      child: ProjectDetailView(projectId: projectId),
    );

  }
}

class ProjectDetailView extends StatefulWidget {
  final String projectId;

  const ProjectDetailView({
    super.key,
    required this.projectId,
  });

  @override
  State<ProjectDetailView> createState() => _ProjectDetailViewState();
}

class _ProjectDetailViewState extends State<ProjectDetailView> {
  ProjectDetailModel? _project;
  bool _loading = true;
  String? _error;

  bool _hasApplied = false;
  bool _checkingApplied = false;

  @override
  void initState() {
    super.initState();
    debugPrint('[ProjectDetailView] initState, projectId = ${widget.projectId}');
    _fetchProjectData();
  }

  // ================== LOAD PROJECT DETAIL ==================

  Future<void> _fetchProjectData() async {
    debugPrint('[ProjectDetailView] _fetchProjectData() START');
    setState(() {
      _loading = true;
      _error = null;
    });

    final projectRepository = getIt<ProjectRepository>();
    final result = await projectRepository.getProjectDetail(widget.projectId);

    if (!mounted) {
      debugPrint('[ProjectDetailView] _fetchProjectData() - widget not mounted');
      return;
    }

    result.fold(
          (failure) {
        debugPrint('[ProjectDetailView] _fetchProjectData() FAILURE: $failure');
        setState(() {
          _error = _mapFailureToMessage(failure);
          _loading = false;
        });
      },
          (data) {
        debugPrint(
            '[ProjectDetailView] _fetchProjectData() SUCCESS, projectId = ${data.id}');
        setState(() {
          _project = data;
          _loading = false;
        });

        // Sau khi có project -> check xem user đã apply chưa
        _checkAppliedStatus();
      },
    );

    debugPrint('[ProjectDetailView] _fetchProjectData() END');
  }

  // ================== CHECK ĐÃ ỨNG TUYỂN CHƯA ==================

  Future<void> _checkAppliedStatus() async {
    if (_project == null) return;

    setState(() {
      _checkingApplied = true;
    });

    final appRepository = getIt<ProjectApplicationRepository>();
    final result = await appRepository.hasAppliedProject(_project!.id);

    if (!mounted) return;

    result.fold(
          (failure) {
        if (kDebugMode) {
          debugPrint('[ProjectDetailView] hasAppliedProject FAILURE: $failure');
        }
        // UX kiểu big company: lỗi thì im lặng, coi như chưa apply
        setState(() {
          _checkingApplied = false;
          _hasApplied = false;
        });
      },
          (hasApplied) {
        if (kDebugMode) {
          debugPrint(
              '[ProjectDetailView] hasAppliedProject SUCCESS: $hasApplied');
        }
        setState(() {
          _hasApplied = hasApplied;
          _checkingApplied = false;
        });
      },
    );
  }

  // ================== COMMON UTILS ==================

  String _mapFailureToMessage(Failure failure) {
    debugPrint('[ProjectDetailView] _mapFailureToMessage: $failure');
    if (failure is ServerFailure) return failure.message;
    if (failure is NetworkFailure) return 'Vui lòng kiểm tra kết nối mạng.';
    return 'Đã xảy ra lỗi không xác định.';
  }

  void _showSnackBar(String message, {bool isError = false}) {
    debugPrint(
        '[ProjectDetailView] _showSnackBar: "$message", isError=$isError');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
        isError ? Colors.redAccent : Theme.of(context).primaryColor,
      ),
    );
  }

  // ================== UI PHỤ ==================

  Widget _buildHeaderSection(BuildContext context, ProjectDetailModel p) {
    final theme = Theme.of(context);
    final statusColor = ProjectDataFormatter.getStatusColor(p.status);
    final statusText = ProjectDataFormatter.translateStatus(p.status);

    return ReusableCard(
      elevation: 0,
      border: Border.all(color: Colors.transparent),
      backgroundColor: Colors.transparent,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Tiêu đề + công ty
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (p.companyName != null && p.companyName!.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.business,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            p.companyName!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: statusColor.withOpacity(0.5)),
                ),
                child: Text(
                  statusText,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallInfoCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        String? content,
        Widget? contentWidget,
      }) {
    final theme = Theme.of(context);
    return ReusableCard(
      padding: const EdgeInsets.all(12),
      backgroundColor: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          contentWidget ??
              Text(
                content ?? '',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildInfoCardsRow(BuildContext context, ProjectDetailModel p) {
    final startText = p.startDate != null
        ? ProjectDataFormatter.formatDate(p.startDate!)
        : 'Chưa cập nhật';

    final endText = p.endDate != null
        ? ProjectDataFormatter.formatDate(p.endDate!)
        : 'Chưa cập nhật';

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _buildSmallInfoCard(
            context,
            icon: Icons.calendar_month_outlined,
            title: 'Thời gian',
            content: '$startText\n- $endText',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 4,
          child: _buildSmallInfoCard(
            context,
            icon: Icons.monetization_on_outlined,
            title: 'Ngân sách & Cột mốc',
            contentWidget: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ProjectDataFormatter.formatCurrency(context, p.budget),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.flag_outlined,
                      size: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        p.currentMilestoneName ?? 'Chưa có',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }


  /// Skills: ProjectSkillModel
  Widget _buildSkillsSection(
      BuildContext context,
      List<ProjectSkillModel> skills,
      ) {
    final theme = Theme.of(context);
    if (skills.isEmpty) {
      return Text(
        'Chưa có kỹ năng được gắn với dự án này.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: skills
          .map(
            (skill) => ServiceChip(
          name: skill.name,
          color: '#000000',
          small: false,
        ),
      )
          .toList(),
    );
  }

  /// Mentors: ProjectMentorModel
  Widget _buildMentorsSection(
      BuildContext context,
      List<ProjectMentorModel> mentors,
      ) {
    final theme = Theme.of(context);

    if (mentors.isEmpty) {
      return Text(
        'Chưa có mentor được gán cho dự án này.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Column(
      children: mentors.map((m) {
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),

          /// ✅ Avatar với fallback
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: NetworkImageWithFallback(
              imageUrl: m.avatar ?? "",
              width: 44,
              height: 44,
              fit: BoxFit.cover,
              fallbackIcon: Icons.person,
              fallbackIconColor: theme.colorScheme.onSurfaceVariant,
              fallbackIconSize: 26,
              borderRadius: BorderRadius.circular(999),
            ),
          ),

          title: Row(
            children: [
              Expanded(
                child: Text(
                  m.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (m.leader)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Leader',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),

          subtitle: Text(
            m.roleName,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        );
      }).toList(),
    );
  }


  /// Talents: ProjectTalentModel
  Widget _buildTalentsSection(
      BuildContext context,
      List<ProjectTalentModel> talents,
      ) {
    final theme = Theme.of(context);

    if (talents.isEmpty) {
      return Text(
        'Chưa có thành viên nào tham gia dự án này.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Column(
      children: talents.map((t) {
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),

          /// ✅ Avatar với fallback
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: NetworkImageWithFallback(
              imageUrl: t.avatar ?? "",
              width: 44,
              height: 44,
              fit: BoxFit.cover,
              fallbackIcon: Icons.person,
              fallbackIconColor: theme.colorScheme.onSurfaceVariant,
              fallbackIconSize: 26,
              borderRadius: BorderRadius.circular(999),
            ),
          ),

          title: Row(
            children: [
              Expanded(
                child: Text(
                  t.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (t.leader)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Leader',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),

          subtitle: Text(
            t.roleName,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        );
      }).toList(),
    );
  }


  Widget _buildMetadataFooter(BuildContext context, ProjectDetailModel p) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Project ID: ${p.id}', style: style),
        const SizedBox(height: 4),
        Text(
          'Tạo lúc: ${ProjectDataFormatter.formatDateTime(p.createdAt)}',
          style: style,
        ),
      ],
    );
  }

  // ================== MODAL XÁC NHẬN ỨNG TUYỂN ==================

  void _showApplyConfirmationModal({
    required String fileName,
    required String cvUrl,
  }) {
    debugPrint(
        '[ProjectDetailView] _showApplyConfirmationModal: fileName=$fileName, cvUrl=$cvUrl');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => BlocProvider.value(
        value: context.read<ProjectApplicationCubit>(),
        child: BlocBuilder<ProjectApplicationCubit, ProjectApplicationState>(
          builder: (context, modalState) {
            final isApplying = modalState is ProjectApplicationLoading;
            debugPrint(
                '[ProjectDetailView] ApplyConfirmationModal build, isApplying=$isApplying');
            return ApplyConfirmationModal(
              project: _project!,
              fileName: fileName,
              isApplying: isApplying,
              onConfirm: () {
                debugPrint(
                    '[ProjectDetailView] onConfirm APPLY -> applyToProject');
                context
                    .read<ProjectApplicationCubit>()
                    .applyToProject(widget.projectId, cvUrl);
              },
            );
          },
        ),
      ),
    );
  }

  // ================== PICK + UPLOAD CV CHO SHEET ==================

  Future<void> _pickAndUploadCvForSheet({
    required void Function(void Function()) setModalState,
    required List<SubmittedCvModel> localCvs,
    required void Function(int newIndex) onCvAdded,
  }) async {
    debugPrint('[ProjectDetailView] _pickAndUploadCvForSheet() START');
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles();
      debugPrint(
          '[ProjectDetailView] FilePicker result: ${result == null ? 'null (user cancel)' : 'OK'}');
      if (result == null) return; // user cancel

      final PlatformFile pickedFile = result.files.single;
      debugPrint(
          '[ProjectDetailView] Picked file: name=${pickedFile.name}, path=${pickedFile.path}');

      if (pickedFile.path == null) {
        _showSnackBar(
          'Không thể đọc đường dẫn file. Nền tảng hiện tại chưa được hỗ trợ.',
          isError: true,
        );
        return;
      }

      final file = File(pickedFile.path!);
      debugPrint(
          '[ProjectDetailView] UploadCvUseCase.call() with file.path=${file.path}');

      final uploadUseCase = getIt<UploadCvUseCase>();
      final uploadResult = await uploadUseCase.call(file);

      uploadResult.fold(
            (failure) {
          debugPrint('[ProjectDetailView] uploadResult FAILURE: $failure');
          _showSnackBar(_mapFailureToMessage(failure), isError: true);
        },
            (uploaded) {
          debugPrint(
              '[ProjectDetailView] uploadResult SUCCESS: fileName=${uploaded.fileName}, fileUrl=${uploaded.fileUrl}');
          setModalState(() {
            localCvs.add(
              SubmittedCvModel(
                fileLink: uploaded.fileUrl,
                fileName: uploaded.fileName,
              ),
            );
            final idx = localCvs.length - 1;
            debugPrint(
                '[ProjectDetailView] localCvs length after add: ${localCvs.length}, newIndex=$idx');
            onCvAdded(idx);
          });

          _showSnackBar(
            'Upload CV thành công. Bạn có thể dùng CV này để ứng tuyển.',
          );
        },
      );
    } catch (e, st) {
      debugPrint(
          '[ProjectDetailView] Error in _pickAndUploadCvForSheet: $e\n$st');
      _showSnackBar('Không thể chọn hoặc upload CV: $e', isError: true);
    } finally {
      debugPrint('[ProjectDetailView] _pickAndUploadCvForSheet() END');
    }
  }

  // ================== SHEET CHỌN CV ==================

  void _showCvSelectionSheet(List<SubmittedCvModel> initialCvs) {
    final theme = Theme.of(context);
    debugPrint(
        '[ProjectDetailView] _showCvSelectionSheet() initialCvs.length=${initialCvs.length}');

    final List<SubmittedCvModel> localCvs = List.of(initialCvs);
    int? selectedIndex = localCvs.isNotEmpty ? 0 : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        debugPrint(
            '[ProjectDetailView] BottomSheet builder: localCvs.length=${localCvs.length}');
        return StatefulBuilder(
          builder: (context, setModalState) {
            debugPrint(
                '[ProjectDetailView] StatefulBuilder build: localCvs.length=${localCvs.length}, selectedIndex=$selectedIndex');
            return Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // drag handle
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Chọn CV để ứng tuyển',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _project?.title ?? '',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Danh sách CV
                    if (localCvs.isEmpty)
                      Column(
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 40,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Bạn chưa có CV nào.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      )
                    else
                      SizedBox(
                        height: 240,
                        child: ListView.separated(
                          itemCount: localCvs.length,
                          separatorBuilder: (_, __) =>
                          const SizedBox(height: 4),
                          itemBuilder: (context, index) {
                            final cv = localCvs[index];
                            debugPrint(
                                '[ProjectDetailView] build CV tile index=$index, fileName=${cv.fileName}');
                            return RadioListTile<int>(
                              value: index,
                              groupValue: selectedIndex,
                              onChanged: (value) {
                                debugPrint(
                                    '[ProjectDetailView] onChanged RadioListTile: value=$value');
                                if (value == null) return;
                                setModalState(() {
                                  selectedIndex = value;
                                  debugPrint(
                                      '[ProjectDetailView] selectedIndex updated -> $selectedIndex');
                                });
                              },
                              dense: true,
                              title: Text(
                                cv.fileName,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                cv.fileLink,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Hàng nút: Upload mới + Tiếp tục
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              debugPrint(
                                  '[ProjectDetailView] [Sheet] Upload CV mới pressed');
                              await _pickAndUploadCvForSheet(
                                setModalState: setModalState,
                                localCvs: localCvs,
                                onCvAdded: (newIndex) {
                                  debugPrint(
                                      '[ProjectDetailView] [Sheet] onCvAdded, newIndex=$newIndex');
                                  selectedIndex = newIndex;
                                },
                              );
                            },
                            icon: const Icon(
                              Icons.upload_file_outlined,
                              size: 18,
                            ),
                            label: const Text('Upload CV mới'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton(
                            onPressed: (selectedIndex == null)
                                ? null
                                : () {
                              final selectedCv =
                              localCvs[selectedIndex!];
                              debugPrint(
                                  '[ProjectDetailView] [Sheet] Tiếp tục pressed, selectedIndex=$selectedIndex, fileName=${selectedCv.fileName}');
                              Navigator.pop(modalContext);
                              _showApplyConfirmationModal(
                                fileName: selectedCv.fileName,
                                cvUrl: selectedCv.fileLink,
                              );
                            },
                            child: const Text('Tiếp tục'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ================== BUILD CHÍNH ==================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final authProvider = context.watch<AuthProvider>();
    final role = (authProvider.currentUser?.role ?? '').toUpperCase();
    debugPrint(
        '[ProjectDetailView] build(), role=$role, loading=$_loading, error=$_error, hasApplied=$_hasApplied, checkingApplied=$_checkingApplied');

    final canApplyRole = role == 'TALENT' || role == 'USER';
    final isMentorRole = role == 'MENTOR';

    final canShowBottomArea = canApplyRole &&
        _project != null &&
        !_loading &&
        _error == null &&
        !_checkingApplied;

    final canApplyThisProject = canShowBottomArea && !_hasApplied;

    return BlocListener<ProjectApplicationCubit, ProjectApplicationState>(
      listener: (context, state) async {
        debugPrint(
            '[ProjectDetailView] BlocListener state: ${state.runtimeType}');
        if (state is ProjectApplicationLoading) {
          debugPrint('[ProjectDetailView] state = ProjectApplicationLoading');
        } else if (state is ProjectApplicationCvCheckSuccess) {
          debugPrint(
              '[ProjectDetailView] state = ProjectApplicationCvCheckSuccess, cvs.length=${state.cvs.length}');
          _showCvSelectionSheet(state.cvs);
        } else if (state is ProjectApplicationApplySuccess) {
          debugPrint(
              '[ProjectDetailView] state = ProjectApplicationApplySuccess -> pop modal & show snackbar');
          if (Navigator.canPop(context)) {
            Navigator.pop(context); // đóng modal xác nhận
          }
          _showSnackBar('Ứng tuyển thành công!');
          await _checkAppliedStatus();
        } else if (state is ProjectApplicationFailure) {
          debugPrint(
              '[ProjectDetailView] state = ProjectApplicationFailure, message=${state.message}');
          _showSnackBar(state.message, isError: true);

          if (state.message
              .toLowerCase()
              .contains('bạn đã ứng tuyển vào dự án này')) {
            await _checkAppliedStatus();
          }
        }
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.surfaceVariant,
        appBar: AppBar(
          backgroundColor: theme.colorScheme.surfaceVariant,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: theme.colorScheme.onSurface,
            ),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text(
            'Chi tiết dự án',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  color: theme.colorScheme.error,
                  size: 40,
                ),
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _fetchProjectData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        )
            : _project == null
            ? Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Không tìm thấy dữ liệu dự án.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        )
            : SingleChildScrollView(
          padding:
          const EdgeInsets.fromLTRB(16, 8, 16, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(context, _project!),
              const SizedBox(height: 20),
              _buildInfoCardsRow(context, _project!),
              const SizedBox(height: 20),
              SectionCard(
                title: 'Mô tả dự án',
                child: ExpandableText(
                  text: _project!.description,
                  maxLines: 6,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SectionCard(
                title: 'Kỹ năng yêu cầu',
                child: _buildSkillsSection(
                  context,
                  _project!.skills,
                ),
              ),
              const SizedBox(height: 20),
              SectionCard(
                title: 'Mentors',
                child: _buildMentorsSection(
                  context,
                  _project!.mentors,
                ),
              ),
              const SizedBox(height: 20),
              SectionCard(
                title: 'Thành viên',
                child: _buildTalentsSection(
                  context,
                  _project!.talents,
                ),
              ),
              const SizedBox(height: 20),
              SectionCard(
                title: 'Dự án liên quan',
                child: _buildRelatedProjectsSection(context),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8.0),
                child: _buildMetadataFooter(
                  context,
                  _project!,
                ),
              ),
            ],
          ),
        ),
        floatingActionButton:
        !canShowBottomArea
            ? null
            : canApplyThisProject
            ? FloatingActionButton.extended(
          onPressed: () {
            debugPrint(
                '[ProjectDetailView] FAB "Ứng tuyển ngay" pressed -> checkCvAvailability');
            context
                .read<ProjectApplicationCubit>()
                .checkCvAvailability();
          },
          label: const Text('Ứng tuyển ngay'),
          icon: const Icon(Icons.rocket_launch_rounded),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          elevation: 4,
        )
            : FloatingActionButton.extended(
          onPressed: () {
            _showSnackBar(
              'Bạn đã ứng tuyển dự án này. Vui lòng chờ phản hồi từ công ty.',
            );
          },
          label: const Text('Đã ứng tuyển'),
          icon: const Icon(Icons.check_circle_outline),
          backgroundColor: Colors.grey.shade400,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
    );
  }
}

Widget _buildRelatedProjectsSection(BuildContext context) {
  final theme = Theme.of(context);

  return BlocBuilder<RelatedProjectsPreviewCubit, RelatedProjectsPreviewState>(
    builder: (context, state) {
      // Đang load: skeleton ngang
      if (state.isLoading) {
        return SizedBox(
          height: 170,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, __) {
              return Container(
                width: 240,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                ),
              );
            },
          ),
        );
      }

      // Lỗi
      if (state.errorMessage != null) {
        return Text(
          state.errorMessage!,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.error,
          ),
        );
      }

      // Không có dự án liên quan
      if (state.projects.isEmpty) {
        return Text(
          'Chưa có dự án liên quan nào.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        );
      }

      // Có dữ liệu
      return SizedBox(
        height: 180,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: state.projects.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final project = state.projects[index];
            return RelatedProjectMiniCard(project: project);
          },
        ),
      );
    },
  );
}

