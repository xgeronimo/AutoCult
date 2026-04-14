import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/sign_in_page.dart';
import '../../features/auth/presentation/pages/sign_up_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/home/presentation/pages/main_tabs_page.dart';
import '../../features/garage/presentation/pages/add_car_page.dart';
import '../../features/garage/presentation/pages/car_details_page.dart';
import '../../features/garage/presentation/pages/edit_car_page.dart';
import '../../features/garage/presentation/bloc/garage_bloc.dart';
import '../../features/garage/domain/entities/car_entity.dart';
import '../../features/expenses/presentation/pages/add_expense_page.dart';
import '../../features/expenses/presentation/pages/expenses_page.dart';
import '../../features/expenses/domain/entities/expense_entity.dart';
import '../../features/service_records/presentation/pages/add_service_record_page.dart';
import '../../features/service_records/presentation/pages/edit_service_record_page.dart';
import '../../features/service_records/presentation/pages/report_selection_page.dart';
import '../../features/service_records/presentation/pages/service_record_details_page.dart';
import '../../features/service_records/domain/entities/service_record_entity.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/change_password_page.dart';
import '../../features/profile/presentation/pages/settings_page.dart';
import '../../features/profile/presentation/pages/notifications_page.dart' as profile_notifications;
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/notifications/presentation/pages/create_reminder_page.dart';
import '../../features/personal_documents/presentation/pages/personal_documents_page.dart';
import '../../features/auth/domain/entities/user_entity.dart' as auth_entity;

/// Пути роутинга
class AppRoutes {
  AppRoutes._();

  // Auth
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String forgotPassword = '/forgot-password';

  // Main
  static const String home = '/';
  static const String garage = '/garage';
  static const String addCar = '/garage/add';
  static const String carDetails = '/garage/:carId';
  static const String editCar = '/garage/:carId/edit';

  // Service Records
  static const String serviceRecords = '/garage/:carId/records';
  static const String addServiceRecord = '/garage/:carId/records/add';
  static const String serviceRecordDetails = '/garage/:carId/records/:recordId';
  static const String editServiceRecord = '/garage/:carId/records/:recordId/edit';
  static const String serviceReport = '/garage/:carId/report';

  // Expenses
  static const String expenses = '/garage/:carId/expenses';
  static const String addExpense = '/garage/:carId/expenses/add';

  // Profile
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String personalDocuments = '/profile/documents';
  static const String notifications = '/profile/notifications';
  static const String createReminder = '/profile/notifications/create';
  static const String notificationSettings = '/profile/notification-settings';
  static const String settings = '/profile/settings';
  static const String changePassword = '/profile/settings/change-password';

  // Statistics
  static const String statistics = '/statistics';
}

/// Конфигурация роутера
class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter get router => _router;

  static CarEntity? _getCarFromState(BuildContext context, String carId) {
    final garageState = context.read<GarageBloc>().state;
    if (garageState is GarageLoaded) {
      try {
        return garageState.cars.firstWhere((c) => c.id == carId);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static CarEntity _carNotFoundFallback(BuildContext context) {
    return CarEntity(
      id: '',
      userId: '',
      brand: 'Не найден',
      model: '',
      year: 0,
      mileage: 0,
      fuelType: FuelType.petrol,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  static final GoRouter _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.signIn,
    debugLogDiagnostics: false,

    redirect: (context, state) {
      final authBloc = context.read<AuthBloc>();
      final authState = authBloc.state;
      final isAuthenticated = authState is AuthAuthenticated;
      final isLoading = authState is AuthLoading || authState is AuthInitial;

      final isAuthRoute = state.matchedLocation == AppRoutes.signIn ||
          state.matchedLocation == AppRoutes.signUp ||
          state.matchedLocation == AppRoutes.forgotPassword;

      if (isLoading) {
        return null;
      }

      if (!isAuthenticated && !isAuthRoute) {
        return AppRoutes.signIn;
      }

      if (isAuthenticated && isAuthRoute) {
        return AppRoutes.home;
      }

      return null;
    },

    routes: [
      // ==================== Auth Routes ====================
      GoRoute(
        path: AppRoutes.signIn,
        name: 'signIn',
        builder: (context, state) => const SignInPage(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        name: 'signUp',
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordPage(),
      ),

      // ==================== Main Tabs ====================
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const MainTabsPage(),
      ),

      // ==================== Garage Routes ====================
      GoRoute(
        path: AppRoutes.garage,
        name: 'garage',
        builder: (context, state) => const MainTabsPage(),
      ),

      // Add Car — отдельный top-level маршрут, без конфликта с :carId
      GoRoute(
        path: AppRoutes.addCar,
        name: 'addCar',
        builder: (context, state) => const AddCarPage(),
      ),

      // Car Details Route
      GoRoute(
        path: '/garage/:carId',
        name: 'carDetails',
        builder: (context, state) {
          final carId = state.pathParameters['carId'] ?? '';
          final car = _getCarFromState(context, carId);

          if (car == null) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text('Автомобиль не найден'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.go(AppRoutes.garage),
                      child: const Text('В гараж'),
                    ),
                  ],
                ),
              ),
            );
          }

          return CarDetailsPage(car: car);
        },
        routes: [
          GoRoute(
            path: 'edit',
            name: 'editCar',
            builder: (context, state) {
              final carId = state.pathParameters['carId'] ?? '';
              final car = _getCarFromState(context, carId);
              if (car == null) {
                return Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        const Text('Автомобиль не найден'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context.go(AppRoutes.garage),
                          child: const Text('В гараж'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return EditCarPage(car: car);
            },
          ),
          GoRoute(
            path: 'records',
            name: 'serviceRecords',
            builder: (context, state) {
              final carId = state.pathParameters['carId'] ?? '';
              return CarDetailsPage(
                car: _getCarFromState(context, carId) ??
                    _carNotFoundFallback(context),
              );
            },
            routes: [
              GoRoute(
                path: 'add',
                name: 'addServiceRecord',
                builder: (context, state) {
                  final carId = state.pathParameters['carId'] ?? '';
                  return AddServiceRecordPage(carId: carId);
                },
              ),
              GoRoute(
                path: ':recordId',
                name: 'serviceRecordDetails',
                builder: (context, state) {
                  final carId = state.pathParameters['carId'] ?? '';
                  final recordId = state.pathParameters['recordId'] ?? '';
                  return ServiceRecordDetailsPage(
                    carId: carId,
                    recordId: recordId,
                  );
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: 'editServiceRecord',
                    builder: (context, state) {
                      final carId = state.pathParameters['carId'] ?? '';
                      final record = state.extra as ServiceRecordEntity?;
                      if (record == null) {
                        return Scaffold(
                          body: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline,
                                    size: 64, color: Colors.red),
                                const SizedBox(height: 16),
                                const Text('Запись не найдена'),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => context.go(AppRoutes.home),
                                  child: const Text('На главную'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return EditServiceRecordPage(
                        carId: carId,
                        record: record,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: 'report',
            name: 'serviceReport',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>;
              return ReportSelectionPage(
                car: extra['car'] as CarEntity,
                records:
                    extra['records'] as List<ServiceRecordEntity>,
              );
            },
          ),
          GoRoute(
            path: 'expenses',
            name: 'expenses',
            builder: (context, state) {
              final carId = state.pathParameters['carId'] ?? '';
              return ExpensesPage(carId: carId);
            },
            routes: [
              GoRoute(
                path: 'add',
                name: 'addExpense',
                builder: (context, state) {
                  final carId = state.pathParameters['carId'] ?? '';
                  final categoryParam = state.uri.queryParameters['category'];

                  ExpenseCategory? category;
                  if (categoryParam != null) {
                    category = ExpenseCategory.values
                        .where((c) => c.name == categoryParam)
                        .firstOrNull;
                  }

                  return AddExpensePage(
                    carId: carId,
                    initialCategory: category,
                  );
                },
              ),
            ],
          ),
        ],
      ),

      // ==================== Profile Routes ====================
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
        routes: [
          GoRoute(
            path: 'edit',
            name: 'editProfile',
            builder: (context, state) {
              final user = state.extra as auth_entity.UserEntity?;
              if (user == null) {
                return const Scaffold(
                  body: Center(child: Text('Пользователь не найден')),
                );
              }
              return EditProfilePage(user: user);
            },
          ),
          GoRoute(
            path: 'documents',
            name: 'personalDocuments',
            builder: (context, state) => const PersonalDocumentsPage(),
          ),
          GoRoute(
            path: 'notifications',
            name: 'notifications',
            builder: (context, state) => const NotificationsPage(),
            routes: [
              GoRoute(
                path: 'create',
                name: 'createReminder',
                builder: (context, state) => const CreateReminderPage(),
              ),
            ],
          ),
          GoRoute(
            path: 'notification-settings',
            name: 'notificationSettings',
            builder: (context, state) =>
                const profile_notifications.NotificationsPage(),
          ),
          GoRoute(
            path: 'settings',
            name: 'settings',
            builder: (context, state) => const SettingsPage(),
            routes: [
              GoRoute(
                path: 'change-password',
                name: 'changePassword',
                builder: (context, state) => const ChangePasswordPage(),
              ),
            ],
          ),
        ],
      ),

      // ==================== Statistics Route ====================
      GoRoute(
        path: AppRoutes.statistics,
        name: 'statistics',
        builder: (context, state) => const MainTabsPage(),
      ),
    ],

    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Страница не найдена: ${state.matchedLocation}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('На главную'),
            ),
          ],
        ),
      ),
    ),
  );
}
