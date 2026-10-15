import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../providers/theme_provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/inputs/custom_text_field.dart';
import 'select_institute_screen.dart';
import 'register_institute_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    children: [
                      // Appearance icon
                      Align(
                        alignment: Alignment.topRight,
                        child: Consumer<ThemeProvider>(
                          builder: (context, themeProvider, child) {
                            return IconButton(
                              tooltip: themeProvider.isDarkMode
                                  ? 'Switch to light mode'
                                  : 'Switch to dark mode',
                              onPressed: themeProvider.toggleTheme,
                              icon: Icon(
                                themeProvider.isDarkMode
                                    ? Icons.light_mode_outlined
                                    : Icons.dark_mode_outlined,
                                color: Theme.of(context).colorScheme.onSurface,
                                size: 19,
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 62),

                      // Institute logo
                      Icon(
                        Icons.account_balance_outlined,
                        size: 43,
                        color: AppColors.primary,
                      ),

                      const SizedBox(height: 10),

                      Text(
                        'THE CLASS',
                        style: AppTextStyles.subHeading.copyWith(
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        'Institute Management System',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.caption.copyWith(fontSize: 9),
                      ),

                      const SizedBox(height: 36),

                      // Username or NIC
                      CustomTextField(
                        hint: 'Username or NIC',
                        icon: Icons.person_outline,
                        controller: usernameController,
                      ),

                      const SizedBox(height: 11),

                      // Password with visibility toggle
                      TextField(
                        controller: passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Sign in
                      PrimaryButton(
                        text: 'Sign in',
                        onPressed: () {
                          if (usernameController.text.trim().isEmpty ||
                              passwordController.text.isEmpty) {
                            _showMessage(
                              'Please enter your username and password.',
                            );
                            return;
                          }

                          // _showMessage(
                          //   'Authentication will be connected later.',
                          // );
                          // Temporary navigation until login API is connected
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SelectInstituteScreen(
                                userName: 'Kamala',
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 10),

                      // Divider with "or"
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outlineVariant,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              'or',
                              style: AppTextStyles.caption.copyWith(
                                fontSize: 9,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: AppColors.border)),
                        ],
                      ),

                      const SizedBox(height: 9),

                      // Google sign-in placeholder
                      SizedBox(
                        width: double.infinity,
                        height: 34,
                        child: OutlinedButton(
                          onPressed: () {
                            _showMessage(
                              'Google sign-in will be configured later.',
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .surface,
                            foregroundColor: Theme.of(context)
                                .colorScheme
                                .onSurface,
                            side: BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const FaIcon(
                                FontAwesomeIcons.google,
                                // color: Color(0xFF4285F4),
                                size: 18,
                              ),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  'Google සමඟින් ඉදිරියට යන්න',
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.caption.copyWith(
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Register institute placeholder
                      SizedBox(
                        width: double.infinity,
                        height: 29,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // _showMessage(
                            //   'Institute registration will be added later.',
                            // );

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const RegisterInstituteScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.domain_add_outlined, size: 14),
                          label: const Text(
                            'Register your institute',
                            style: TextStyle(fontSize: 10),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Server address
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.dns_outlined,
                            size: 12,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              'Server: http://localhost:5196/',
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.caption.copyWith(
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
