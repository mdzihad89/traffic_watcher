import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/error/failure.dart';
import '../../domain/repository/auth_repository.dart';
import '../model/user.dart';

class AuthRepositoryImpl implements AuthRepository {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Future<Either<Failure, User>> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account != null) {
        return Right(
          User(
            id: account.id,
            name: account.displayName ?? '',
            email: account.email,
            photoUrl: account.photoUrl ?? '',
          ),
        );
      } else {
        return Left(Failure('Sign-in was canceled'));
      }
    } catch (e) {
      return Left(Failure('An error occurred during sign-in'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _googleSignIn.signOut();
      return const Right(null);
    } catch (e) {
      return Left(Failure('An error occurred during sign-out'));
    }
  }

  @override
  Future<Option<User>> getSignedInUser() async {
    final account = await _googleSignIn.signInSilently();
    if (account != null) {
      return Some(User(
        id: account.id,
        name: account.displayName ?? '',
        email: account.email,
        photoUrl: account.photoUrl ?? '',
      ));
    }
    return const None();
  }
}
