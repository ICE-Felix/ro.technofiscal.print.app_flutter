import 'package:app/core/navigation/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/service_locator.dart';
import 'core/style/app_theme.dart';
import 'core/localization/app_localization.dart';
import 'core/cubit/location_cubit.dart';
import 'features/auth/presentation/bloc/authentication_bloc.dart';
import 'features/intro/presentation/bloc/intro_bloc.dart';
import 'features/news/presentation/bloc/news_bloc.dart';
import 'firebase_options.dart';
import '../core/services/firebase_messaging_service.dart';
import 'features/notifications/presentation/bloc/notification_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase only on supported platforms (Android, iOS, Web)
  if (defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS ||
      kIsWeb) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    // Initialize Firebase Messaging only on supported platforms
    await sl<FirebaseMessagingService>().initialize();
  }

  // Load environment variables
  await dotenv.load(fileName: ".env");
  // Initialize dependency injection
  await initServiceLocator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<AuthenticationBloc>()),
        BlocProvider(create: (context) => sl<IntroBloc>()),
        BlocProvider(create: (context) => sl<NewsBloc>()),
        BlocProvider(create: (context) => sl<NotificationBloc>()),
        BlocProvider(create: (context) => sl<LocationCubit>(), lazy: false),
        BlocProvider(
          create:
              (context) => sl<LocalizationCubit>()..initializeLocalization(),
          lazy: false,
        ),
      ],
      child: LocalizationProvider(
        child: MaterialApp.router(
          title: 'Mommy HAI',
          theme: AppTheme.lightTheme,
          themeMode: ThemeMode.light,
          routerConfig: routes,
        ),
      ),
    );
  }
}
