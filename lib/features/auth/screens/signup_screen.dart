import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:locacharge/shared/styles/colors.dart';
import 'package:locacharge/shared/widgets/modern_card.dart';
import 'package:locacharge/shared/widgets/modern_buttons.dart';
import 'package:locacharge/shared/widgets/modern_input_fields.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nomController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nomController.dispose();
    super.dispose();
  }

  void _signup() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final phone = _emailController.text.trim();
      final password = _passwordController.text.trim();
      String phoneToEmail(String phone) =>
          phone.replaceAll('+', '').replaceAll(' ', '') + '@locacharge.com';
      final emailFictif = phoneToEmail(phone);
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailFictif,
          password: password,
        );
        final userId = FirebaseAuth.instance.currentUser!.uid;
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'id': userId,
          'phone': phone,
          'role': 'UserRole.client',
          'nomComplet': _nomController.text,
        });
        setState(() => _isLoading = false);
        context.go('/login'); // Rediriger après succès
      } catch (e) {
        // Handle error
        print('Erreur lors de la création de l\'utilisateur: $e');
        setState(() => _isLoading = false);
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
                  'Inscription',
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
                        controller: _nomController,
                        label: 'Nom',
                        hint: 'Votre nom',
                        prefixIcon: Icons.person_outline,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Nom requis' : null,
                      ),
                      const SizedBox(height: 16),
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
                        hint: 'Entrez un mot de passe',
                        prefixIcon: Icons.lock_outline,
                        obscureText: true,
                        validator: (value) => value == null || value.length < 6
                            ? 'Le mot de passe doit faire 6+ caractères'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      ModernTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirmer le mot de passe',
                        hint: 'Répétez le mot de passe',
                        prefixIcon: Icons.lock_outline,
                        obscureText: true,
                        validator: (value) => value != _passwordController.text
                            ? 'Les mots de passe ne correspondent pas'
                            : null,
                      ),
                      const SizedBox(height: 28),
                      _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _signup,
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
                                child: const Text('S\'INSCRIRE'),
                              ),
                            ),
                      const SizedBox(height: 24),
                      Center(
                        child: RichText(
                          text: TextSpan(
                            text: 'Vous avez déjà un compte ? ',
                            style: const TextStyle(
                                color: AppColors.textPrimary, fontSize: 16),
                            children: [
                              TextSpan(
                                text: 'Se connecter',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryColor,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    context.go('/login');
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
