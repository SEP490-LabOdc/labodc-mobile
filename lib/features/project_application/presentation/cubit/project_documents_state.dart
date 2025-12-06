import '../../data/models/project_document_model.dart';

abstract class ProjectDocumentsState {}

class ProjectDocumentsInitial extends ProjectDocumentsState {}

class ProjectDocumentsLoading extends ProjectDocumentsState {}

class ProjectDocumentsLoaded extends ProjectDocumentsState {
  final List<ProjectDocumentModel> documents;
  ProjectDocumentsLoaded(this.documents);
}

class ProjectDocumentsError extends ProjectDocumentsState {
  final String message;
  ProjectDocumentsError(this.message);
}