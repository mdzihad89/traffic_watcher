import 'package:equatable/equatable.dart';
import 'package:googleapis/drive/v3.dart';

abstract class VideoState extends Equatable {
  const VideoState();
  @override
  List<Object> get props => [];
}

class VideoInitial extends VideoState {}

class VideoLoading extends VideoState {}

class VideoPicked extends VideoState {
  final String videoPath;
  const VideoPicked(this.videoPath);

  @override
  List<Object> get props => [videoPath];
}

class VideoError extends VideoState {
  final String message;
  const VideoError(this.message);

  @override
  List<Object> get props => [message];
}

class VideoUploaded extends VideoState {
  final File file;
  const VideoUploaded(this.file);

  @override
  List<Object> get props => [file];
}
