import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../data/models/milestone_detail_model.dart';
import '../../data/models/milestone_disbursement_model.dart';
import '../../data/models/milestone_document_model.dart';
import '../../data/models/milestone_member_model.dart';
import '../../data/models/milestone_wallet_model.dart';
import '../../data/models/project_milestone_model.dart';

abstract class MilestoneRepository {
  Future<Either<Failure, List<ProjectMilestoneModel>>> getMilestones(
    String projectId,
  );
  Future<Either<Failure, MilestoneDetailModel>> getMilestoneDetail(
    String milestoneId,
  );
  Future<Either<Failure, List<MilestoneDocumentModel>>> getMilestoneDocuments(
    String milestoneId,
  );
  Future<Either<Failure, MilestoneDisbursementModel>> getMilestoneDisbursement(
    String milestoneId,
    double totalAmount,
  );

  // New methods for paid milestones feature
  Future<Either<Failure, List<ProjectMilestoneModel>>> getPaidMilestones(
    String projectId,
  );
  Future<Either<Failure, List<MilestoneMemberModel>>> getMilestoneMembersByRole(
    String milestoneId,
    String role,
  );
  Future<Either<Failure, MilestoneWalletModel?>> getMilestoneWallet(
    String milestoneId,
  );
}
