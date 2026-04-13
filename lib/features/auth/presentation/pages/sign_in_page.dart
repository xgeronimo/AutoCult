import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../app/router/app_router.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/auth_text_field.dart';

/// Страница авторизации
class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  
  bool _obscurePassword = true;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _onSignIn() {
    // Сбрасываем ошибки
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    // Валидация
    final emailError = Validators.email(_emailController.text);
    final passwordError = Validators.password(_passwordController.text);

    if (emailError != null || passwordError != null) {
      setState(() {
        _emailError = emailError;
        _passwordError = passwordError;
      });
      return;
    }

    // Отправляем событие авторизации
    context.read<AuthBloc>().add(AuthSignInRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            setState(() {
              // Показываем ошибку под соответствующим полем
              if (state.message.toLowerCase().contains('пароль')) {
                _passwordError = state.message;
              } else {
                _emailError = state.message;
              }
            });
          } else if (state is AuthAuthenticated) {
            context.go(AppRoutes.home);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w), // По дизайну: 20px
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 24.h),
                    
                    // Заголовок (по дизайну: SF Pro, 510, 32px)
                    Text(
                      'Авторизация',
                      style: TextStyle(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    
                    // Подзаголовок (по дизайну: SF Pro, 510, 14px, #888888)
                    Text(
                      'Введите вашу электронную почту и пароль для входа',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    
                    // Поле Email
                    AuthTextField(
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      label: 'Электронная почта',
                      hint: 'example@email.com',
                      errorText: _emailError,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      onChanged: (_) {
                        if (_emailError != null) {
                          setState(() => _emailError = null);
                        }
                      },
                      onSubmitted: (_) {
                        _passwordFocusNode.requestFocus();
                      },
                    ),
                    SizedBox(height: 16.h), // По дизайну: gap 16px
                    
                    // Поле Пароль
                    AuthTextField(
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      label: 'Пароль',
                      errorText: _passwordError,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onChanged: (_) {
                        if (_passwordError != null) {
                          setState(() => _passwordError = null);
                        }
                      },
                      onSubmitted: (_) => _onSignIn(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword 
                              ? Icons.visibility_outlined 
                              : Icons.visibility_off_outlined,
                          color: AppColors.textSecondaryLight,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    ),
                    SizedBox(height: 12.h),
                    
                    // Забыли пароль?
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () => context.push(AppRoutes.forgotPassword),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Забыли пароль?',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Кнопка Продолжить (по дизайну: высота 41px, radius 12px)
                    SizedBox(
                      width: double.infinity,
                      height: 41.h,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _onSignIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          textStyle: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: isLoading
                            ? SizedBox(
                                height: 20.h,
                                width: 20.h,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Продолжить'),
                      ),
                    ),
                    SizedBox(height: 8.h), // По дизайну: gap 8px
                    
                    // Кнопка Еще нет аккаунта? (по дизайну: серый #969696)
                    SizedBox(
                      width: double.infinity,
                      height: 41.h,
                      child: ElevatedButton(
                        onPressed: () => context.push(AppRoutes.signUp),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          textStyle: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text('Еще нет аккаунта?'),
                      ),
                    ),
                    SizedBox(height: 53.h), // Отступ до home indicator
                  ],
              ),
            ),
          );
        },
      ),
    );
  }
}
