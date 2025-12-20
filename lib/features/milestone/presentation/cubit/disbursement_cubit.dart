import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/milestone_repository.dart';
import '../../data/models/milestone_disbursement_model.dart';

abstract class DisbursementState {}

class DisbursementInitial extends DisbursementState {}
class DisbursementLoading extends DisbursementState {}
class DisbursementLoaded extends DisbursementState {
  final MilestoneDisbursementModel disbursement;
  DisbursementLoaded(this.disbursement);
}
class DisbursementFailure extends DisbursementState {
  final String message;
  final bool isBusinessError;
  DisbursementFailure(this.message, {this.isBusinessError = false});
}

class DisbursementCubit extends Cubit<DisbursementState> {
  final MilestoneRepository repository;

  DisbursementCubit({required this.repository}) : super(DisbursementInitial());

  Future<void> fetchDisbursement(String milestoneId) async {
    emit(DisbursementLoading());
    final result = await repository.getMilestoneDisbursement(milestoneId);

    result.fold(
          (failure) {
        bool isBusiness = failure.message.contains("Chưa có thông tin giải ngân");
        emit(DisbursementFailure(failure.message, isBusinessError: isBusiness));
      },
          (data) => emit(DisbursementLoaded(data)),
    );
  }
}