import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/submitted_cv_model.dart';
import '../../data/models/uploaded_file_model.dart';

abstract class ProjectApplicationRepository {
  Future<Either<Failure, List<SubmittedCvModel>>> getMySubmittedCvs();
  Future<Either<Failure, void>> applyProject({required String userId, required String projectId, required String cvUrl});
  Future<Either<Failure, UploadedFileModel>> uploadCv(File file);
}