import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../app/router/app_router.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/welcome_dialog.dart';

/// Страница регистрации
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _onSignUp() {
    // Сбрасываем ошибки
    setState(() {
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });

    // Валидация
    final emailError = Validators.email(_emailController.text);
    final passwordError = Validators.password(_passwordController.text);
    final confirmPasswordError = Validators.confirmPassword(
      _passwordController.text,
    )(_confirmPasswordController.text);

    if (emailError != null || passwordError != null || confirmPasswordError != null) {
      setState(() {
        _emailError = emailError;
        _passwordError = passwordError;
        _confirmPasswordError = confirmPasswordError;
      });
      return;
    }

    // Отправляем событие регистрации
    context.read<AuthBloc>().add(AuthSignUpRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ));
  }

  void _showWelcomeDialog() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.modalOverlay,
      isScrollControlled: true,
      builder: (_) => WelcomeDialog(
        onContinue: () {
          Navigator.of(context).pop();
          context.go(AppRoutes.home);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            setState(() {
              if (state.message.toLowerCase().contains('email') ||
                  state.message.toLowerCase().contains('почта')) {
                _emailError = state.message;
              } else if (state.message.toLowerCase().contains('пароль')) {
                _passwordError = state.message;
              } else {
                _emailError = state.message;
              }
            });
          } else if (state is AuthAuthenticated) {
            _showWelcomeDialog();
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
                    SizedBox(height: 24.h), // top: 68 - 44 (status bar)
                    
                    // Заголовок (по дизайну: SF Pro, 510, 32px)
                    Text(
                      'Регистрация',
                      style: TextStyle(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    
                    // Подзаголовок (по дизайну: SF Pro, 510, 14px, #888888)
                    Text(
                      'Введите вашу электронную почту и пароль для регистрации',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    SizedBox(height: 24.h), // gap до полей
                    
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
                      textInputAction: TextInputAction.next,
                      onChanged: (_) {
                        if (_passwordError != null) {
                          setState(() => _passwordError = null);
                        }
                      },
                      onSubmitted: (_) {
                        _confirmPasswordFocusNode.requestFocus();
                      },
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
                    SizedBox(height: 16.h), // По дизайну: gap 16px
                    
                    // Поле Повторите пароль
                    AuthTextField(
                      controller: _confirmPasswordController,
                      focusNode: _confirmPasswordFocusNode,
                      label: 'Повторите пароль',
                      errorText: _confirmPasswordError,
                      obscureText: _obscureConfirmPassword,
                      textInputAction: TextInputAction.done,
                      onChanged: (_) {
                        if (_confirmPasswordError != null) {
                          setState(() => _confirmPasswordError = null);
                        }
                      },
                      onSubmitted: (_) => _onSignUp(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword 
                              ? Icons.visibility_outlined 
                              : Icons.visibility_off_outlined,
                          color: AppColors.textSecondaryLight,
                        ),
                        onPressed: () {
                          setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                        },
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Кнопка Продолжить (по дизайну: высота 41px, radius 12px)
                    SizedBox(
                      width: double.infinity,
                      height: 41.h,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _onSignUp,
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
                    
                    // Кнопка Уже есть аккаунт? (по дизайну: высота 41px, серый #969696)
                    SizedBox(
                      width: double.infinity,
                      height: 41.h,
                      child: ElevatedButton(
                        onPressed: () => context.pop(),
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
                        child: const Text('Уже есть аккаунт?'),
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
