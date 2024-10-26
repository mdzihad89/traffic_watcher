import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/repository/video_repository.dart';
import 'video_event.dart';
import 'video_state.dart';

class VideoBloc extends Bloc<VideoEvent, VideoState> {
  final ImagePicker _imagePicker = ImagePicker();
  final VideoRepository _videoRepository;

  VideoBloc(this._videoRepository) : super(VideoInitial()) {
    on<PickVideo>((event, emit) async {
      try {
        final pickedFile = await _imagePicker.pickVideo(
          source: event.fromCamera ? ImageSource.camera : ImageSource.gallery,
        );
        if (pickedFile != null) {
          emit(VideoPicked(pickedFile.path));
        } else {
          emit(const VideoError('Video selection was canceled'));
        }
      } catch (e) {
        emit(const VideoError('An error occurred while picking the video'));
      }
    });
    on<UploadVideo>((event, emit) async {
      emit(VideoLoading());
      final result = await _videoRepository.uploadVideo(event.videoModel);
      result.fold(
            (failure) => emit( VideoError(failure.message)),
            (file) => emit(VideoUploaded(file)),
      );
    });

  }
}
