import 'package:equatable/equatable.dart';

class CompanyEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? taxCode;
  final String address;
  final String? description;
  final String? website;
  final String status;
  final String? domain;
  final String? userId;
  final String? contactPersonName;
  final String? contactPersonEmail;
  final String? contactPersonPhone;
  final String? createdAt;
  final String? logoUrl;

  const CompanyEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.taxCode,
    required this.address,
    required this.status,
    this.description,
    this.website,
    this.domain,
    this.userId,
    this.contactPersonName,
    this.contactPersonEmail,
    this.contactPersonPhone,
    this.createdAt,
    this.logoUrl,
  });

  @override
  List<Object?> get props => [
    id, name, email, phone, taxCode, address, status, description,
    website, domain, userId, contactPersonName, contactPersonEmail,
    contactPersonPhone, createdAt, logoUrl
  ];
}