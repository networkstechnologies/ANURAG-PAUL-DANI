import 'package:flutter/material.dart';
import 'src/config.dart';
import 'src/theme.dart';
import 'src/state/session.dart';
import 'src/screens/login_screen.dart';
import 'src/screens/company_picker_screen.dart';
import 'src/screens/home_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Session.instance.load();
  runApp(const AkApp());
}

class AkApp extends StatelessWidget {
  const AkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AkTheme.theme,
      home: const _Root(),
    );
  }
}

class _Root extends StatelessWidget {
  const _Root();
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Session.instance,
      builder: (context, _) {
        final s = Session.instance;
        if (s.token == null) return const LoginScreen();
        if (s.companyId == null) return const CompanyPickerScreen();
        return const HomeShell();
      },
    );
  }
}
