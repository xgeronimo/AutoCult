/// Константы приложения
class AppConstants {
  AppConstants._();

  /// Название приложения
  static const String appName = 'AutoCult';
  
  /// Версия приложения
  static const String appVersion = '1.0.0';
  
  /// Максимальное количество автомобилей в гараже
  static const int maxCarsInGarage = 10;
  
  /// Максимальный размер изображения (в байтах) — 5MB
  static const int maxImageSize = 5 * 1024 * 1024;
  
  /// Поддерживаемые форматы изображений
  static const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png', 'webp'];
  
  /// Длина VIN кода
  static const int vinLength = 17;
  
  /// Регулярное выражение для проверки ГРЗ (российский формат)
  static final RegExp licensePlateRegex = RegExp(
    r'^[АВЕКМНОРСТУХ]\d{3}[АВЕКМНОРСТУХ]{2}\d{2,3}$',
    caseSensitive: false,
  );
}

/// Константы Firebase коллекций
class FirestoreCollections {
  FirestoreCollections._();

  static const String users = 'users';
  static const String cars = 'cars';
  static const String serviceRecords = 'service_records';
  static const String reminders = 'reminders';
  static const String expenses = 'expenses';
  static const String documents = 'documents';
  static const String personalDocuments = 'personal_documents';
}

/// Константы Firebase Storage
class StoragePaths {
  StoragePaths._();

  static const String userAvatars = 'avatars';
  static const String carPhotos = 'car_photos';
  static const String servicePhotos = 'service_photos';
  static const String documents = 'documents';
}
