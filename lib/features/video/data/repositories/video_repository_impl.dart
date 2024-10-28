import 'dart:convert';
import 'dart:io' as io;
import 'package:googleapis_auth/auth_io.dart';
import 'package:dartz/dartz.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:traffic_watcher/core/error/failure.dart';
import 'package:traffic_watcher/core/secrets/app_secrets.dart';
import 'package:traffic_watcher/features/video/data/model/video_model.dart';
import '../../domain/repository/video_repository.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import '../../../auth/data/model/user.dart' as signedInUser;

class VideoRepositoryImpl implements VideoRepository {
  @override
  Future<Either<Failure, File>> uploadVideo(VideoModel videoModel, signedInUser.User user) async {
    try {
      var credentials = json.decode(AppSecrests.serviceAccountCredentials);
      var accountCredentials = ServiceAccountCredentials.fromJson(credentials);
      var scopes = [drive.DriveApi.driveFileScope];
      var client = await clientViaServiceAccount(accountCredentials, scopes);
      var driveApi = drive.DriveApi(client);
      var media = drive.Media(io.File(videoModel.videoPath).openRead(),
          io.File(videoModel.videoPath).lengthSync());
      var driveFile = drive.File()
        ..name = "${user.name}-${videoModel.location}.mp4"
        ..parents = [AppSecrests.driveFolderId];
      File responseFile = await driveApi.files.create(
        driveFile, uploadMedia: media,
        uploadOptions: drive.UploadOptions.defaultOptions,);
      return Right(responseFile);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

}