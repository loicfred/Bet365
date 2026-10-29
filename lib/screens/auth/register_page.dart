import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/widgets.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}
class _RegisterPageState extends State<RegisterPage> {
  final auth = AuthService();
  final email = TextEditingController(), pass = TextEditingController(), confirm = TextEditingController();

  void register() async {
    if (pass.text != confirm.text) { popup(context, 'Passwords do not match'); return; }
    if (await attempt(context, () => auth.signUp(email.text, pass.text), 'Registration') && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(text: 'Sign Up Here', body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        field(email, 'Email'),
        field(pass, 'Password', hide: true),
        field(confirm, 'Confirm Password', hide: true),
        const SizedBox(height: 8),
        yellowButton('Register', register),
      ],
    ));
  }
}