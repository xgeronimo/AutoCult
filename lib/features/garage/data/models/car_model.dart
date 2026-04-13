import '../../domain/entities/car_entity.dart';

/// Модель автомобиля для работы с Firebase
class CarModel extends CarEntity {
  const CarModel({
    required super.id,
    required super.userId,
    required super.brand,
    required super.model,
    required super.year,
    super.vin,
    super.licensePlate,
    required super.mileage,
    required super.fuelType,
    super.engineVolume,
    super.transmission,
    super.color,
    super.photoUrl,
    super.description,
    super.isFormer,
    super.bodyType,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Создание из JSON (Firestore)
  factory CarModel.fromJson(Map<String, dynamic> json) {
    return CarModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      brand: json['brand'] as String,
      model: json['model'] as String,
      year: json['year'] as int,
      vin: json['vin'] as String?,
      licensePlate: json['licensePlate'] as String?,
      mileage: json['mileage'] as int,
      fuelType: FuelType.values.firstWhere(
        (e) => e.name == json['fuelType'],
        orElse: () => FuelType.petrol,
      ),
      engineVolume: (json['engineVolume'] as num?)?.toDouble(),
      transmission: json['transmission'] != null
          ? TransmissionType.values.firstWhere(
              (e) => e.name == json['transmission'],
              orElse: () => TransmissionType.automatic,
            )
          : null,
      color: json['color'] as String?,
      photoUrl: json['photoUrl'] as String?,
      description: json['description'] as String?,
      isFormer: json['isFormer'] as bool? ?? false,
      bodyType: json['bodyType'] != null
          ? BodyType.values.firstWhere(
              (e) => e.name == json['bodyType'],
              orElse: () => BodyType.sedan,
            )
          : BodyType.sedan,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Преобразование в JSON (Firestore)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'brand': brand,
      'model': model,
      'year': year,
      'vin': vin,
      'licensePlate': licensePlate,
      'mileage': mileage,
      'fuelType': fuelType.name,
      'engineVolume': engineVolume,
      'transmission': transmission?.name,
      'color': color,
      'photoUrl': photoUrl,
      'description': description,
      'isFormer': isFormer,
      'bodyType': bodyType.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Создание из CarEntity
  factory CarModel.fromEntity(CarEntity entity) {
    return CarModel(
      id: entity.id,
      userId: entity.userId,
      brand: entity.brand,
      model: entity.model,
      year: entity.year,
      vin: entity.vin,
      licensePlate: entity.licensePlate,
      mileage: entity.mileage,
      fuelType: entity.fuelType,
      engineVolume: entity.engineVolume,
      transmission: entity.transmission,
      color: entity.color,
      photoUrl: entity.photoUrl,
      description: entity.description,
      isFormer: entity.isFormer,
      bodyType: entity.bodyType,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  @override
  CarModel copyWith({
    String? id,
    String? userId,
    String? brand,
    String? model,
    int? year,
    String? Function()? vin,
    String? Function()? licensePlate,
    int? mileage,
    FuelType? fuelType,
    double? Function()? engineVolume,
    TransmissionType? Function()? transmission,
    String? Function()? color,
    String? Function()? photoUrl,
    String? Function()? description,
    bool? isFormer,
    BodyType? bodyType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CarModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      vin: vin != null ? vin() : this.vin,
      licensePlate: licensePlate != null ? licensePlate() : this.licensePlate,
      mileage: mileage ?? this.mileage,
      fuelType: fuelType ?? this.fuelType,
      engineVolume: engineVolume != null ? engineVolume() : this.engineVolume,
      transmission: transmission != null ? transmission() : this.transmission,
      color: color != null ? color() : this.color,
      photoUrl: photoUrl != null ? photoUrl() : this.photoUrl,
      description: description != null ? description() : this.description,
      isFormer: isFormer ?? this.isFormer,
      bodyType: bodyType ?? this.bodyType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
