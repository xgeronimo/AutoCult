import 'package:equatable/equatable.dart';

enum PersonalDocumentType {
  driverLicense('Водительское удостоверение'),
  passport('Паспорт'),
  snils('СНИЛС'),
  inn('ИНН'),
  medicalCertificate('Медицинская справка'),
  other('Другое');

  final String label;
  const PersonalDocumentType(this.label);
}

class PersonalDocumentEntity extends Equatable {
  final String id;
  final String userId;
  final PersonalDocumentType type;
  final String? label;
  final String photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PersonalDocumentEntity({
    required this.id,
    required this.userId,
    required this.type,
    this.label,
    required this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  String get displayName => label ?? type.label;

  @override
  List<Object?> get props =>
      [id, userId, type, label, photoUrl, createdAt, updatedAt];
}
