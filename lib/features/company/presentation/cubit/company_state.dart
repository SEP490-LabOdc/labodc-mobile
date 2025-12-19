// lib/features/company/presentation/cubit/company_state.dart

import 'package:equatable/equatable.dart';
import '../../data/models/company_model.dart';

abstract class CompanyState extends Equatable {
  const CompanyState();

  @override
  List<Object?> get props => [];
}

class CompanyInitial extends CompanyState {}

class CompanyLoading extends CompanyState {}

class CompanyLoaded extends CompanyState {
  final List<CompanyModel> companies;

  const CompanyLoaded({required this.companies});

  @override
  List<Object?> get props => [companies];
}

class CompanyError extends CompanyState {
  final String message;

  const CompanyError({required this.message});

  @override
  List<Object?> get props => [message];
}