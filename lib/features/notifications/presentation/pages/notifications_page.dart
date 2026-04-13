import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/reminder_entity.dart';
import '../bloc/notifications_bloc.dart';
import '../widgets/reminder_tile.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadReminders();
  }

  void _loadReminders() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<NotificationsBloc>().add(
            NotificationsLoadRequested(authState.user.id),
          );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationsBloc, NotificationsState>(
      listener: (context, state) {
        if (state is NotificationsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              SizedBox(height: 4.h),
              _buildTabBar(),
              Expanded(
                child: BlocBuilder<NotificationsBloc, NotificationsState>(
                  builder: (context, state) {
                    if (state is NotificationsLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }

                    if (state is NotificationsLoaded) {
                      return TabBarView(
                        controller: _tabController,
                        children: [
                          _buildActiveTab(state),
                          _buildPastTab(state),
                        ],
                      );
                    }

                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_none_rounded,
                            size: 64.w,
                            color: AppColors.divider,
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'Загрузка...',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────── App Bar ───────────────

  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Row(
        children: [
          GlassPillButton(
            iconPath: 'assets/icons/arrow-left-s-line.svg',
            onTap: () => context.pop(),
          ),
          Expanded(
            child: Text(
              'Уведомления',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          BlocBuilder<NotificationsBloc, NotificationsState>(
            builder: (context, state) {
              final hasOverdue = state is NotificationsLoaded &&
                  state.overdueUnread.isNotEmpty;
              if (!hasOverdue) return SizedBox(width: 44.w);

              return GestureDetector(
                onTap: () {
                  context.read<NotificationsBloc>().add(
                        const NotificationsMarkAllAsReadRequested(),
                      );
                },
                child: Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF7F7F7),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.done_all_rounded,
                    size: 22.w,
                    color: AppColors.primary,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ─────────────── Tab Bar ───────────────

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      height: 40.h,
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: AppColors.textPrimaryLight,
        unselectedLabelColor: AppColors.textSecondaryLight,
        labelStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
        padding: EdgeInsets.all(3.w),
        tabs: const [
          Tab(text: 'Активные'),
          Tab(text: 'Прошедшие'),
        ],
      ),
    );
  }

  // ─────────────── Active Tab ───────────────

  Widget _buildActiveTab(NotificationsLoaded state) {
    final overdue = state.overdueUnread;
    final upcoming = state.upcomingUnread;

    if (overdue.isEmpty && upcoming.isEmpty) {
      return _buildEmptyActiveState();
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => _loadReminders(),
            color: AppColors.primary,
            child: ListView(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
              children: [
                for (final reminder in overdue) ...[
                  _buildDismissibleTile(reminder, canMarkAsRead: true),
                  SizedBox(height: 8.h),
                ],
                if (upcoming.isNotEmpty) ...[
                  if (overdue.isNotEmpty) SizedBox(height: 8.h),
                  _buildSectionDivider('Предстоящие'),
                  SizedBox(height: 12.h),
                ],
                for (final reminder in upcoming) ...[
                  _buildDismissibleTile(reminder, canMarkAsRead: false),
                  SizedBox(height: 8.h),
                ],
              ],
            ),
          ),
        ),
        _buildAddReminderButton(),
      ],
    );
  }

  // ─────────────── Past Tab ───────────────

  Widget _buildPastTab(NotificationsLoaded state) {
    final read = state.readReminders;

    if (read.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 64.w,
              color: AppColors.divider,
            ),
            SizedBox(height: 12.h),
            Text(
              'Нет прошедших напоминаний',
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.textSecondaryLight,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Прочитанные напоминания появятся здесь',
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.textSecondaryLight.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _loadReminders(),
      color: AppColors.primary,
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
        itemCount: read.length,
        separatorBuilder: (_, __) => SizedBox(height: 8.h),
        itemBuilder: (context, index) {
          return _buildDismissibleTile(read[index], canMarkAsRead: false);
        },
      ),
    );
  }

  // ─────────────── Empty Active State ───────────────

  Widget _buildEmptyActiveState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 72.w,
              color: AppColors.divider,
            ),
            SizedBox(height: 16.h),
            Text(
              'Нет активных напоминаний',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryLight,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Создайте напоминание, чтобы не забыть\nо важных событиях для вашего авто',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 28.h),
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                onPressed: () => context.push(AppRoutes.createReminder),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Добавить напоминание',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────── Add Reminder Button ───────────────

  Widget _buildAddReminderButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
      child: SizedBox(
        width: double.infinity,
        height: 52.h,
        child: ElevatedButton(
          onPressed: () => context.push(AppRoutes.createReminder),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
            elevation: 0,
          ),
          child: Text(
            'Добавить напоминание',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────── Dismissible Tile ───────────────

  Widget _buildDismissibleTile(
    ReminderEntity reminder, {
    required bool canMarkAsRead,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14.r),
      child: Dismissible(
        key: Key(reminder.id),
        direction: canMarkAsRead
            ? DismissDirection.horizontal
            : DismissDirection.endToStart,
        onDismissed: (direction) {
          if (direction == DismissDirection.startToEnd) {
            context.read<NotificationsBloc>().add(
                  NotificationsMarkAsReadRequested(reminder.id),
                );
          } else {
            context.read<NotificationsBloc>().add(
                  NotificationsDeleteRequested(reminder.id),
                );
          }
        },
        // Свайп вправо → зелёный фон, галочка → прочитано
        background: Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: 24.w),
          color: AppColors.primary,
          child: Row(
            children: [
              Icon(Icons.done_rounded, color: Colors.white, size: 26.w),
              SizedBox(width: 8.w),
              Text(
                'Прочитано',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        // Свайп влево → красный фон, корзина → удалить
        secondaryBackground: Container(
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 24.w),
          color: AppColors.error,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Удалить',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 8.w),
              Icon(Icons.delete_outline_rounded,
                  color: Colors.white, size: 26.w),
            ],
          ),
        ),
        child: ReminderTile(reminder: reminder),
      ),
    );
  }

  // ─────────────── Section Divider ───────────────

  Widget _buildSectionDivider(String label) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.divider.withValues(alpha: 0.6),
            thickness: 1,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.divider.withValues(alpha: 0.6),
            thickness: 1,
          ),
        ),
      ],
    );
  }
}
