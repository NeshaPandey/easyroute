import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import '../../../domain/entities/route_entity.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/user_repository.dart';

// Events
abstract class AuthEvent extends Equatable {
  @override List<Object?> get props => [];
}
class LoginWithEmail extends AuthEvent {
  final String email, password;
  LoginWithEmail(this.email, this.password);
  @override List<Object?> get props => [email];
}
class LoginWithGoogle extends AuthEvent {}
class SignUpWithEmail extends AuthEvent {
  final String email, password, name;
  SignUpWithEmail(this.email, this.password, this.name);
  @override List<Object?> get props => [email, name];
}
class LogoutRequested extends AuthEvent {}
class CheckAuthStatus extends AuthEvent {}
class _AuthStatusChanged extends AuthEvent {
  final UserEntity? user;
  _AuthStatusChanged(this.user);
  @override List<Object?> get props => [user];
}

// States
abstract class AuthState extends Equatable {
  @override List<Object?> get props => [];
}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final UserEntity user;
  AuthAuthenticated(this.user);
  @override List<Object?> get props => [user];
}
class AuthUnauthenticated extends AuthState {}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
  @override List<Object?> get props => [message];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository = GetIt.instance<AuthRepository>();
  StreamSubscription<UserEntity?>? _userSubscription;

  AuthBloc() : super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheck);
    on<LoginWithEmail>(_onLoginEmail);
    on<LoginWithGoogle>(_onLoginGoogle);
    on<SignUpWithEmail>(_onSignUp);
    on<LogoutRequested>(_onLogout);
    on<_AuthStatusChanged>(_onStatusChanged);

    // Subscribe to auth state changes from repository
    _userSubscription = _authRepository.user.listen((user) {
      add(_AuthStatusChanged(user));
    });
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }

  Future<void> _onCheck(CheckAuthStatus e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (err) {
      emit(AuthError(err.toString()));
    }
  }

  Future<void> _onLoginEmail(LoginWithEmail e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.loginWithEmail(e.email, e.password);
      emit(AuthAuthenticated(user));
    } catch (err) {
      emit(AuthError(err.toString()));
    }
  }

  Future<void> _onLoginGoogle(LoginWithGoogle e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.loginWithGoogle();
      emit(AuthAuthenticated(user));
    } catch (err) {
      emit(AuthError(err.toString()));
    }
  }

  Future<void> _onSignUp(SignUpWithEmail e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.signUpWithEmail(e.email, e.password, e.name);
      emit(AuthAuthenticated(user));
    } catch (err) {
      emit(AuthError(err.toString()));
    }
  }

  Future<void> _onLogout(LogoutRequested e, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.logout();
      emit(AuthUnauthenticated());
    } catch (err) {
      emit(AuthError(err.toString()));
    }
  }

  void _onStatusChanged(_AuthStatusChanged e, Emitter<AuthState> emit) {
    if (e.user != null) {
      emit(AuthAuthenticated(e.user!));
    } else {
      emit(AuthUnauthenticated());
    }
  }
}
