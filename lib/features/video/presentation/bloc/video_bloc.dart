import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_compress/video_compress.dart';
import '../../data/model/video_model.dart';
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
      final result = await _videoRepository.uploadVideo(event.videoModel , event.user );
      result.fold(
            (failure) => emit( VideoError(failure.message)),
            (file) => emit(VideoUploaded(file)),
      );
    });

    on<CompressVideo>((event, emit) async {
  emit(VideoCompressing());
  try {
    final compressedVideo = await VideoCompress.compressVideo(
      event.videoModel.videoPath,
      quality: VideoQuality.DefaultQuality,
    );
    final videoModel = VideoModel(
      videoPath: compressedVideo!.file!.path,
      location: event.videoModel.location,
    );
    add(UploadVideo(videoModel , event.user));
  } catch (e) {
    emit(const VideoError('An error occurred while compressing the video'));
  }
});

  }


}
