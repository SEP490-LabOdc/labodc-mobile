import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/project_application_repository.dart';
import '../data_sources/project_application_remote_data_source.dart';
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
}