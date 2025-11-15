import 'package:app/core/navigation/routes_name.dart';
import 'package:app/core/navigation/widgets/navigation_menu.dart';
import 'package:app/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:app/features/auth/presentation/pages/signup_page.dart';
import 'package:app/features/events/presentation/events.dart';
import 'package:app/features/events/presentation/events_details.dart';
import 'package:app/features/locations/presentations/pages/locations_categories_page.dart';
import 'package:app/features/locations/presentations/pages/locations_details_page.dart';
import 'package:app/features/locations/presentations/pages/search_locations_page.dart';
import 'package:app/features/locations/presentations/pages/selected_location_category_page.dart';
import 'package:app/features/news/presentation/pages/news_detail_page.dart';
import 'package:app/features/news/presentation/pages/saved_articles_page.dart';
import 'package:app/features/shop/domain/entities/product_category_entity.dart';
import 'package:app/features/shop/domain/entities/product_entity.dart';
import 'package:app/features/shop/presentation/pages/categories_page.dart';
import 'package:app/features/shop/presentation/pages/products_page.dart';
import 'package:app/features/shop/presentation/pages/product_detail_page.dart';
import 'package:app/features/shop/presentation/pages/search_products_page.dart';
import 'package:app/features/cart/presentation/pages/cart_page.dart';
import 'package:app/features/checkout/presentation/pages/checkout_page.dart';
import 'package:app/features/checkout/presentation/pages/payment_webview.dart';
import 'package:app/features/contract_generation/presentation/pages/contract_generation_page.dart';
import 'package:app/features/contract_generation/presentation/pages/single_field_flow_page.dart';
import 'package:app/features/contract_generation/presentation/pages/order_confirmation_demo_page.dart';
import 'package:app/features/contract_generation/presentation/pages/order_completion_demo_page.dart';
import 'package:app/features/contract_generation/presentation/pages/printer_settings_page.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/intro/presentation/pages/intro_page.dart';
import '../../features/news/presentation/pages/news_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';

final routes = GoRouter(
  initialLocation: AppRoutesNames.intro.path,
  restorationScopeId: 'app',
  redirect: (context, state) {
    // If we're at the root and not authenticated, stay at intro
    if (state.matchedLocation == AppRoutesNames.intro.path) {
      return null;
    }

    // If we're navigating to main sections, ensure proper routing
    if (state.matchedLocation == '/') {
      return AppRoutesNames.news.path;
    }

    return null;
  },
  routes: [
    GoRoute(
      path: AppRoutesNames.intro.path,
      name: AppRoutesNames.intro.name,
      builder: (context, state) => const IntroPage(),
      routes: [
        GoRoute(
          path: AppRoutesNames.login.path,
          name: AppRoutesNames.login.name,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: AppRoutesNames.register.path,
          name: AppRoutesNames.register.name,
          builder: (context, state) => const SignupPage(),
        ),
        GoRoute(
          path: AppRoutesNames.forgotPassword.path,
          name: AppRoutesNames.forgotPassword.name,
          builder: (context, state) => const ForgotPasswordPage(),
        ),
        GoRoute(
          path: '${AppRoutesNames.paymentWebView.path}/:url',
          name: AppRoutesNames.paymentWebView.name,
          builder:
              (context, state) => PaymentWebView(
                url: Uri.decodeComponent(state.pathParameters['url']!),
              ),
        ),
      ],
    ),
    GoRoute(
      path: AppRoutesNames.home.path,
      name: AppRoutesNames.home.name,
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: AppRoutesNames.contractGeneration.path,
      name: AppRoutesNames.contractGeneration.name,
      builder: (context, state) => const ContractGenerationPage(),
    ),
    GoRoute(
      path: AppRoutesNames.contractGenerationSingleField.path,
      name: AppRoutesNames.contractGenerationSingleField.name,
      builder: (context, state) => const SingleFieldFlowPage(),
    ),
    GoRoute(
      path: AppRoutesNames.printerSettings.path,
      name: AppRoutesNames.printerSettings.name,
      builder: (context, state) => const PrinterSettingsPage(),
    ),
    GoRoute(
      path: AppRoutesNames.orderConfirmationDemo.path,
      name: AppRoutesNames.orderConfirmationDemo.name,
      builder: (context, state) => const OrderConfirmationDemoPage(),
    ),
    GoRoute(
      path: AppRoutesNames.orderCompletion.path,
      name: AppRoutesNames.orderCompletion.name,
      builder: (context, state) => const OrderCompletionDemoPage(),
    ),
    ShellRoute(
      pageBuilder: (context, state, child) {
        return NoTransitionPage(
          child: NavigationMenu(
            currentLocation: state.fullPath ?? state.matchedLocation,
            parentContext: context,
            child: child,
          ),
        );
      },
      routes: [
        // News route
        GoRoute(
          path: AppRoutesNames.news.path,
          name: AppRoutesNames.news.name,
          pageBuilder:
              (context, state) => NoTransitionPage(
                key: state.pageKey,
                restorationId: 'news_page',
                child: const NewsPage(),
              ),
          routes: [
            GoRoute(
              path: AppRoutesNames.savedArticles.path,
              name: AppRoutesNames.savedArticles.name,
              pageBuilder:
                  (context, state) => NoTransitionPage(
                    key: state.pageKey,
                    restorationId: 'news_page',
                    child: const SavedArticlesPage(),
                  ),
            ),
            GoRoute(
              path: '${AppRoutesNames.newsDetails.path}/:id',
              name: AppRoutesNames.newsDetails.name,
              pageBuilder:
                  (context, state) => NoTransitionPage(
                    key: state.pageKey,
                    restorationId: 'news_page',
                    child: NewsDetailPage(id: state.pathParameters['id']!),
                  ),
            ),
          ],
        ),

        // Shop route
        GoRoute(
          path: AppRoutesNames.shop.path,
          name: AppRoutesNames.shop.name,
          pageBuilder:
              (context, state) => NoTransitionPage(
                key: state.pageKey,
                restorationId: 'shop_page',
                child: const CategoriesPage(),
              ),
          routes: [
            GoRoute(
              path: AppRoutesNames.products.path,
              name: AppRoutesNames.products.name,
              pageBuilder:
                  (context, state) => NoTransitionPage(
                    key: state.pageKey,
                    restorationId: 'shop_page',
                    child: ProductsPage(
                      category: state.extra as ProductCategoryEntity,
                    ),
                  ),
            ),
            GoRoute(
              path: AppRoutesNames.productDetails.path,
              name: AppRoutesNames.productDetails.name,
              pageBuilder:
                  (context, state) => NoTransitionPage(
                    key: state.pageKey,
                    restorationId: 'shop_page',
                    child: ProductDetailPage(
                      product: state.extra as ProductEntity,
                    ),
                  ),
            ),
            GoRoute(
              path: AppRoutesNames.searchProducts.path,
              name: AppRoutesNames.searchProducts.name,
              pageBuilder:
                  (context, state) => NoTransitionPage(
                    key: state.pageKey,
                    restorationId: 'shop_page',
                    child: const SearchProductsPage(),
                  ),
            ),
          ],
        ),

        // Locations route
        GoRoute(
          path: AppRoutesNames.locations.path,
          name: AppRoutesNames.locations.name,
          pageBuilder:
              (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const LocationsCategoriesPage(),
              ),
          routes: [
            GoRoute(
              path: AppRoutesNames.searchLocations.path,
              name: AppRoutesNames.searchLocations.name,
              pageBuilder:
                  (context, state) => NoTransitionPage(
                    key: state.pageKey,
                    child: const SearchLocationsPage(),
                  ),
            ),
          ],
        ),
        GoRoute(
          path: '${AppRoutesNames.selectedLocationCategory.path}/:id',
          name: AppRoutesNames.selectedLocationCategory.name,
          pageBuilder:
              (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: SelectedLocationCategoryPage(
                  categoryId: state.pathParameters['id']!,
                ),
              ),
        ),

        GoRoute(
          path: '${AppRoutesNames.locationsDetails.path}/:id',
          name: AppRoutesNames.locationsDetails.name,
          pageBuilder:
              (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: LocationsDetailsPage(
                  locationId: state.pathParameters['id']!,
                ),
              ),
        ),

        // Events route
        GoRoute(
          path: AppRoutesNames.events.path,
          name: AppRoutesNames.events.name,
          pageBuilder:
              (context, state) => NoTransitionPage(
                key: state.pageKey,
                child: const EventsPage(),
              ),
          routes: [
            GoRoute(
              path: AppRoutesNames.eventDetails.path,
              name: AppRoutesNames.eventDetails.name,
              pageBuilder:
                  (context, state) => NoTransitionPage(
                    key: state.pageKey,
                    child: EventDetailPage(id: state.pathParameters['id']!),
                  ),
            ),
          ],
        ),

        // Profile route
        GoRoute(
          path: AppRoutesNames.profile.path,
          name: AppRoutesNames.profile.name,
          pageBuilder:
              (context, state) => NoTransitionPage(
                key: state.pageKey,
                restorationId: 'profile_page',
                child: const ProfilePage(),
              ),
        ),

        // Cart route
        GoRoute(
          path: AppRoutesNames.cart.path,
          name: AppRoutesNames.cart.name,
          pageBuilder:
              (context, state) => NoTransitionPage(
                key: state.pageKey,
                restorationId: 'cart_page',
                child: const CartPage(),
              ),
          routes: [
            GoRoute(
              path: AppRoutesNames.checkout.path,
              name: AppRoutesNames.checkout.name,
              builder: (context, state) => const CheckoutPage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
