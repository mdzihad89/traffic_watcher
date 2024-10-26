import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../data/model/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> signInWithGoogle();
  Future<Either<Failure, void>> signOut();
  Future<Option<User>> getSignedInUser();
}