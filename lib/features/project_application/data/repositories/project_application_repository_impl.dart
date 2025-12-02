import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:labodc_mobile/features/project_application/data/models/my_project_model.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/project_application_repository.dart';
import '../data_sources/project_application_remote_data_source.dart';
import '../models/project_applicant_model.dart';
import '../models/submitted_cv_model.dart';
import '../models/uploaded_file_model.dart';

class ProjectApplicationRepositoryImpl implements ProjectApplicationRepository {
  final ProjectApplicationRemoteDataSource remoteDataSource;

  ProjectApplicationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<SubmittedCvModel>>> getMySubmittedCvs() async {
    try {
      final result = await remoteDataSource.getMySubmittedCvs();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode ?? 500));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString(), 500));
    }
  }

  @override
  Future<Either<Failure, void>> applyProject({required String userId, required String projectId, required String cvUrl}) async {
    try {
      await remoteDataSource.applyProject(userId: userId, projectId: projectId, cvUrl: cvUrl);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode ?? 500));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString(), 500));
    }
  }

  @override
  Future<Either<Failure, UploadedFileModel>> uploadCv(File file) async {
    try {
      final result = await remoteDataSource.uploadCvFile(file);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode ?? 500));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString(), 500));
    }
  }

  @override
  Future<Either<Failure, bool>> hasAppliedProject(
      String projectId,
      ) async {
    try {
      final status =
      await remoteDataSource.getApplicationStatus(projectId);

      // Core logic:
      // canApply == true  -> user CHƯA apply -> hasApplied = false
      // canApply == false -> user ĐÃ apply  -> hasApplied = true
      final hasApplied = !status.canApply;

      return Right(hasApplied);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode ?? 500));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString(), 500));
    }
  }

  @override
  Future<Either<Failure, List<MyProjectModel>>> getMyProjects({
    String? status,
  }) async {
    try {
      final result = await remoteDataSource.getMyProjects(status: status);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode ?? 500));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString(), 500));
    }
  }

  @override
  Future<Either<Failure, List<ProjectApplicantModel>>> getProjectApplicants(
      String projectId) async {
    try {
      final result =
      await remoteDataSource.getProjectApplicants(projectId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode ?? 500));
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString(), 500));
    }
  }


}