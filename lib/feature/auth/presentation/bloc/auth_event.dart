import 'package:commute_calendar/feature/user/domain/entities/user_entity.dart';
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthStarted extends AuthEvent {
  const AuthStarted();
}

class AuthUserChanged extends AuthEvent {
  const AuthUserChanged(this.user);

  final UserEntity? user;

  @override
  List<Object?> get props => [user];
}

class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}
