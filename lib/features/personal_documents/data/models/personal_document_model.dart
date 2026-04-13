import '../../domain/entities/personal_document_entity.dart';

class PersonalDocumentModel extends PersonalDocumentEntity {
  const PersonalDocumentModel({
    required super.id,
    required super.userId,
    required super.type,
    super.label,
    required super.photoUrl,
    required super.createdAt,
    required super.updatedAt,
  });

  factory PersonalDocumentModel.fromJson(Map<String, dynamic> json) {
    return PersonalDocumentModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: PersonalDocumentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PersonalDocumentType.other,
      ),
      label: json['label'] as String?,
      photoUrl: json['photoUrl'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.name,
      'label': label,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory PersonalDocumentModel.fromEntity(PersonalDocumentEntity entity) {
    return PersonalDocumentModel(
      id: entity.id,
      userId: entity.userId,
      type: entity.type,
      label: entity.label,
      photoUrl: entity.photoUrl,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
