import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/project_application_repository.dart';
import 'project_documents_state.dart';

class ProjectDocumentsCubit extends Cubit<ProjectDocumentsState> {
  final ProjectApplicationRepository repository;

  ProjectDocumentsCubit(this.repository) : super(ProjectDocumentsInitial());

  Future<void> loadDocuments(String projectId) async {
    emit(ProjectDocumentsLoading());

    final result = await repository.getProjectDocuments(projectId);

    result.fold(
          (failure) => emit(ProjectDocumentsError(failure.message)),
          (documents) => emit(ProjectDocumentsLoaded(documents)),
    );
  }
}