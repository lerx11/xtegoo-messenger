import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/auth/phone_auth_screen.dart';
import '../../presentation/screens/auth/otp_screen.dart';
import '../../presentation/screens/auth/username_setup_screen.dart';
import '../../presentation/screens/main/main_shell.dart';
import '../../presentation/screens/chats/chats_screen.dart';
import '../../presentation/screens/chats/chat_screen.dart';
import '../../presentation/screens/calls/calls_history_screen.dart';
import '../../presentation/screens/calls/call_screen.dart';
import '../../presentation/screens/translate/translator_screen.dart';
import '../../presentation/screens/marketplace/marketplace_screen.dart';
import '../../presentation/screens/marketplace/product_screen.dart';
import '../../presentation/screens/marketplace/orders_screen.dart';
import '../../presentation/screens/calendar/calendar_screen.dart';
import '../../presentation/screens/calendar/event_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/profile/edit_profile_screen.dart';
import '../../presentation/screens/business/business_profile_screen.dart';
import '../../presentation/screens/business/services_catalog_screen.dart';
import '../../presentation/screens/business/booking_screen.dart';
import '../../presentation/screens/esim/esim_screen.dart';
import '../../presentation/screens/search/search_screen.dart';
import '../../presentation/screens/story/story_viewer_screen.dart';
import '../../presentation/screens/story/create_story_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/auth/phone',
        builder: (context, state) => const PhoneAuthScreen(),
      ),
      GoRoute(
        path: '/auth/otp',
        builder: (context, state) => const OtpScreen(),
      ),
      GoRoute(
        path: '/auth/username',
        builder: (context, state) => const UsernameSetupScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home/chats',
            builder: (context, state) => const ChatsScreen(),
          ),
          GoRoute(
            path: '/home/calls',
            builder: (context, state) => const CallsHistoryScreen(),
          ),
          GoRoute(
            path: '/home/translate',
            builder: (context, state) => const TranslatorScreen(),
          ),
          GoRoute(
            path: '/home/marketplace',
            builder: (context, state) => const MarketplaceScreen(),
          ),
          GoRoute(
            path: '/home/calendar',
            builder: (context, state) => const CalendarScreen(),
          ),
          GoRoute(
            path: '/home/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/chat/:id',
        builder: (context, state) => ChatScreen(chatId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/chat/group/:id',
        builder: (context, state) => ChatScreen(chatId: state.pathParameters['id']!, isGroup: true),
      ),
      GoRoute(
        path: '/call/:userId',
        builder: (context, state) => CallScreen(userId: state.pathParameters['userId']!),
      ),
      GoRoute(
        path: '/profile/:id',
        builder: (context, state) => ProfileScreen(userId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/business/:id',
        builder: (context, state) => BusinessProfileScreen(businessId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/business/:id/services',
        builder: (context, state) => ServicesCatalogScreen(businessId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/product/:id',
        builder: (context, state) => ProductScreen(productId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/booking/:serviceId',
        builder: (context, state) => BookingScreen(serviceId: state.pathParameters['serviceId']!),
      ),
      GoRoute(
        path: '/story/:userId',
        builder: (context, state) => StoryViewerScreen(userId: state.pathParameters['userId']!),
      ),
      GoRoute(
        path: '/marketplace/category/:id',
        builder: (context, state) => MarketplaceScreen(categoryId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/calendar/event/:id',
        builder: (context, state) => EventScreen(eventId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/esim',
        builder: (context, state) => const EsimScreen(),
      ),
      GoRoute(
        path: '/translate',
        builder: (context, state) => const TranslatorScreen(fullScreen: true),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrdersScreen(),
      ),
      GoRoute(
        path: '/story/create',
        builder: (context, state) => const CreateStoryScreen(),
      ),
    ],
  );
});
