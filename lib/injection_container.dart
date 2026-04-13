import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

// Core
import 'core/network/network_info.dart';
import 'core/services/image_picker_service.dart';
import 'core/services/image_storage_service.dart';

// Auth
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/sign_in_usecase.dart';
import 'features/auth/domain/usecases/sign_up_usecase.dart';
import 'features/auth/domain/usecases/sign_out_usecase.dart';
import 'features/auth/domain/usecases/get_current_user_usecase.dart';
import 'features/auth/domain/usecases/reset_password_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

// Garage
import 'features/garage/data/datasources/car_remote_datasource.dart';
import 'features/garage/data/repositories/car_repository_impl.dart';
import 'features/garage/domain/repositories/car_repository.dart';
import 'features/garage/domain/usecases/get_cars_usecase.dart';
import 'features/garage/domain/usecases/add_car_usecase.dart';
import 'features/garage/domain/usecases/update_car_usecase.dart';
import 'features/garage/domain/usecases/delete_car_usecase.dart';
import 'features/garage/presentation/bloc/garage_bloc.dart';

// Service Records
import 'features/service_records/data/datasources/service_record_remote_datasource.dart';
import 'features/service_records/data/repositories/service_record_repository_impl.dart';
import 'features/service_records/domain/repositories/service_record_repository.dart';
import 'features/service_records/domain/usecases/get_records_usecase.dart';
import 'features/service_records/domain/usecases/add_record_usecase.dart';
import 'features/service_records/domain/usecases/update_record_usecase.dart';
import 'features/service_records/domain/usecases/delete_record_usecase.dart';
import 'features/service_records/presentation/bloc/service_records_bloc.dart';

// Documents
import 'features/documents/data/datasources/document_remote_datasource.dart';
import 'features/documents/data/repositories/document_repository_impl.dart';
import 'features/documents/domain/repositories/document_repository.dart';
import 'features/documents/presentation/bloc/documents_bloc.dart';

// Profile
import 'features/auth/domain/usecases/update_profile_usecase.dart';
import 'features/auth/domain/usecases/change_password_usecase.dart';
import 'features/auth/domain/usecases/delete_account_usecase.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';

// Personal Documents
import 'features/personal_documents/data/datasources/personal_document_remote_datasource.dart';
import 'features/personal_documents/data/repositories/personal_document_repository_impl.dart';
import 'features/personal_documents/domain/repositories/personal_document_repository.dart';
import 'features/personal_documents/presentation/bloc/personal_documents_bloc.dart';

// Expenses
import 'features/expenses/data/datasources/expense_remote_datasource.dart';
import 'features/expenses/data/repositories/expense_repository_impl.dart';
import 'features/expenses/domain/repositories/expense_repository.dart';
import 'features/expenses/presentation/bloc/expenses_bloc.dart';

// Statistics
import 'features/statistics/presentation/bloc/statistics_bloc.dart';

// Notifications
import 'core/services/notification_service.dart';
import 'features/notifications/data/datasources/reminder_remote_datasource.dart';
import 'features/notifications/data/repositories/reminder_repository_impl.dart';
import 'features/notifications/domain/repositories/reminder_repository.dart';
import 'features/notifications/presentation/bloc/notifications_bloc.dart';

/// Глобальный Service Locator
final sl = GetIt.instance;

/// Инициализация всех зависимостей
Future<void> initDependencies() async {
  // ==================== External ====================
  
  // Firebase
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  sl.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);
  
  // Network
  sl.registerLazySingleton<InternetConnectionChecker>(
    () => InternetConnectionChecker(),
  );

  // ==================== Core ====================
  
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl()),
  );

  sl.registerLazySingleton<ImagePickerService>(
    () => ImagePickerService(),
  );

  sl.registerLazySingleton<ImageStorageService>(
    () => ImageStorageService(storage: sl()),
  );

  // ==================== Auth ====================
  
  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl(),
      firestore: sl(),
    ),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));

  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => ChangePasswordUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAccountUseCase(sl()));

  // BLoC
  sl.registerFactory(
    () => AuthBloc(
      signInUseCase: sl(),
      signUpUseCase: sl(),
      signOutUseCase: sl(),
      getCurrentUserUseCase: sl(),
      resetPasswordUseCase: sl(),
      authRepository: sl(),
    ),
  );

  // ==================== Profile ====================

  sl.registerFactory(
    () => ProfileBloc(
      updateProfileUseCase: sl(),
      changePasswordUseCase: sl(),
      deleteAccountUseCase: sl(),
      imageStorageService: sl(),
    ),
  );

  // ==================== Garage ====================
  
  // Data Sources
  sl.registerLazySingleton<CarRemoteDataSource>(
    () => CarRemoteDataSourceImpl(firestore: sl(), storage: sl()),
  );

  // Repositories
  sl.registerLazySingleton<CarRepository>(
    () => CarRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetCarsUseCase(sl()));
  sl.registerLazySingleton(() => AddCarUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCarUseCase(sl()));
  sl.registerLazySingleton(() => DeleteCarUseCase(sl()));

  // BLoC
  sl.registerFactory(
    () => GarageBloc(
      getCarsUseCase: sl(),
      addCarUseCase: sl(),
      updateCarUseCase: sl(),
      deleteCarUseCase: sl(),
      imageStorageService: sl(),
    ),
  );

  // ==================== Service Records ====================
  
  // Data Sources
  sl.registerLazySingleton<ServiceRecordRemoteDataSource>(
    () => ServiceRecordRemoteDataSourceImpl(firestore: sl()),
  );

  // Repositories
  sl.registerLazySingleton<ServiceRecordRepository>(
    () => ServiceRecordRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetRecordsUseCase(sl()));
  sl.registerLazySingleton(() => AddRecordUseCase(sl()));
  sl.registerLazySingleton(() => UpdateRecordUseCase(sl()));
  sl.registerLazySingleton(() => DeleteRecordUseCase(sl()));

  // BLoC
  sl.registerFactory(
    () => ServiceRecordsBloc(
      getRecordsUseCase: sl(),
      addRecordUseCase: sl(),
      updateRecordUseCase: sl(),
      deleteRecordUseCase: sl(),
      imageStorageService: sl(),
    ),
  );

  // ==================== Documents ====================
  
  // Data Sources
  sl.registerLazySingleton<DocumentRemoteDataSource>(
    () => DocumentRemoteDataSourceImpl(firestore: sl()),
  );

  // Repositories
  sl.registerLazySingleton<DocumentRepository>(
    () => DocumentRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // BLoC
  sl.registerFactory(
    () => DocumentsBloc(
      repository: sl(),
      imageStorageService: sl(),
    ),
  );

  // ==================== Personal Documents ====================

  // Data Sources
  sl.registerLazySingleton<PersonalDocumentRemoteDataSource>(
    () => PersonalDocumentRemoteDataSourceImpl(firestore: sl()),
  );

  // Repositories
  sl.registerLazySingleton<PersonalDocumentRepository>(
    () => PersonalDocumentRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // BLoC
  sl.registerFactory(
    () => PersonalDocumentsBloc(
      repository: sl(),
      imageStorageService: sl(),
    ),
  );

  // ==================== Expenses ====================
  
  // Data Sources
  sl.registerLazySingleton<ExpenseRemoteDataSource>(
    () => ExpenseRemoteDataSourceImpl(firestore: sl()),
  );

  // Repositories
  sl.registerLazySingleton<ExpenseRepository>(
    () => ExpenseRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // BLoC
  sl.registerFactory(
    () => ExpensesBloc(repository: sl()),
  );

  // ==================== Statistics ====================

  sl.registerFactory(
    () => StatisticsBloc(
      expenseRepository: sl(),
      serviceRecordRepository: sl(),
    ),
  );

  // ==================== Notifications ====================

  // Services
  sl.registerLazySingleton<NotificationService>(
    () => NotificationService(),
  );

  // Data Sources
  sl.registerLazySingleton<ReminderRemoteDataSource>(
    () => ReminderRemoteDataSourceImpl(firestore: sl()),
  );

  // Repositories
  sl.registerLazySingleton<ReminderRepository>(
    () => ReminderRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // BLoC
  sl.registerFactory(
    () => NotificationsBloc(
      repository: sl(),
      notificationService: sl(),
    ),
  );
}
