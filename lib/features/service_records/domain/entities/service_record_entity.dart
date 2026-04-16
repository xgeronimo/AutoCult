import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum ServiceCategory {
  maintenance('Плановое ТО', Icons.build_outlined),
  repair('Ремонт', Icons.handyman_outlined),
  tires('Шины', Icons.tire_repair_outlined),
  bodywork('Кузовные работы', Icons.directions_car_outlined),
  electrical('Электрика', Icons.bolt_outlined),
  oil('Масло и жидкости', Icons.oil_barrel_outlined),
  brakes('Тормоза', Icons.do_not_disturb_on_outlined),
  suspension('Подвеска', Icons.settings_outlined),
  fuel('Заправка', Icons.local_gas_station_outlined),
  wash('Мойка', Icons.local_car_wash_outlined),
  insurance('Страховка', Icons.assignment_outlined),
  tax('Налог', Icons.payments_outlined),
  other('Прочее', Icons.edit_note_outlined);

  final String label;
  final IconData icon;
  const ServiceCategory(this.label, this.icon);
}

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

  bool get hasPhotos => photoUrls.isNotEmpty;

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
