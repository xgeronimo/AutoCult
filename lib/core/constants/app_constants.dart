class AppConstants {
  AppConstants._();

  static const String appName = 'AutoCult';

  static const String appVersion = '1.0.0';

  static const int maxCarsInGarage = 10;

  static const int maxImageSize = 5 * 1024 * 1024;

  static const List<String> supportedImageFormats = [
    'jpg',
    'jpeg',
    'png',
    'webp'
  ];

  static const int vinLength = 17;

  static final RegExp licensePlateRegex = RegExp(
    r'^[АВЕКМНОРСТУХ]\d{3}[АВЕКМНОРСТУХ]{2}\d{2,3}$',
    caseSensitive: false,
  );
}

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

class StoragePaths {
  StoragePaths._();

  static const String userAvatars = 'avatars';
  static const String carPhotos = 'car_photos';
  static const String servicePhotos = 'service_photos';
  static const String documents = 'documents';
}
