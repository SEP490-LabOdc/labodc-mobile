import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../data/models/submitted_cv_model.dart';
import '../repositories/project_application_repository.dart';

class GetMySubmittedCvsUseCase implements UseCase<List<SubmittedCvModel>, NoParams> {
  final ProjectApplicationRepository repository;

  GetMySubmittedCvsUseCase({required this.repository});

  @override
  Future<Either<Failure, List<SubmittedCvModel>>> call(NoParams params) {
    return repository.getMySubmittedCvs();
  }
}