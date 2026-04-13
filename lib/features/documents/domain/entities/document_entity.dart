import 'package:equatable/equatable.dart';

enum DocumentType {
  pts('ПТС'),
  sts('СТС'),
  insurance('Страховка'),
  driverLicense('Водительское удостоверение'),
  other('Другое');

  final String label;
  const DocumentType(this.label);
}

class DocumentEntity extends Equatable {
  final String id;
  final String carId;
  final String userId;
  final DocumentType type;
  final String? label;
  final String photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DocumentEntity({
    required this.id,
    required this.carId,
    required this.userId,
    required this.type,
    this.label,
    required this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  String get displayName => label ?? type.label;

  @override
  List<Object?> get props => [id, carId, userId, type, label, photoUrl, createdAt, updatedAt];
}
