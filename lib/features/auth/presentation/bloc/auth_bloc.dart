import 'package:hydrated_bloc/hydrated_bloc.dart';
import '../../data/model/user.dart';
import '../../domain/repository/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends HydratedBloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc(this.authRepository) : super(AuthInitial()) {
    on<AppStarted>((event, emit) async {
      final userOption = await authRepository.getSignedInUser();
      userOption.fold(
        () => emit(Unauthenticated()),
        (user) => emit(Authenticated(user)),
      );
    });

    on<SignInRequested>((event, emit) async {
      emit(AuthLoading());
      final result = await authRepository.signInWithGoogle();
      result.fold(
        (failure) => emit(AuthError(failure.message)),
        (user) => emit(Authenticated(user)),
      );
    });

    on<SignOutRequested>((event, emit) async {
      emit(AuthLoading());
      final result = await authRepository.signOut();
      result.fold(
        (failure) => emit(AuthError(failure.message)),
        (_) => emit(Unauthenticated()),
      );
    });
  }

  @override
  AuthState? fromJson(Map<String, dynamic> json) {
    final stateType = json['type'] as String?;
    if (stateType == 'Authenticated') {
      return Authenticated(
        User(
          id: json['user']['id'],
          name: json['user']['name'],
          email: json['user']['email'],
          photoUrl: json['user']['photoUrl'],
        ),
      );
    } else if (stateType == 'Unauthenticated') {
      return Unauthenticated();
    }
    return null;
  }

  @override
  Map<String, dynamic>? toJson(AuthState state) {
    if (state is Authenticated) {
      return {
        'type': 'Authenticated',
        'user': {
          'id': state.user.id,
          'name': state.user.name,
          'email': state.user.email,
          'photoUrl': state.user.photoUrl,
        },
      };
    } else if (state is Unauthenticated) {

      return {'type': 'Unauthenticated'};
    }
    return null;
  }
}
