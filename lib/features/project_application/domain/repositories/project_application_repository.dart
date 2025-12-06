import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:labodc_mobile/features/project_application/data/models/my_project_model.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/project_applicant_model.dart';
import '../../data/models/project_document_model.dart';
import '../../data/models/submitted_cv_model.dart';
import '../../data/models/uploaded_file_model.dart';

abstract class ProjectApplicationRepository {
  Future<Either<Failure, List<SubmittedCvModel>>> getMySubmittedCvs();
  Future<Either<Failure, void>> applyProject({required String userId, required String projectId, required String cvUrl});
  Future<Either<Failure, UploadedFileModel>> uploadCv(File file);
  Future<Either<Failure, bool>> hasAppliedProject(String projectId);
  Future<Either<Failure, List<MyProjectModel>>> getMyProjects({String? status});
  Future<Either<Failure, List<ProjectApplicantModel>>> getProjectApplicants(
      String projectId);
  Future<Either<Failure, void>> approveProjectApplication(
      String projectApplicationId,
      );
  Future<Either<Failure, void>> rejectProjectApplication(
      String projectApplicationId,
      String reviewNotes,
      );

  Future<Either<Failure, List<ProjectDocumentModel>>> getProjectDocuments(String projectId);

}