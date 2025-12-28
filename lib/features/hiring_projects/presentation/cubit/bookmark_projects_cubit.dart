import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/repositories/project_repository.dart';

class BookmarkProjectsCubit extends Cubit<List<ProjectEntity>> {
  final ProjectRepository repository;
  BookmarkProjectsCubit(this.repository) : super([]);

  Future<void> loadBookmarks(String userId) async {
    if (userId.isEmpty) {
      emit([]);
      return;
    }
    final result = await repository.getBookmarkedProjects(userId);
    result.fold((_) => emit([]), (projects) => emit(projects));
  }

  Future<void> toggleBookmark(ProjectEntity project, String userId) async {
    if (userId.isEmpty) return;

    final isBookmarked = await repository.checkIsBookmarked(project.projectId, userId);
    if (isBookmarked) {
      await repository.unbookmarkProject(project.projectId, userId);
    } else {
      await repository.bookmarkProject(project, userId);
    }
    await loadBookmarks(userId);
  }
}