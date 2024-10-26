import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:traffic_watcher/core/constants/asset_constants.dart';
import 'package:traffic_watcher/features/auth/presentation/screen/signin_screen.dart';
import '../../../video/presentation/screen/home_screen.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';


class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
        } else if (state is Unauthenticated) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SignInScreen()));
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: Center(
            child: Image.asset(AssetConstants.appLogo, height: 100, width: 100),
          ),
        );
      },
    );
  }
}