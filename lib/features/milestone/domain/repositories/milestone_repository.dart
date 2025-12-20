

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../data/models/milestone_detail_model.dart';
import '../../data/models/milestone_disbursement_model.dart';
import '../../data/models/milestone_document_model.dart';
import '../../data/models/project_milestone_model.dart';

abstract class MilestoneRepository {
  Future<Either<Failure, List<ProjectMilestoneModel>>> getMilestones(String projectId);
  Future<Either<Failure, MilestoneDetailModel>> getMilestoneDetail(String milestoneId);
  Future<Either<Failure, List<MilestoneDocumentModel>>> getMilestoneDocuments(String milestoneId);
  Future<Either<Failure, MilestoneDisbursementModel>> getMilestoneDisbursement(String milestoneId);
}