import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as dio;
import 'package:labodc_mobile/features/project_application/data/models/my_project_model.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/milestone_repository.dart';
import '../data_sources/milestone_remote_data_source.dart';
import '../models/milestone_detail_model.dart';
import '../models/milestone_disbursement_model.dart';
import '../models/milestone_document_model.dart';
import '../models/milestone_member_model.dart';
import '../models/milestone_wallet_model.dart';
import '../models/project_milestone_model.dart';

class MilestoneRepositoryImpl implements MilestoneRepository {
  final MilestoneRemoteDataSource remoteDataSource;

  MilestoneRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ProjectMilestoneModel>>> getMilestones(
    String projectId,
  ) async {
    try {
      final result = await remoteDataSource.getMilestones(projectId);
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
  Future<Either<Failure, MilestoneDetailModel>> getMilestoneDetail(
    String milestoneId,
  ) async {
    try {
      final result = await remoteDataSource.getMilestoneDetail(milestoneId);
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
  Future<Either<Failure, List<MilestoneDocumentModel>>> getMilestoneDocuments(
    String milestoneId,
  ) async {
    try {
      final result = await remoteDataSource.getMilestoneDocuments(milestoneId);
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
  Future<Either<Failure, MilestoneDisbursementModel>> getMilestoneDisbursement(
    String milestoneId,
  ) async {
    try {
      final result = await remoteDataSource.getMilestoneDisbursement(
        milestoneId,
      );
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
  Future<Either<Failure, List<ProjectMilestoneModel>>> getPaidMilestones(
    String projectId,
  ) async {
    try {
      final result = await remoteDataSource.getPaidMilestones(projectId);
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
  Future<Either<Failure, List<MilestoneMemberModel>>> getMilestoneMembersByRole(
    String milestoneId,
    String role,
  ) async {
    try {
      final result = await remoteDataSource.getMilestoneMembersByRole(
        milestoneId,
        role,
      );
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
  Future<Either<Failure, MilestoneWalletModel?>> getMilestoneWallet(
    String milestoneId,
  ) async {
    try {
      final result = await remoteDataSource.getMilestoneWallet(milestoneId);
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
