import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../services/auth_service.dart';
import '../../widgets/widgets.dart';
import 'register_page.dart';
import '../app/customer_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}
class _LoginPageState extends State<LoginPage> {
  final auth = AuthService();
  final email = TextEditingController(), pass = TextEditingController();

  void login() async {
    if (await attempt(context, () => auth.signIn(email.text, pass.text), 'Login') && mounted) {
      goReplace(context, CustomerPage(email: email.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(text: 'Bet365 Login', body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(CupertinoIcons.sportscourt_fill, size: 80, color: Colors.yellow),
        const SizedBox(height: 20),
        field(email, 'Email'),
        field(pass, 'Password', hide: true),
        const SizedBox(height: 8),
        yellowButton('Login', login),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text("Don't have an account? ", style: TextStyle(color: Colors.white)),
          LinkText('SignUp', () => go(context, const RegisterPage())),
        ]),
      ],
    ));
  }
}