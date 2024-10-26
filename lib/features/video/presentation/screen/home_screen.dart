import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traffic_watcher/features/video/presentation/screen/upload_screen.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/screen/signin_screen.dart';
import '../bloc/video_bloc.dart';
import '../bloc/video_event.dart';
import '../bloc/video_state.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = (context.read<AuthBloc>().state as Authenticated).user;
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome ${user.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () {
              context.read<AuthBloc>().add(SignOutRequested());
            },
          ),
        ],
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is Unauthenticated) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const SignInScreen()));
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return BlocConsumer<VideoBloc, VideoState>(
              listener: (context, videoState) {
                if (videoState is VideoError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(videoState.message)),
                  );
                } else if (videoState is VideoPicked) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UploadScreen(videoPath: videoState.videoPath),
                    ),
                  );
                }
              },
            builder: (context,state) {

                if (state is VideoLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
              return Column(
                children: [
                  Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () async {
                          context.read<VideoBloc>().add(const PickVideo(fromCamera: false));
                        },
                        child: Container(
                          margin: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.photo_sharp,size: 70,color: Colors.white,),
                        ),
                      )),
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: (){
                        context.read<VideoBloc>().add(const PickVideo(fromCamera: true));
                      },
                      child: Container(
                        margin: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.black),
                        alignment: Alignment.center,
                        child: const Icon(Icons.camera_alt,size: 70,color: Colors.white,),
                      ),
                    ),
                  )
                ],
              );
            }
          );
        },
      ),
    );
  }
}
