import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

// Core
import '../../../../../core/error/failures.dart';
import '../../../../../core/usecase/usecase.dart';

// Feature: Project Application
import '../../data/models/submitted_cv_model.dart';
import '../../data/models/uploaded_file_model.dart';
import '../../domain/use_cases/apply_project_use_case.dart';
import '../../domain/use_cases/get_my_submitted_cvs_use_case.dart';
import '../../domain/use_cases/upload_cv_use_case.dart';

// === STATES ===

abstract class ProjectApplicationState {}

class ProjectApplicationInitial extends ProjectApplicationState {}

class ProjectApplicationLoading extends ProjectApplicationState {}

class ProjectApplicationFailure extends ProjectApplicationState {
  final String message;

  ProjectApplicationFailure(this.message);
}

// State cho quy trình kiểm tra CV
class ProjectApplicationCvCheckSuccess extends ProjectApplicationState {
  final List<SubmittedCvModel> cvs;

  ProjectApplicationCvCheckSuccess(this.cvs);
}

// State cho quy trình Apply
class ProjectApplicationApplySuccess extends ProjectApplicationState {}

// State cho quy trình Upload (QUAN TRỌNG: giữ nguyên để sheet nhận biết)
class ProjectApplicationUploadSuccess extends ProjectApplicationState {
  final UploadedFileModel uploadedFile;

  ProjectApplicationUploadSuccess(this.uploadedFile);
}

// === CUBIT ===

class ProjectApplicationCubit extends Cubit<ProjectApplicationState> {
  final GetMySubmittedCvsUseCase getCvsUseCase;
  final ApplyProjectUseCase applyProjectUseCase;
  final UploadCvUseCase uploadCvUseCase;

  ProjectApplicationCubit({
    required this.getCvsUseCase,
    required this.applyProjectUseCase,
    required this.uploadCvUseCase,
  }) : super(ProjectApplicationInitial());

  /// Map Failure -> message hiển thị cho user
  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message.isNotEmpty
          ? failure.message
          : 'Lỗi máy chủ. Vui lòng thử lại sau.';
    }

    if (failure is NetworkFailure) {
      return 'Vui lòng kiểm tra kết nối mạng.';
    }

    return 'Đã xảy ra lỗi không xác định.';
  }

  // 1. Kiểm tra CV (Khi nhấn nút Apply ở trang chi tiết)
  Future<void> checkCvAvailability() async {
    emit(ProjectApplicationLoading());

    final result = await getCvsUseCase.call(NoParams());

    result.fold(
          (failure) => emit(ProjectApplicationFailure(_mapFailureToMessage(failure))),
          (cvs) => emit(ProjectApplicationCvCheckSuccess(cvs)),
    );
  }

  // 2. Upload CV (Gọi từ sheet khi user chọn file)
  Future<void> uploadCv(File file) async {
    emit(ProjectApplicationLoading());

    final result = await uploadCvUseCase.call(file);

    result.fold(
          (failure) => emit(ProjectApplicationFailure(_mapFailureToMessage(failure))),
          (fileModel) => emit(ProjectApplicationUploadSuccess(fileModel)),
    );
  }

  // 3. Xác nhận Apply (Khi nhấn nút trên Modal xác nhận)
  Future<void> applyToProject(String projectId, String cvUrl) async {
    emit(ProjectApplicationLoading());

    final result = await applyProjectUseCase.call(
      ApplyProjectParams(projectId: projectId, cvUrl: cvUrl),
    );

    result.fold(
          (failure) => emit(ProjectApplicationFailure(_mapFailureToMessage(failure))),
          (_) => emit(ProjectApplicationApplySuccess()),
    );
  }
}