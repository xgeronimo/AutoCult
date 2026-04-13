import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/image_picker_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/photo_viewer_page.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/personal_document_entity.dart';
import '../bloc/personal_documents_bloc.dart';

class PersonalDocumentsPage extends StatelessWidget {
  const PersonalDocumentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final userId = authState is AuthAuthenticated ? authState.user.id : '';

    return BlocProvider(
      create: (_) => sl<PersonalDocumentsBloc>()
        ..add(PersonalDocumentsLoadRequested(userId)),
      child: const _PersonalDocumentsView(),
    );
  }
}

class _PersonalDocumentsView extends StatelessWidget {
  const _PersonalDocumentsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              child: Row(
                children: [
                  GlassPillButton(
                    iconPath: 'assets/icons/arrow-left-s-line.svg',
                    onTap: () => context.pop(),
                  ),
                  Expanded(
                    child: Text(
                      'Мои документы',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  GlassPillButton(
                    iconPath: 'assets/icons/add-line.svg',
                    onTap: () => _showAddDocumentSheet(context),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            Expanded(
              child: BlocBuilder<PersonalDocumentsBloc, PersonalDocumentsState>(
                builder: (context, state) {
                  if (state is PersonalDocumentsLoading) {
                    return const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary),
                    );
                  }

                  if (state is PersonalDocumentsError) {
                    return _buildError(context, state.message);
                  }

                  final documents = state is PersonalDocumentsLoaded
                      ? state.documents
                      : <PersonalDocumentEntity>[];

                  if (documents.isEmpty) {
                    return _buildEmpty(context);
                  }

                  return _buildDocumentsList(context, documents);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/passport-fill.svg',
                  width: 40.w,
                  height: 40.w,
                  colorFilter: ColorFilter.mode(
                    AppColors.textSecondaryLight.withValues(alpha: 0.5),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Нет документов',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryLight,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Добавьте водительское удостоверение,\nпаспорт или другие документы',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: () => _showAddDocumentSheet(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Добавить документ',
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

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48.sp, color: AppColors.error),
            SizedBox(height: 12.h),
            Text(
              message,
              style: TextStyle(fontSize: 14.sp, color: AppColors.error),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            TextButton(
              onPressed: () {
                final authState = context.read<AuthBloc>().state;
                if (authState is AuthAuthenticated) {
                  context.read<PersonalDocumentsBloc>().add(
                        PersonalDocumentsLoadRequested(authState.user.id),
                      );
                }
              },
              child: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsList(
    BuildContext context,
    List<PersonalDocumentEntity> documents,
  ) {
    return ListView.separated(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 8.h,
        bottom: MediaQuery.of(context).padding.bottom + 20.h,
      ),
      itemCount: documents.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final doc = documents[index];
        return _buildDocumentCard(context, doc);
      },
    );
  }

  Widget _buildDocumentCard(BuildContext context, PersonalDocumentEntity doc) {
    return GestureDetector(
      onTap: () => _showDocumentPhoto(context, doc),
      onLongPress: () => _showDeleteDocDialog(context, doc),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Container(
              width: 64.w,
              height: 64.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
              ),
              clipBehavior: Clip.antiAlias,
              child: doc.photoUrl.isNotEmpty
                  ? Image.network(
                      doc.photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildDocIcon(),
                    )
                  : _buildDocIcon(),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc.displayName,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _formatDate(doc.createdAt),
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _showDocumentOptions(context, doc),
              child: Padding(
                padding: EdgeInsets.all(8.w),
                child: Icon(
                  Icons.more_vert_rounded,
                  size: 20.w,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocIcon() {
    return Center(
      child: SvgPicture.asset(
        'assets/icons/file-list-3-fill.svg',
        width: 28.w,
        height: 28.w,
        colorFilter: ColorFilter.mode(
          AppColors.textSecondaryLight,
          BlendMode.srcIn,
        ),
      ),
    );
  }

  void _showAddDocumentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Выберите тип документа',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              SizedBox(height: 16.h),
              ...PersonalDocumentType.values.map(
                (type) => ListTile(
                  leading: Icon(
                    _iconForType(type),
                    color: AppColors.textPrimaryLight,
                  ),
                  title: Text(
                    type.label,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickAndAddDocument(context, type);
                  },
                ),
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForType(PersonalDocumentType type) {
    switch (type) {
      case PersonalDocumentType.driverLicense:
        return Icons.badge_outlined;
      case PersonalDocumentType.passport:
        return Icons.menu_book_outlined;
      case PersonalDocumentType.snils:
        return Icons.credit_card_outlined;
      case PersonalDocumentType.inn:
        return Icons.numbers_outlined;
      case PersonalDocumentType.medicalCertificate:
        return Icons.medical_information_outlined;
      case PersonalDocumentType.other:
        return Icons.description_outlined;
    }
  }

  Future<void> _pickAndAddDocument(
    BuildContext context,
    PersonalDocumentType type,
  ) async {
    final pickerService = sl<ImagePickerService>();
    final path = await pickerService.showPickerSheet(context);
    if (path == null || !context.mounted) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    context.read<PersonalDocumentsBloc>().add(
          PersonalDocumentsAddRequested(
            userId: authState.user.id,
            type: type,
            photoPath: path,
          ),
        );
  }

  void _showDocumentPhoto(BuildContext context, PersonalDocumentEntity doc) {
    if (doc.photoUrl.isEmpty) return;
    PhotoViewerPage.open(
      context,
      photoUrls: [doc.photoUrl],
    );
  }

  void _showDocumentOptions(BuildContext context, PersonalDocumentEntity doc) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                doc.displayName,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              SizedBox(height: 20.h),
              ListTile(
                leading: const Icon(Icons.visibility_outlined),
                title: Text(
                  'Просмотреть',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _showDocumentPhoto(context, doc);
                },
              ),
              ListTile(
                leading:
                    Icon(Icons.delete_outline_rounded, color: AppColors.error),
                title: Text(
                  'Удалить',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.error,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _showDeleteDocDialog(context, doc);
                },
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDocDialog(BuildContext context, PersonalDocumentEntity doc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Удалить документ?',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        content: Text(
          '${doc.displayName} будет удалён без возможности восстановления.',
          style:
              TextStyle(fontSize: 14.sp, color: AppColors.textSecondaryLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Отмена',
              style: TextStyle(
                color: AppColors.textSecondaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<PersonalDocumentsBloc>().add(
                    PersonalDocumentsDeleteRequested(doc.id),
                  );
            },
            child: Text(
              'Удалить',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'января',
      'февраля',
      'марта',
      'апреля',
      'мая',
      'июня',
      'июля',
      'августа',
      'сентября',
      'октября',
      'ноября',
      'декабря',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
