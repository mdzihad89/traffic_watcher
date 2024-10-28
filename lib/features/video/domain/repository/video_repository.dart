
import 'package:dartz/dartz.dart';
import 'package:googleapis/drive/v3.dart';
import '../../../auth/data/model/user.dart' as signedInUser;
import 'package:traffic_watcher/features/video/data/model/video_model.dart';
import '../../../../core/error/failure.dart';

abstract class VideoRepository {
  Future<Either<Failure, File>> uploadVideo(VideoModel videoModel, signedInUser.User user);
}