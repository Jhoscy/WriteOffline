import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'presentation/screens/projects/project_list_screen.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  try {
    const env = String.fromEnvironment('ENV', defaultValue: 'local');
    debugPrint('Debug - Env: $env');
    await dotenv.load(fileName: './environments/.env.$env');
  } catch (e) {
    debugPrint('Warning: Could not load .env file: $e');
    debugPrint('The app will use empty values for Appwrite configuration.');
    debugPrint('Please create a .env file in the environments/ folder.');
  }
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    
    return MaterialApp(
      title: 'Write Offline: Projects & Tasks',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const ProjectListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
