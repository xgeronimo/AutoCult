import 'package:equatable/equatable.dart';

enum FuelType {
  petrol('Бензин'),
  diesel('Дизель'),
  electric('Электро'),
  hybrid('Гибрид'),
  gas('Газ');

  final String label;
  const FuelType(this.label);
}

enum TransmissionType {
  manual('Механика'),
  automatic('Автомат'),
  robot('Робот'),
  variator('Вариатор');

  final String label;
  const TransmissionType(this.label);
}

enum BodyType {
  sedan('Легковой'),
  suv('Кроссовер');

  final String label;
  const BodyType(this.label);

  String get imagePath {
    switch (this) {
      case BodyType.sedan:
        return 'assets/images/sedan.png';
      case BodyType.suv:
        return 'assets/images/SUV.png';
    }
  }
}

class CarEntity extends Equatable {
  final String id;
  final String userId;
  final String brand;
  final String model;
  final int year;
  final String? vin;
  final String? licensePlate;
  final int mileage;
  final FuelType fuelType;
  final double? engineVolume;
  final TransmissionType? transmission;
  final String? color;
  final String? photoUrl;
  final String? description;
  final bool isFormer;
  final BodyType bodyType;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CarEntity({
    required this.id,
    required this.userId,
    required this.brand,
    required this.model,
    required this.year,
    this.vin,
    this.licensePlate,
    required this.mileage,
    required this.fuelType,
    this.engineVolume,
    this.transmission,
    this.color,
    this.photoUrl,
    this.description,
    this.isFormer = false,
    this.bodyType = BodyType.sedan,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$brand $model';

  String get fullNameWithYear => '$brand $model, $year';

  CarEntity copyWith({
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
    return CarEntity(
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

  String get shortDescription {
    final parts = <String>[];
    parts.add('$year г.');
    if (engineVolume != null) {
      parts.add('${engineVolume!.toStringAsFixed(1)} л');
    }
    parts.add(fuelType.label);
    if (transmission != null) {
      parts.add(transmission!.label);
    }
    return parts.join(' • ');
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        brand,
        model,
        year,
        vin,
        licensePlate,
        mileage,
        fuelType,
        engineVolume,
        transmission,
        color,
        photoUrl,
        description,
        isFormer,
        bodyType,
        createdAt,
        updatedAt,
      ];
}
