import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;

  void _login() async {
    setState(() => loading = true);
    final res = await ApiService.login(email.text.trim(), password.text);
    setState(() => loading = false);
    if (res.containsKey('token')) {
      await ApiService.saveToken(res['token']);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      final msg = res['msg'] ?? res['error'] ?? 'Login failed';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    backgroundColor: const Color.fromARGB(237, 197, 226, 237),
      appBar: AppBar(title: const Text('QuickNotes — Login')),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 600,
            height: 400,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
              ],
            ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          const Text(
            'LogIn',
           style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          TextField(
            controller: email,
            decoration: InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[100],
            ),
            ),
            const SizedBox(height:24),
          TextField(controller: password,
           obscureText: true, 
           decoration: InputDecoration(labelText: 'Password',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[100],
                    ),),
          const SizedBox(height: 30),
          SizedBox(
            width: 350,
            height: 50,
            child: ElevatedButton(
  onPressed: loading ? null : _login,
  style: ElevatedButton.styleFrom(
    backgroundColor: Color.fromARGB(255, 3, 188, 169), // Button color
    foregroundColor: Colors.white,  // Text/icon color
    padding: const EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
  child: const Text(
    'Login',
    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  ),
),

          ),
          const SizedBox(height: 30),
          
          TextButton(onPressed: () => Navigator.pushNamed(context, '/register'), child: const Text('Create an account'))
        ]),
        
      ),
        ),
      ),
    );
  }
}
