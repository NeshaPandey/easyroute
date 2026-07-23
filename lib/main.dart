import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/route/route_bloc.dart';
import 'presentation/bloc/navigation/navigation_bloc.dart';
import 'presentation/bloc/location/location_bloc.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/user_repository.dart';
import 'domain/repositories/place_repository.dart';
import 'domain/repositories/route_repository.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/user_repository_impl.dart';
import 'data/repositories/place_repository_impl.dart';
import 'data/repositories/route_repository_impl.dart';

final getIt = GetIt.instance;

void _setupDependencies() {
  const googleApiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY', defaultValue: '');

  // Register Place & Route repositories
  final placeRepository = HybridPlaceRepositoryImpl(googleApiKey: googleApiKey);
  final routeRepository = GoogleRouteRepositoryImpl(googleApiKey: googleApiKey);

  getIt.registerSingleton<PlaceRepository>(placeRepository);
  getIt.registerSingleton<RouteRepository>(routeRepository);

  // Register Auth & User repositories
  final isFirebaseInitialized = Firebase.apps.isNotEmpty;

  if (isFirebaseInitialized) {
    final userRepository = FirestoreUserRepository();
    getIt.registerSingleton<UserRepository>(userRepository);
    getIt.registerSingleton<AuthRepository>(FirebaseAuthRepository(userRepository));
  } else {
    final userRepository = DemoUserRepository();
    getIt.registerSingleton<UserRepository>(userRepository);
    getIt.registerSingleton<AuthRepository>(DemoAuthRepository());
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  // Firebase
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Firebase not configured yet — app still runs in demo mode
  }

  _setupDependencies();

  runApp(const EasyRouteApp());
}

class EasyRouteApp extends StatefulWidget {
  const EasyRouteApp({super.key});

  @override
  State<EasyRouteApp> createState() => _EasyRouteAppState();
}

class _EasyRouteAppState extends State<EasyRouteApp> {
  late final AppRouter _router;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _router = AppRouter();
  }

  void _toggleTheme(bool dark) => setState(() => _isDarkMode = dark);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc()),
        BlocProvider(
          create: (_) => RouteBloc(
            routeRepository: getIt<RouteRepository>(),
          ),
        ),
        BlocProvider(create: (_) => NavigationBloc()),
        BlocProvider(create: (_) => LocationBloc()),
      ],
      child: MaterialApp.router(
        title: 'EasyRoute',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
        routerConfig: _router.config,
      ),
    );
  }
}
