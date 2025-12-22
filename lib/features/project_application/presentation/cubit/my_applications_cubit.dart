import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/my_application_model.dart';
import '../../domain/repositories/project_application_repository.dart';

abstract class MyApplicationsState {}
class MyApplicationsLoading extends MyApplicationsState {}
class MyApplicationsLoaded extends MyApplicationsState {
  final List<MyApplicationModel> applications;
  MyApplicationsLoaded(this.applications);
}
class MyApplicationsError extends MyApplicationsState {
  final String message;
  MyApplicationsError(this.message);
}

class MyApplicationsCubit extends Cubit<MyApplicationsState> {
  final ProjectApplicationRepository repository;
  MyApplicationsCubit({required this.repository}) : super(MyApplicationsLoading());

  Future<void> loadApplications() async {
    emit(MyApplicationsLoading());
    final result = await repository.getMyApplications();
    result.fold(
          (l) => emit(MyApplicationsError(l.message)),
          (r) => emit(MyApplicationsLoaded(r)),
    );
  }
}