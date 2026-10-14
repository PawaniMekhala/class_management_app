import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../providers/theme_provider.dart';
import '../screens/auth/sign_in_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  //   @override
  //   Widget build(BuildContext context) {
  //     return MaterialApp(
  //       title: 'Class Management App',
  //       debugShowCheckedModeBanner: false,

  //       theme: AppTheme.lightTheme,
  //       home: const SignInScreen(),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Class Management App',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const SignInScreen(),
          );
        },
      ),
    );
  }
}
