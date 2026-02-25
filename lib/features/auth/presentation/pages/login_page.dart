import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
        SnackBar(content: Text(authProvider.error ?? "Login Failed")),
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

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "ERP Mobile Login",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                Checkbox(
                  value: rememberMe,
                  onChanged: (value) {
                    setState(() => rememberMe = value ?? false);
                  },
                ),
                const Text("Remember me"),
              ],
            ),
            const SizedBox(height: 8),
            authProvider.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: login,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text("Login"),
                  ),
          ],
        ),
      ),
    );
  }
}
