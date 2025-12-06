import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/milestone_repository.dart';
import 'milestone_documents_state.dart';

class MilestoneDocumentsCubit extends Cubit<MilestoneDocumentsState> {
  final MilestoneRepository repository;

  MilestoneDocumentsCubit(this.repository) : super(MilestoneDocumentsInitial());

  Future<void> loadDocuments(String milestoneId) async {
    emit(MilestoneDocumentsLoading());

    final result = await repository.getMilestoneDocuments(milestoneId);

    result.fold(
          (failure) => emit(MilestoneDocumentsError(failure.message)),
          (documents) => emit(MilestoneDocumentsLoaded(documents)),
    );
  }
}