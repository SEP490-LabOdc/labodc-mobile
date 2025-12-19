// lib/features/company/presentation/cubit/company_detail_state.dart

import 'package:equatable/equatable.dart';
import '../../data/models/company_model.dart';

abstract class CompanyDetailState extends Equatable {
  const CompanyDetailState();

  @override
  List<Object?> get props => [];
}

class CompanyDetailInitial extends CompanyDetailState {}

class CompanyDetailLoading extends CompanyDetailState {}

class CompanyDetailLoaded extends CompanyDetailState {
  final CompanyModel company;

  const CompanyDetailLoaded({required this.company});

  @override
  List<Object?> get props => [company];
}

class CompanyDetailError extends CompanyDetailState {
  final String message;

  const CompanyDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}