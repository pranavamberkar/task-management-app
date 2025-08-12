import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/task_service.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/task/task_bloc.dart';
import 'pages/onboarding_page.dart';
import 'pages/task_list_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Load stored login status
  final prefs = await SharedPreferences.getInstance();
  final bool? isLoggedIn = prefs.getBool("isLoggedIn");

  runApp(TaskManagerApp(isLoggedIn: isLoggedIn));
}

class TaskManagerApp extends StatelessWidget {
  final bool? isLoggedIn;
  const TaskManagerApp({super.key, this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(AuthService()),
        ),
        BlocProvider(
          create: (_) => TaskBloc(TaskService()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Task Manager',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          scaffoldBackgroundColor: Colors.white,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: isLoggedIn == true
            ? const TaskListPage()
            : const OnboardingPage(),
      ),
    );
  }
}
