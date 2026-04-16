import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/theme/app_theme.dart';
import '../core/constants/app_strings.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/garage/presentation/bloc/garage_bloc.dart';
import '../features/notifications/presentation/bloc/notifications_bloc.dart';
import '../features/profile/presentation/bloc/profile_bloc.dart';
import '../features/statistics/presentation/bloc/statistics_bloc.dart';
import '../injection_container.dart';
import 'router/app_router.dart';

class AutoCultApp extends StatelessWidget {
  const AutoCultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>()..add(const AuthCheckRequested()),
        ),
        BlocProvider<GarageBloc>(
          create: (_) => sl<GarageBloc>(),
        ),
        BlocProvider<ProfileBloc>(
          create: (_) => sl<ProfileBloc>(),
        ),
        BlocProvider<NotificationsBloc>(
          create: (_) => sl<NotificationsBloc>(),
        ),
        BlocProvider<StatisticsBloc>(
          create: (_) => sl<StatisticsBloc>(),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthAuthenticated) {
                final garageBloc = context.read<GarageBloc>();
                garageBloc.setUserId(state.user.id);
                garageBloc.add(const GarageLoadCars());

                context.read<NotificationsBloc>().add(
                      NotificationsLoadRequested(state.user.id),
                    );
              }
            },
            child: BlocBuilder<AuthBloc, AuthState>(
              buildWhen: (previous, current) {
                return previous.runtimeType != current.runtimeType;
              },
              builder: (context, state) {
                return MaterialApp.router(
                  title: AppStrings.appName,
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.light,
                  darkTheme: AppTheme.dark,
                  themeMode: ThemeMode.system,
                  locale: const Locale('ru', 'RU'),
                  supportedLocales: const [
                    Locale('ru', 'RU'),
                    Locale('en', 'US'),
                  ],
                  localizationsDelegates: const [
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  routerConfig: AppRouter.router,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
