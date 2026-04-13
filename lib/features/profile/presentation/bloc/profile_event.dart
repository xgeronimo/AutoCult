part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileUpdateRequested extends ProfileEvent {
  final String userId;
  final String? displayName;
  final String? photoPath;

  const ProfileUpdateRequested({
    required this.userId,
    this.displayName,
    this.photoPath,
  });

  @override
  List<Object?> get props => [userId, displayName, photoPath];
}

class ProfileChangePasswordRequested extends ProfileEvent {
  final String currentPassword;
  final String newPassword;

  const ProfileChangePasswordRequested({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object> get props => [currentPassword, newPassword];
}

class ProfileDeleteAccountRequested extends ProfileEvent {
  final String password;

  const ProfileDeleteAccountRequested({required this.password});

  @override
  List<Object> get props => [password];
}
