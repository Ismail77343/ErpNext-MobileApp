import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:erp_mobile_app/core/constants/app_branding.dart';
import 'package:erp_mobile_app/core/localization/localization_extensions.dart';
import 'package:erp_mobile_app/core/utils/app_logger.dart';
import '../../../navigation/presentation/pages/main_shell_page.dart';
import '../providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool rememberMe = true;

  void login() async {
    final authProvider = context.read<AuthProvider>();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    AppLogger.auth('try login: $email');

    await authProvider.login(email, password, rememberMe: rememberMe);
    if (!mounted) return;

    if (authProvider.isAuthenticated) {
      AppLogger.auth('login success: $email');
      AppLogger.nav('navigate to home page');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainShellPage()),
      );
    } else {
      AppLogger.error('login failed: ${authProvider.error ?? "unknown error"}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? context.l10n.authLoginFailed),
        ),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEAF5FB), Color(0xFFF8FBFD)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(maxWidth: 240),
                          decoration: BoxDecoration(
                            color: AppBranding.ice,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
                          child: Image.asset(
                            AppBranding.fullLogoPath,
                            height: 72,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Text(
                                AppBranding.appName,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppBranding.navy,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          AppBranding.appName,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppBranding.navy,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.authSignInToContinue,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 22),
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.alternate_email_rounded),
                            border: OutlineInputBorder(),
                          ).copyWith(labelText: l10n.authEmail),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: l10n.authPassword,
                            prefixIcon: Icon(Icons.lock_outline_rounded),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Checkbox(
                              value: rememberMe,
                              onChanged: (value) {
                                setState(() => rememberMe = value ?? false);
                              },
                            ),
                            Text(l10n.authRememberMe),
                          ],
                        ),
                        const SizedBox(height: 8),
                        authProvider.isLoading
                            ? const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(),
                              )
                            : ElevatedButton.icon(
                                onPressed: login,
                                icon: const Icon(Icons.login_rounded),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                label: Text(l10n.authLogin),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
