// lib/features/company/data/repositories_impl/company_repository_impl.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../shared/models/search_request_model.dart';
import '../../domain/entities/paginated_company_entity.dart';
import '../../domain/repositories/company_repository.dart';
import '../data_sources/company_remote_data_source.dart';
import '../models/company_model.dart';
import '../models/company_project_model.dart';

class CompanyRepositoryImpl implements CompanyRepository {
  final CompanyRemoteDataSource remoteDataSource;

  CompanyRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<CompanyModel>>> getActiveCompanies() async {
    try {
      final remoteData = await remoteDataSource.getActiveCompanies();
      return Right(remoteData);
    } on ServerException catch (e) {
      final int statusCode = e.statusCode ?? 500;
      switch (statusCode) {
        case 400:
          return Left(InvalidInputFailure(e.message));
        case 401:
          return Left(UnAuthorizedFailure(e.message));
        case 404:
          return Left(NotFoundFailure(e.message));
        default:
          return Left(ServerFailure(e.message, statusCode));
      }
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, CompanyModel>> getCompanyDetail(String companyId) async {
    try {
      final remoteData = await remoteDataSource.getCompanyDetail(companyId);
      return Right(remoteData);
    } on ServerException catch (e) {
      final int statusCode = e.statusCode ?? 500;
      switch (statusCode) {
        case 400:
          return Left(InvalidInputFailure(e.message));
        case 401:
          return Left(UnAuthorizedFailure(e.message));
        case 404:
          return Left(NotFoundFailure(e.message));
        default:
          return Left(ServerFailure(e.message, statusCode));
      }
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, PaginatedCompanyEntity>> searchCompanies(SearchRequest request) async {
    try {
      final remoteData = await remoteDataSource.searchCompanies(request);
      return Right(remoteData);
    } on ServerException catch (e) {
      final int statusCode = e.statusCode ?? 500;
      switch (statusCode) {
        case 400:
          return Left(InvalidInputFailure(e.message));
        case 401:
          return Left(UnAuthorizedFailure(e.message));
        case 404:
          return Left(NotFoundFailure(e.message));
        default:
          return Left(ServerFailure(e.message, statusCode));
      }
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, List<CompanyProjectModel>>> getProjectsByCompany(String companyId) async {
    try {
      final remoteData = await remoteDataSource.getProjectsByCompany(companyId);
      return Right(remoteData);
    } on ServerException catch (e) {
      final int statusCode = e.statusCode ?? 500;
      switch (statusCode) {
        case 400:
          return Left(InvalidInputFailure(e.message));
        case 401:
          return Left(UnAuthorizedFailure(e.message));
        case 404:
          return Left(NotFoundFailure(e.message));
        default:
          return Left(ServerFailure(e.message, statusCode));
      }
    } on NetworkException {
      return const Left(NetworkFailure());
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}