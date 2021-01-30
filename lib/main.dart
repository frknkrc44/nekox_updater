import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:nekox_updater/routes/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static final Connectivity connectivity = Connectivity();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NekoX Releases',
      debugShowCheckedModeBanner: false,
      builder: (context, child) => ScrollConfiguration(
        behavior: _NoGlowScrollBehavior(),
        child: child,
      ),
      theme: ThemeData(
        primarySwatch: PRIMARY_COLOR,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }

  static const MaterialColor PRIMARY_COLOR = MaterialColor(0xFF4B6C85, {
    50: Color(0xFF4B6C85),
    100: Color(0xFF4B6C85),
    200: Color(0xFF4B6C85),
    300: Color(0xFF4B6C85),
    400: Color(0xFF4B6C85),
    500: Color(0xFF4B6C85),
    600: Color(0xFF4B6C85),
    700: Color(0xFF4B6C85),
    800: Color(0xFF4B6C85),
    900: Color(0xFF4B6C85),
  });
}

class _NoGlowScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
    BuildContext ctx,
    Widget child,
    AxisDirection dir,
  ) {
    return child;
  }
}
