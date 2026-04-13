import 'package:equatable/equatable.dart';

/// Категория обслуживания
enum ServiceCategory {
  maintenance('Плановое ТО', '🔧'),
  repair('Ремонт', '🛠'),
  tires('Шины', '🛞'),
  bodywork('Кузовные работы', '🚗'),
  electrical('Электрика', '⚡'),
  oil('Масло и жидкости', '🛢'),
  brakes('Тормоза', '🛑'),
  suspension('Подвеска', '🔩'),
  fuel('Заправка', '⛽'),
  wash('Мойка', '🧼'),
  insurance('Страховка', '📋'),
  tax('Налог', '💰'),
  other('Прочее', '📝');

  final String label;
  final String icon;
  const ServiceCategory(this.label, this.icon);
}

/// Сущность записи о ТО
class ServiceRecordEntity extends Equatable {
  final String id;
  final String carId;
  final String userId;
  final ServiceCategory category;
  final String title;
  final String? description;
  final DateTime date;
  final int mileage;
  final double? cost;
  final String? serviceStation;
  final List<String> photoUrls;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ServiceRecordEntity({
    required this.id,
    required this.carId,
    required this.userId,
    required this.category,
    required this.title,
    this.description,
    required this.date,
    required this.mileage,
    this.cost,
    this.serviceStation,
    this.photoUrls = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  /// Есть ли фотографии
  bool get hasPhotos => photoUrls.isNotEmpty;

  /// Количество фотографий
  int get photosCount => photoUrls.length;

  @override
  List<Object?> get props => [
        id,
        carId,
        userId,
        category,
        title,
        description,
        date,
        mileage,
        cost,
        serviceStation,
        photoUrls,
        createdAt,
        updatedAt,
      ];
}
