// ==================== lib/main.dart ====================
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:projet_flutter/viewsmodels/login_viewmodel.dart';
import 'package:provider/provider.dart';
import 'constants/app_colors.dart';
import 'constants/app_routes.dart';
import 'viewsmodels/home_viewmodel.dart';
import 'viewsmodels/etudiant_viewmodel.dart';
import 'viewsmodels/gerant_viewmodel.dart';
import 'views/home/home_page.dart';
import 'views/etudiant/etudiant_page.dart';
import 'views/gerant/login_page.dart';
import 'views/gerant/gerant_page.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<FirestoreService>(create: (_) => FirestoreService()),
      ],
      child: const CantineApp(),
    ),
  );
}

class CantineApp extends StatelessWidget {
  const CantineApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cantine Université',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      initialRoute: AppRoutes.home,
      routes: {
        AppRoutes.home: (context) => ChangeNotifierProvider(
              create: (_) => HomeViewModel(),
              child: const HomePage(),
            ),
        AppRoutes.etudiant: (context) => ChangeNotifierProvider(
              create: (context) => EtudiantViewModel(), // ✅ SANS paramètre
              child: const EtudiantPage(),
            ),
        AppRoutes.loginGerant: (context) => ChangeNotifierProvider(
              create: (context) => LoginViewModel(
                authService: context.read(),
              ),
              child: const LoginPage(),
            ),
        AppRoutes.gerant: (context) => ChangeNotifierProvider(
              create: (context) => GerantViewModel(), // ✅ SANS paramètre
              child: const GerantPage(),
            ),
      },
    );
  }
}