import '../../domain/entities/service_record_entity.dart';

/// Модель записи ТО для работы с Firebase
class ServiceRecordModel extends ServiceRecordEntity {
  const ServiceRecordModel({
    required super.id,
    required super.carId,
    required super.userId,
    required super.category,
    required super.title,
    super.description,
    required super.date,
    required super.mileage,
    super.cost,
    super.serviceStation,
    super.photoUrls,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Создание из JSON (Firestore)
  factory ServiceRecordModel.fromJson(Map<String, dynamic> json) {
    return ServiceRecordModel(
      id: json['id'] as String,
      carId: json['carId'] as String,
      userId: json['userId'] as String,
      category: ServiceCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => ServiceCategory.other,
      ),
      title: json['title'] as String,
      description: json['description'] as String?,
      date: DateTime.parse(json['date'] as String),
      mileage: json['mileage'] as int,
      cost: (json['cost'] as num?)?.toDouble(),
      serviceStation: json['serviceStation'] as String?,
      photoUrls: (json['photoUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Преобразование в JSON (Firestore)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'carId': carId,
      'userId': userId,
      'category': category.name,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'mileage': mileage,
      'cost': cost,
      'serviceStation': serviceStation,
      'photoUrls': photoUrls,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Создание из Entity
  factory ServiceRecordModel.fromEntity(ServiceRecordEntity entity) {
    return ServiceRecordModel(
      id: entity.id,
      carId: entity.carId,
      userId: entity.userId,
      category: entity.category,
      title: entity.title,
      description: entity.description,
      date: entity.date,
      mileage: entity.mileage,
      cost: entity.cost,
      serviceStation: entity.serviceStation,
      photoUrls: entity.photoUrls,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Копирование с изменениями
  ServiceRecordModel copyWith({
    String? id,
    String? carId,
    String? userId,
    ServiceCategory? category,
    String? title,
    String? description,
    DateTime? date,
    int? mileage,
    double? cost,
    String? serviceStation,
    List<String>? photoUrls,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceRecordModel(
      id: id ?? this.id,
      carId: carId ?? this.carId,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      mileage: mileage ?? this.mileage,
      cost: cost ?? this.cost,
      serviceStation: serviceStation ?? this.serviceStation,
      photoUrls: photoUrls ?? this.photoUrls,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
