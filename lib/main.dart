import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'models/user_profile.dart';
import 'screens/auth/auth_common.dart';
import 'screens/onboarding/activity_level_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/onboarding/personalize_screen.dart';
import 'screens/onboarding/profile_ready_screen.dart';
import 'screens/onboarding/weight_goal_screen.dart';
import 'services/notification_service.dart';

enum DebugStartScreen {
  normal,
  personalize,
  weightGoal,
  activityLevel,
  profileReady,
}

const DebugStartScreen _debugStartScreen = DebugStartScreen.normal;

AppUserProfile _debugProfile() {
  return AppUserProfile(
    uid: 'debug',
    fullName: 'Mey',
    email: 'mey123@gmail.com.kh',
    gender: 'Female',
    dateOfBirth: DateTime(2002, 5, 15),
    weightKg: 58,
    heightCm: 160,
    healthGoal: 'Lose Weight',
    targetWeightKg: 55,
    activityLevel: 'Sedentary',
    onboardingComplete: true,
  );
}

Widget _startScreen() {
  switch (_debugStartScreen) {
    case DebugStartScreen.personalize:
      return const PersonalizeScreen();
    case DebugStartScreen.weightGoal:
      return WeightGoalScreen(profile: _debugProfile());
    case DebugStartScreen.activityLevel:
      return ActivityLevelScreen(profile: _debugProfile());
    case DebugStartScreen.profileReady:
      return ProfileReadyScreen(profile: _debugProfile());
    case DebugStartScreen.normal:
      return const OnboardingScreen();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await NotificationService.instance.initialize();
  } on FirebaseException catch (error) {
    debugPrint('Firebase did not initialize: ${error.message}');
  } catch (error) {
    debugPrint('Firebase did not initialize: $error');
  }

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const FitBuddyApp(),
    ),
  );
}

class FitBuddyApp extends StatelessWidget {
  const FitBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // ignore: deprecated_member_use
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.green,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.paleGreen,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          surfaceTintColor: Colors.transparent,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.green, width: 1.4),
          ),
        ),
      ),
      home: _startScreen(),
    );
  }
}
