import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../data/models/uploaded_file_model.dart';
import '../repositories/project_application_repository.dart';

class UploadCvUseCase implements UseCase<UploadedFileModel, File> {
  final ProjectApplicationRepository repository;

  UploadCvUseCase({required this.repository});

  @override
  Future<Either<Failure, UploadedFileModel>> call(File file) {
    return repository.uploadCv(file);
  }
}