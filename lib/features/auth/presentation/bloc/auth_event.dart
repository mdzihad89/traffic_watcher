import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AppStarted extends AuthEvent {}

class SignInRequested extends AuthEvent {}

class SignOutRequested extends AuthEvent {}

class SignInCancelled extends AuthEvent {}
