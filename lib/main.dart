import 'package:flutter/material.dart';

import 'pages/cart_page.dart';
import 'pages/checkout_page.dart';
import 'pages/home_page.dart';
import 'pages/menu_detail_page.dart';
import 'pages/menu_list_page.dart';
import 'pages/order_success_page.dart';
import 'state/cart_state.dart';

void main() {
  runApp(const KantinBuSariApp());
}

class KantinBuSariApp extends StatelessWidget {
  const KantinBuSariApp({super.key});

  @override
  Widget build(BuildContext context) {
    final lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFE64A19),
        brightness: Brightness.light,
        primary: const Color(0xFFE64A19),
        secondary: const Color(0xFFFFB300),
      ),
      scaffoldBackgroundColor: const Color(0xFFFFFAF6),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: false,
      ),
      textTheme: const TextTheme(
        titleMedium: TextStyle(fontWeight: FontWeight.w600),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        isDense: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
    );

    return CartScope(
      notifier: CartModel(),
      child: MaterialApp(
        title: 'Kantin Bu Sari',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        initialRoute: '/',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(
                  builder: (_) => const HomePage(), settings: settings);
            case '/menu':
              return MaterialPageRoute(
                  builder: (_) => const MenuListPage(), settings: settings);
            case '/detail':
              return MaterialPageRoute(
                  builder: (_) => const MenuDetailPage(), settings: settings);
            case '/cart':
              return MaterialPageRoute(
                  builder: (_) => const CartPage(), settings: settings);
            case '/checkout':
              return MaterialPageRoute(
                  builder: (_) => const CheckoutPage(), settings: settings);
            case '/success':
              return MaterialPageRoute(
                  builder: (_) => const OrderSuccessPage(), settings: settings);
            default:
              return MaterialPageRoute(
                  builder: (_) => const HomePage(), settings: settings);
          }
        },
      ),
    );
  }
}
