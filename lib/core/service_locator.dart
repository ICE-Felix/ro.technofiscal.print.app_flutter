import 'package:app/core/banners/data/datasources/banners_remote_data_source.dart';
import 'package:app/core/banners/domain/repositories/banners_repository.dart';
import 'package:app/core/banners/domain/repositories/banners_repository_impl.dart';
import 'package:app/features/cart/data/datasource/cart_stock_datasource.dart';
import 'package:app/features/checkout/data/order_datasource.dart';
import 'package:app/features/checkout/data/order_datasource_supabase.dart';
import 'package:app/features/checkout/domain/repository/order_repository.dart';
import 'package:app/features/checkout/domain/service/checkout_service.dart';
import 'package:app/features/events/data/events_datasource.dart';
import 'package:app/features/events/data/events_datasource_supabase.dart';
import 'package:app/features/events/domain/repository/events_repository.dart';
import 'package:app/features/events/domain/repository/events_repository_supabase.dart';
import 'package:app/features/locations/data/datasources/locations_remote_data_source.dart';
import 'package:app/features/locations/domain/repositories/locations_repository.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'database/database_helper.dart';
import 'network/dio_client.dart';
import 'network/network_info.dart';
import 'network/supabase_client.dart';
import 'localization/app_localization.dart';
import '../features/auth/data/datasources/auth_remote_data_source.dart';
import '../features/auth/data/datasources/auth_local_data_source.dart';
import '../features/auth/domain/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/services/authentication_service.dart';
import '../features/auth/domain/services/supabase_authentication_service.dart';
import '../features/auth/domain/usecases/login_usecase.dart';
import '../features/auth/domain/usecases/register_usecase.dart';
import '../features/auth/domain/usecases/forgot_password_usecase.dart';
import '../features/auth/domain/usecases/check_auth_status_usecase.dart';
import '../features/auth/presentation/bloc/authentication_bloc.dart';
// Intro feature imports
import '../features/intro/data/datasources/intro_local_data_source.dart';
import '../features/intro/data/repositories/intro_repository_impl.dart';
import '../features/intro/domain/repositories/intro_repository.dart';
import '../features/intro/domain/usecases/check_network_usecase.dart';
import '../features/intro/domain/usecases/complete_intro_usecase.dart';
import '../features/intro/presentation/bloc/intro_bloc.dart';
// News feature imports
import '../features/news/data/datasources/news_remote_data_source.dart';
import '../features/news/data/repositories/news_repository_impl.dart';
import '../features/news/domain/repositories/news_repository.dart';
import '../features/news/domain/usecases/get_news_usecase.dart';
import '../features/news/domain/usecases/search_news_usecase.dart';
import '../features/news/domain/usecases/get_categories_usecase.dart'
    as news_categories;
import '../features/news/presentation/bloc/news_bloc.dart';
// Bookmark feature imports
import '../features/news/data/datasources/bookmark_local_data_source.dart';
import '../features/news/data/repositories/bookmark_repository_impl.dart';
import '../features/news/domain/repositories/bookmark_repository.dart';
import '../features/news/domain/usecases/toggle_bookmark_usecase.dart';
import '../features/news/domain/usecases/check_bookmark_usecase.dart';
// Shop feature imports
import '../features/shop/data/datasources/shop_remote_data_source.dart';
import '../features/shop/data/repositories/shop_repository_impl.dart';
import '../features/shop/domain/repositories/shop_repository.dart';
import '../features/shop/domain/usecases/get_categories_usecase.dart'
    as shop_categories;
import '../features/shop/domain/usecases/get_products_by_category_usecase.dart';
import '../features/shop/domain/usecases/get_product_by_id_usecase.dart';
import '../core/services/firebase_messaging_service.dart';
import '../features/notifications/presentation/bloc/notification_bloc.dart';
import '../core/services/supabase_fcm_service.dart';
import '../core/services/location_service.dart';
import '../core/cubit/location_cubit.dart';
import '../core/services/share_page_service.dart';
import '../core/navigation/routes.dart';
// Cart feature imports
import '../features/cart/cart.dart';
import '../features/checkout/checkout.dart';

final sl = GetIt.instance;

Future<void> initServiceLocator() async {
  //! External dependencies (register first)
  sl.registerLazySingleton(() => Connectivity());

  // SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  //! Core
  sl.registerLazySingleton(() => DioClient());
  sl.registerLazySingleton(() => SupabaseAuthClient());
  sl.registerLazySingleton(() => DatabaseHelper.instance);
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl<Connectivity>()),
  );

  // Initialize Supabase
  await SupabaseAuthClient.initialize();

  //! Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(supabaseClient: sl<SupabaseAuthClient>()),
  );

  // Auth local data source
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl<SharedPreferences>()),
  );

  // Authentication service
  sl.registerLazySingleton<AuthenticationService>(
    () =>
        SupabaseAuthenticationService(supabaseClient: sl<SupabaseAuthClient>()),
  );

  // Intro data sources
  sl.registerLazySingleton<IntroLocalDataSource>(
    () => IntroLocalDataSourceImpl(),
  );

  // News data sources
  sl.registerLazySingleton<NewsRemoteDataSource>(
    () => NewsRemoteDataSourceImpl(),
  );

  // Bookmark data sources
  sl.registerLazySingleton<BookmarkLocalDataSource>(
    () => BookmarkLocalDataSourceImpl(databaseHelper: sl<DatabaseHelper>()),
  );

  sl.registerLazySingleton<OrderDataSource>(
    () => OrderDataSourceSupabase(dio: sl<DioClient>()),
  );

  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(orderDataSource: sl<OrderDataSource>()),
  );
  sl.registerLazySingleton<CheckoutService>(() => CheckoutServiceImpl());

  // Cart service
  sl.registerLazySingleton<CartService>(() => CartServiceImpl());
  // Cart Stock Datasource
  sl.registerLazySingleton<CartStockDatasource>(
    () => CartStockDatasourceImpl(dio: sl<DioClient>()),
  );
  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(sl<CartService>(), sl<CartStockDatasource>()),
  );
  sl.registerLazySingleton(() => CartCubit()..loadCart());

  sl.registerLazySingleton(() => CheckoutCubit());

  //! Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      localDataSource: sl<AuthLocalDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Intro repository
  sl.registerLazySingleton<IntroRepository>(
    () => IntroRepositoryImpl(
      networkInfo: sl<NetworkInfo>(),
      localDataSource: sl<IntroLocalDataSource>(),
    ),
  );

  // News repository
  sl.registerLazySingleton<NewsRepository>(
    () => NewsRepositoryImpl(
      remoteDataSource: sl<NewsRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Bookmark repository
  sl.registerLazySingleton<BookmarkRepository>(
    () =>
        BookmarkRepositoryImpl(localDataSource: sl<BookmarkLocalDataSource>()),
  );

  //! Use cases
  sl.registerLazySingleton(
    () => LoginUseCase(repository: sl<AuthRepository>()),
  );
  sl.registerLazySingleton(
    () => RegisterUseCase(repository: sl<AuthRepository>()),
  );
  sl.registerLazySingleton(
    () => ForgotPasswordUseCase(repository: sl<AuthRepository>()),
  );
  sl.registerLazySingleton(
    () => CheckAuthStatusUseCase(repository: sl<AuthRepository>()),
  );
  sl.registerLazySingleton(
    () => LogoutUseCase(repository: sl<AuthRepository>()),
  );

  // Intro use cases
  sl.registerLazySingleton(
    () => CheckNetworkUseCase(repository: sl<IntroRepository>()),
  );
  sl.registerLazySingleton(
    () => CompleteIntroUseCase(repository: sl<IntroRepository>()),
  );

  // News use cases
  sl.registerLazySingleton(
    () => GetNewsUseCase(repository: sl<NewsRepository>()),
  );
  sl.registerLazySingleton(
    () => SearchNewsUseCase(repository: sl<NewsRepository>()),
  );
  sl.registerLazySingleton(
    () =>
        news_categories.GetCategoriesUseCase(repository: sl<NewsRepository>()),
  );

  // Bookmark use cases
  sl.registerLazySingleton(
    () => ToggleBookmarkUseCase(sl<BookmarkRepository>()),
  );
  sl.registerLazySingleton(
    () => CheckBookmarkUseCase(sl<BookmarkRepository>()),
  );

  //! BLoCs
  sl.registerFactory(
    () => AuthenticationBloc(
      loginUseCase: sl<LoginUseCase>(),
      registerUseCase: sl<RegisterUseCase>(),
      forgotPasswordUseCase: sl<ForgotPasswordUseCase>(),
      checkAuthStatusUseCase: sl<CheckAuthStatusUseCase>(),
      logoutUseCase: sl<LogoutUseCase>(),
      localizationCubit: sl<LocalizationCubit>(),
      authenticationService: sl<AuthenticationService>(),
    ),
  );

  // Intro BLoC
  sl.registerFactory(
    () => IntroBloc(
      checkNetworkUseCase: sl<CheckNetworkUseCase>(),
      completeIntroUseCase: sl<CompleteIntroUseCase>(),
    ),
  );

  // News BLoC
  sl.registerFactory(
    () => NewsBloc(
      getNewsUseCase: sl<GetNewsUseCase>(),
      searchNewsUseCase: sl<SearchNewsUseCase>(),
      getCategoriesUseCase: sl<news_categories.GetCategoriesUseCase>(),
    ),
  );

  // Shop data sources
  sl.registerLazySingleton<ShopRemoteDataSource>(
    () => ShopRemoteDataSourceImpl(dio: sl<DioClient>()),
  );

  // Shop repositories
  sl.registerLazySingleton<ShopRepository>(
    () => ShopRepositoryImpl(remoteDataSource: sl<ShopRemoteDataSource>()),
  );

  // Shop use cases
  sl.registerLazySingleton(
    () => shop_categories.GetCategoriesUseCase(sl<ShopRepository>()),
  );
  sl.registerLazySingleton(
    () => GetProductsByCategoryUseCase(sl<ShopRepository>()),
  );
  sl.registerLazySingleton(() => GetProductByIdUseCase(sl<ShopRepository>()));

  // Localization Cubit
  sl.registerFactory(() => LocalizationCubit());

  // Firebase Messaging Service - only on mobile platforms
  if (defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS) {
    sl.registerLazySingleton(() => FirebaseMessagingService());

    // Supabase FCM Service
    sl.registerLazySingleton<SupabaseFcmService>(
      () => SupabaseFcmServiceImpl(dio: sl<DioClient>()),
    );
  }

  // Location Service
  sl.registerLazySingleton<LocationService>(() => LocationService());

  // Share Page Service
  sl.registerLazySingleton<SharePageService>(() => SharePageService(routes));

  // Locations data sources
  sl.registerLazySingleton<LocationsRemoteDataSource>(
    () => LocationsRemoteDataSourceImpl(dio: sl<DioClient>()),
  );
  sl.registerLazySingleton<LocationsRepository>(
    () => LocationsRepositoryImpl(
      remoteDataSource: sl<LocationsRemoteDataSource>(),
    ),
  );

  //Event data sources
  sl.registerLazySingleton<EventsDatasource>(
    () => EventsDatasourceSupabase(dio: sl<DioClient>()),
  );
  sl.registerLazySingleton<EventsRepository>(
    () => EventsRepositorySupabase(
      networkInfo: sl<NetworkInfo>(),
      eventsDatasource: sl<EventsDatasource>(),
    ),
  );

  // Notification BLoC
  sl.registerFactory(() => NotificationBloc());

  // Location Cubit
  sl.registerLazySingleton(() {
    final locationCubit = LocationCubit(sl<LocationService>());
    // Initialize in background without blocking
    locationCubit.initialize();
    return locationCubit;
  });




  // Banners repository
  sl.registerLazySingleton<BannersRemoteDataSource>(
    () => BannersRemoteDataSourceImpl(dio: sl<DioClient>()),
  );
  sl.registerLazySingleton<BannersRepository>(
    () => BannersRepositoryImpl(remoteDataSource: sl<BannersRemoteDataSource>()),
  );
}
