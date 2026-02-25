import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Auth
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/navigation/presentation/pages/main_shell_page.dart';

// Projects
import 'features/projects/presentation/providers/projects_provider.dart';
import 'features/projects/presentation/providers/project_details_provider.dart';
import 'features/projects/data/datasources/project_remote_datasource.dart';
import 'features/projects/data/repositories/project_repository_impl.dart';
import 'features/projects/domain/usecases/get_projects_usecase.dart';
import 'features/projects/domain/usecases/get_project_details_usecase.dart';

void main() {
  final authRepo = AuthRepositoryImpl();
  final loginUseCase = LoginUseCase(authRepo);

  final remoteDataSource = ProjectRemoteDataSource();
  final projectsRepo = ProjectRepositoryImpl(remoteDataSource);
  final getProjectsUseCase = GetProjectsUseCase(projectsRepo);
  final getProjectDetailsUseCase = GetProjectDetailsUseCase(projectsRepo);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(loginUseCase)..restoreSession(),
        ),
        ChangeNotifierProvider(create: (_) => ProjectsProvider(getProjectsUseCase)),
        ChangeNotifierProvider(
          create: (_) => ProjectDetailsProvider(getProjectDetailsUseCase),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF0E7490),
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'ERP Mobile App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFF4F8FB),
        appBarTheme: AppBarTheme(
          centerTitle: false,
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isInitializing) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return auth.isAuthenticated ? const MainShellPage() : const LoginPage();
        },
      ),
    );
  }
}
