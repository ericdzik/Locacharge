import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:locacharge/core/services/auth_service.dart';
import 'package:locacharge/shared/styles/colors.dart';
import 'package:locacharge/shared/widgets/modern_buttons.dart';
import 'package:locacharge/shared/widgets/modern_input_fields.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final phone = _emailController.text.trim();
      final password = _passwordController.text.trim();
      String phoneToEmail(String phone) =>
          phone.replaceAll('+', '').replaceAll(' ', '') + '@locacharge.com';
      final emailFictif = phoneToEmail(phone);
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailFictif,
        password: password,
      );

      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de connexion: ${e.toString()}'),
            backgroundColor: AppColors.errorColor,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                // Logo placeholder
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surfaceColor,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(Icons.flash_on,
                        color: AppColors.errorColor, size: 44),
                  ),
                ),
                const SizedBox(height: 24),
                // Titre
                const Text(
                  'Connexion',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 32),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ModernTextField(
                        controller: _emailController,
                        label: 'Numéro de téléphone',
                        hint: 'Ex: 0102030405',
                        prefixIcon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Veuillez entrer un numéro'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      ModernTextField(
                        controller: _passwordController,
                        label: 'Mot de passe',
                        hint: 'Entrez votre mot de passe',
                        prefixIcon: Icons.lock_outline,
                        obscureText: true,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Veuillez entrer un mot de passe'
                            : null,
                      ),
                      const SizedBox(height: 28),
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                child: const Text('SE CONNECTER'),
                              ),
                            ),
                      const SizedBox(height: 24),
                      Center(
                        child: RichText(
                          text: TextSpan(
                            text: 'Vous n\'avez pas de compte ? ',
                            style: const TextStyle(
                                color: AppColors.textPrimary, fontSize: 16),
                            children: [
                              TextSpan(
                                text: 'Créer un compte',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryColor,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    context.go('/register');
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
