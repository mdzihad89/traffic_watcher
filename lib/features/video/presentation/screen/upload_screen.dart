import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:traffic_watcher/features/video/presentation/bloc/video_bloc.dart';
import 'package:traffic_watcher/features/video/presentation/bloc/video_event.dart';
import 'package:traffic_watcher/features/video/presentation/bloc/video_state.dart';
import 'package:traffic_watcher/features/video/data/model/video_model.dart';

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

  void _showProgressDialog(BuildContext context) {
    _overlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.black54,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text('Uploading...'),
              ],
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideProgressDialog() {
    _overlayEntry?.remove();
    _overlayEntry = null;
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
    return Scaffold(
      appBar: AppBar(),
      body: BlocConsumer<VideoBloc, VideoState>(
        listener: (context, state) {
          if (state is VideoUploaded) {
            _hideProgressDialog();
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                    content: Text('${state.file.name} Uploaded successfully!')),
              );
            Navigator.pop(context);
          } else if (state is VideoError) {
            _hideProgressDialog();
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(state.message)),
              );
          } else if (state is VideoLoading) {
            _showProgressDialog(context);
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0)
                .copyWith(bottom: 8.0),
            child: _videoPlayerController.value.isInitialized
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Form(
                        key: _formKey,
                        child: TextFormField(
                          controller: _locationController,
                          keyboardType: TextInputType.text,
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
                            _chewieController.pause();
                            final videoModel = VideoModel(
                              videoPath: widget.videoPath,
                              location: _locationController.text,
                            );
                            context
                                .read<VideoBloc>()
                                .add(UploadVideo(videoModel));
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
                  )
                : const Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}
