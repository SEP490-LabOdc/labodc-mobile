
import '../../../milestone/data/models/milestone_document_model.dart';

abstract class MilestoneDocumentsState {}

class MilestoneDocumentsInitial extends MilestoneDocumentsState {}

class MilestoneDocumentsLoading extends MilestoneDocumentsState {}

class MilestoneDocumentsLoaded extends MilestoneDocumentsState {
  final List<MilestoneDocumentModel> documents;
  MilestoneDocumentsLoaded(this.documents);
}

class MilestoneDocumentsError extends MilestoneDocumentsState {
  final String message;
  MilestoneDocumentsError(this.message);
}