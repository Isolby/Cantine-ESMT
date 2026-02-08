import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'constants/app_routes.dart';
import 'constants/app_colors.dart';
import 'services/fcm_service.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';

// Import des ViewModels
import 'viewsmodels/home_viewmodel.dart';
import 'viewsmodels/gerant_viewmodel.dart';
import 'viewsmodels/etudiant_viewmodel.dart';
import 'viewsmodels/login_viewmodel.dart';
import 'viewsmodels/manage_plats_viewmodel.dart';
import 'viewsmodels/add_plat_viewmodel.dart';
import 'viewsmodels/edit_plat_viewmodel.dart';

// Import des pages
import 'views/home/home_page.dart';
import 'views/gerant/gerant_page.dart';
import 'views/gerant/login_page.dart';
import 'views/etudiant/etudiant_page.dart';
import 'views/debug/notification_test_page.dart';
import 'views/debug/fcm_diagnostics_page.dart';
import 'views/debug/test_broadcast_page.dart';

// ✅ Handler pour les messages en arrière-plan
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📨 Message en arrière-plan reçu: ${message.notification?.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Configurer le handler pour messages en arrière-plan
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Initialiser FCM
  await FCMService().initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Créer les instances des services
    final authService = AuthService();
    final firestoreService = FirestoreService();

    return MultiProvider(
      providers: [
        // Services
        Provider<AuthService>.value(value: authService),
        Provider<FirestoreService>.value(value: firestoreService),

        // ViewModels
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => GerantViewModel()),
        ChangeNotifierProvider(create: (_) => EtudiantViewModel()),
        ChangeNotifierProvider(create: (context) => LoginViewModel(authService: authService)),
        ChangeNotifierProvider(create: (context) => ManagePlatsViewModel(firestoreService: firestoreService)),
        ChangeNotifierProvider(create: (_) => AddPlatViewModel()),
        ChangeNotifierProvider(create: (_) => EditPlatViewModel()),
      ],
      child: MaterialApp(
        title: 'Cantine App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppColors.primary,
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          useMaterial3: true,
        ),
        initialRoute: AppRoutes.home,
        routes: {
          AppRoutes.home: (context) => const HomePage(),
          AppRoutes.loginGerant: (context) => const LoginPage(),
          AppRoutes.gerant: (context) => const GerantPage(),
          AppRoutes.etudiant: (context) => const EtudiantPage(),
          '/test-notifications': (context) => const NotificationTestPage(),
          '/fcm-diagnostics': (context) => const FCMDiagnosticsPage(),
          '/test-broadcast': (context) => const TestBroadcastPage(),
        },
      ),
    );
  }
}