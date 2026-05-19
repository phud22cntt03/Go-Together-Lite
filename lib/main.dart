import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/firestore_seeder.dart';
import 'theme/app_theme.dart';
import 'screens/welcome_screen.dart';
import 'screens/main_screen.dart';
import 'screens/trip_detail_screen.dart';
import 'screens/create_trip_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/my_trips_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/vehicle_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/trip_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Nạp dữ liệu mẫu vào Firestore (chỉ lần đầu)
  await FirestoreSeeder.seedAll();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const SmartCarpoolApp());
}

class SmartCarpoolApp extends StatelessWidget {
  const SmartCarpoolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TripProvider()),
      ],
      child: MaterialApp(
        title: 'Smart Carpool Connect',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const WelcomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/main': (context) => const MainScreen(),
          '/trip-detail': (context) => const TripDetailScreen(),
          '/create-trip': (context) => const CreateTripScreen(),
          '/my-trips': (context) => const MyTripsScreen(),
          '/notifications': (context) => const NotificationsScreen(),
          '/vehicles': (context) => const VehicleScreen(),
        },
      ),
    );
  }
}
