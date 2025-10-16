import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'features/welcome/views/welcome_view.dart';
import 'features/auth/views/login_view.dart';
import 'features/objects/views/objects_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Objetos Perdidos UPT',
      theme: ThemeData(
        primaryColor: const Color(0xFF003366),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF003366),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeView(),
        '/login': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          final isRegister = args != null && args['register'] == true;
          return LoginView(isRegisterMode: isRegister);
        },
        '/objects': (context) => const ObjectsView(),
      },
    );
  }
}
