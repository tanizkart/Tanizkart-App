import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'state/cart_state.dart';
import 'state/navigation_state.dart';
import 'state/location_state.dart';
import 'state/auth_state.dart';
import 'features/splash/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const TanizkartApp());
}

class TanizkartApp extends StatelessWidget {
  const TanizkartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartState()),
        ChangeNotifierProvider(create: (_) => NavigationState()),
        ChangeNotifierProvider(create: (_) => LocationState()),
        ChangeNotifierProvider(create: (_) => AuthState()),
      ],
      child: MaterialApp(
        title: 'Tanizkart - Save money save time',
        debugShowCheckedModeBanner: false,
        theme: TanizTheme.lightTheme,
        builder: (context, child) {
          final media = MediaQuery.of(context);
          if (media.size.width > 540) {
            return Container(
              color: const Color(0xFF061024),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 460),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.45),
                        blurRadius: 36,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: ClipRect(
                    child: MediaQuery(
                      data: media.copyWith(
                        size: Size(460, media.size.height),
                      ),
                      child: child ?? const SizedBox(),
                    ),
                  ),
                ),
              ),
            );
          }
          return child ?? const SizedBox();
        },
        home: const SplashScreen(),
      ),
    );
  }
}
