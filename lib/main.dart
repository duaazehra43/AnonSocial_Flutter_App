import 'package:anonymous_app/auth/authService.dart';
import 'package:anonymous_app/views/home_Screen.dart';
import 'package:anonymous_app/views/login_Screen.dart';
import 'package:anonymous_app/view_model/chat_detail_view_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>(create: (_) => AuthService()),
          ChangeNotifierProvider<ChatDetailViewModel>(
              create: (_) => ChatDetailViewModel()),
        ],
        child: MaterialApp(
          home: Consumer<AuthService>(
            builder: (context, auth, _) {
              return auth.isAuthenticated ? HomeScreen() : LoginScreen();
            },
          ),
          debugShowCheckedModeBanner: false,
        ));
  }
}
