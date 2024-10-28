import 'package:equatable/equatable.dart';
import 'package:traffic_watcher/features/video/data/model/video_model.dart';

import '../../../auth/data/model/user.dart';

abstract class VideoEvent extends Equatable {
  const VideoEvent();

  @override
  List<Object> get props => [];
}

class PickVideo extends VideoEvent {
  final bool fromCamera;

  const PickVideo({required this.fromCamera});
}

class UploadVideo extends VideoEvent {
  final VideoModel videoModel;
  final User user;

  const UploadVideo(this.videoModel, this.user);
  @override
  List<Object> get props => [videoModel];
}

class CompressVideo extends VideoEvent {
  final VideoModel videoModel;
  final User user;

  const CompressVideo(this.videoModel, this.user);

  @override
  List<Object> get props => [videoModel];
}