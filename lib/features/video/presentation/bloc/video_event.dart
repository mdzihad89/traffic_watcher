import 'package:equatable/equatable.dart';
import 'package:traffic_watcher/features/video/data/model/video_model.dart';

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
  const UploadVideo(this.videoModel);
  @override
  List<Object> get props => [videoModel];
}