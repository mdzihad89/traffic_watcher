import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traffic_watcher/features/auth/presentation/bloc/auth_state.dart';
import 'package:video_player/video_player.dart';
import 'package:traffic_watcher/features/video/presentation/bloc/video_bloc.dart';
import 'package:traffic_watcher/features/video/presentation/bloc/video_event.dart';
import 'package:traffic_watcher/features/video/presentation/bloc/video_state.dart';
import 'package:traffic_watcher/features/video/data/model/video_model.dart';

import '../../../../core/dialogue/loading_screen.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class UploadScreen extends StatefulWidget {
  final String videoPath;

  const UploadScreen({super.key, required this.videoPath});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  TextEditingController _locationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.file(File(widget.videoPath));
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      showControls: true,
    );
    _videoPlayerController.initialize().then((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final videoState = context.read<VideoBloc>().state;
        if (videoState is VideoLoading || videoState is VideoCompressing) {
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(),
        body: BlocConsumer<VideoBloc, VideoState>(
          listener: (context, state) {
            if (state is VideoUploaded) {
              LoadingScreen.instance.hide();
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                      content: Text('${state.file.name} Uploaded successfully!')),
                );
              Navigator.pop(context);
            } else if (state is VideoError) {
              LoadingScreen.instance.hide();
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
            } else if (state is VideoLoading) {
              LoadingScreen.instance.show(context: context , text: 'Uploading ...');
            }else if (state is VideoCompressing) {
              LoadingScreen.instance.show(context: context, text: 'Compressing ...');
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0)
                  .copyWith(bottom: 8.0),
              child: _videoPlayerController.value.isInitialized
                  ? SingleChildScrollView(
                scrollDirection: Axis.vertical,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Form(
                            key: _formKey,
                            child: TextFormField(
                              controller: _locationController,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.done,
                              decoration: const InputDecoration(
                                labelText: 'Enter Location',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a location';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          AspectRatio(
                            aspectRatio: _videoPlayerController.value.aspectRatio,
                            child: Chewie(controller: _chewieController),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                FocusScope.of(context).unfocus();
                                _chewieController.pause();
                                final videoModel = VideoModel(
                                  videoPath: widget.videoPath,
                                  location: _locationController.text,
                                );
                                context.read<VideoBloc>().add(CompressVideo(videoModel , (context.read<AuthBloc>().state as Authenticated).user));


                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              fixedSize:
                                  Size(MediaQuery.sizeOf(context).width / 2, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: const Text(
                              "Upload",
                              style: TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          ),
                        ],
                      ),
                  )
                  : const Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ),
    );
  }
}
