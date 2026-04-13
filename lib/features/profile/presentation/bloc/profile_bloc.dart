import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/image_storage_service.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/domain/usecases/update_profile_usecase.dart';
import '../../../auth/domain/usecases/change_password_usecase.dart';
import '../../../auth/domain/usecases/delete_account_usecase.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UpdateProfileUseCase updateProfileUseCase;
  final ChangePasswordUseCase changePasswordUseCase;
  final DeleteAccountUseCase deleteAccountUseCase;
  final ImageStorageService imageStorageService;

  ProfileBloc({
    required this.updateProfileUseCase,
    required this.changePasswordUseCase,
    required this.deleteAccountUseCase,
    required this.imageStorageService,
  }) : super(const ProfileInitial()) {
    on<ProfileUpdateRequested>(_onUpdateProfile);
    on<ProfileChangePasswordRequested>(_onChangePassword);
    on<ProfileDeleteAccountRequested>(_onDeleteAccount);
  }

  Future<void> _onUpdateProfile(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    try {
      String? photoUrl;

      if (event.photoPath != null) {
        photoUrl = await imageStorageService.uploadImage(
          storagePath: StoragePaths.userAvatars,
          filePath: event.photoPath!,
          ownerId: event.userId,
        );
      }

      final result = await updateProfileUseCase(UpdateProfileParams(
        displayName: event.displayName,
        photoUrl: photoUrl,
      ));

      result.fold(
        (failure) => emit(ProfileError(failure.message)),
        (user) => emit(ProfileUpdateSuccess(user)),
      );
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onChangePassword(
    ProfileChangePasswordRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    final result = await changePasswordUseCase(ChangePasswordParams(
      currentPassword: event.currentPassword,
      newPassword: event.newPassword,
    ));

    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (_) => emit(const ProfilePasswordChanged()),
    );
  }

  Future<void> _onDeleteAccount(
    ProfileDeleteAccountRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    final result = await deleteAccountUseCase(DeleteAccountParams(
      password: event.password,
    ));

    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (_) => emit(const ProfileAccountDeleted()),
    );
  }
}
