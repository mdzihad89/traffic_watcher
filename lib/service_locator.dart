import 'package:get_it/get_it.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:traffic_watcher/features/video/domain/repository/video_repository.dart';
import 'package:traffic_watcher/features/video/presentation/bloc/video_bloc.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repository/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/video/data/repositories/video_repository_impl.dart';

final getIt = GetIt.instance;

Future<void> setup() async {
  final storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );
  HydratedBloc.storage = storage;
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());
  getIt.registerLazySingleton<VideoRepository>(() => VideoRepositoryImpl());
  getIt.registerFactory<AuthBloc>(() => AuthBloc(getIt<AuthRepository>()));
  getIt.registerFactory<VideoBloc>(() => VideoBloc(getIt<VideoRepository>()));
}
