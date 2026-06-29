import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation_holder.dart';
import 'services/api_service.dart';
import 'services/notification_service.dart';
import 'widgets/valryze_design.dart';

// Global ValueNotifier to trigger theme updates instantly across the app
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientation to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Initialize date formatting for Indonesian locale
  await initializeDateFormatting('id_ID', null);

  // Initialize Firebase and push notifications
  await NotificationService.initialize();

  // Check if user is logged in
  final bool loggedIn = await ApiService.isLoggedIn();

  runApp(MyApp(isLoggedIn: loggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        final isDark = currentMode == ThemeMode.dark;

        // Set status bar colors adaptively
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          systemNavigationBarColor: isDark
              ? ValryzeDesign.darkBackground
              : ValryzeDesign.background,
          systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ));

        return MaterialApp(
          navigatorKey: navigatorKey,
          title: 'VALRYZE Smart HR Portal',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          // 1. LIGHT THEME DEFINITION
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: ValryzeDesign.background,
            textTheme: GoogleFonts.plusJakartaSansTextTheme(
              ThemeData.light().textTheme,
            ),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF06B6D4), // VALRYZE Cyan
              secondary: Color(0xFF10B981), // VALRYZE Emerald
              surface: Colors.white,
              background: Color(0xFFEFF6FF),
              error: Color(0xFFEF4444),
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onSurface: Color(0xFF0F172A), // Slate 900
            ),
            cardTheme: CardThemeData(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: const Color(0xFFDBEAFE),
                  width: 1,
                ),
              ),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF071830),
              elevation: 0,
              centerTitle: true,
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.2,
              ),
              iconTheme: IconThemeData(color: Colors.white),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF06B6D4),
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFDBEAFE)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFDBEAFE)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF06B6D4), width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFEF4444)),
              ),
              labelStyle: const TextStyle(color: Color(0xFF64748B)),
              hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
            ),
            useMaterial3: true,
          ),
          // 2. DARK THEME DEFINITION
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: ValryzeDesign.darkBackground,
            textTheme: GoogleFonts.plusJakartaSansTextTheme(
              ThemeData.dark().textTheme,
            ),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF06B6D4), // VALRYZE Cyan
              secondary: Color(0xFF10B981), // VALRYZE Emerald
              surface: Color(0xFF0D1F38),
              background: Color(0xFF071524),
              error: Color(0xFFEF4444),
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onSurface: Color(0xFFE2E8F0),
            ),
            cardTheme: CardThemeData(
              color: const Color(0xFF0D1F38),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: const Color(0xFF06B6D4).withOpacity(0.12), // Subtle Cyan Glow
                  width: 1,
                ),
              ),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF071830), // VALRYZE Topbar Navy
              elevation: 0,
              centerTitle: true,
              titleTextStyle: TextStyle(
                color: Color(0xFFF1F5F9),
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.2,
              ),
              iconTheme: IconThemeData(color: Color(0xFFF1F5F9)),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF06B6D4),
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFF0A192D),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: const Color(0xFF06B6D4).withOpacity(0.12)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: const Color(0xFF06B6D4).withOpacity(0.12)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF06B6D4), width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFEF4444)),
              ),
              labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
              hintStyle: const TextStyle(color: Color(0xFF475569)),
            ),
            useMaterial3: true,
          ),
          home: isLoggedIn ? const MainNavigationHolder() : const LoginScreen(),
        );
      },
    );
  }
}
