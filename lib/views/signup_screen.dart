import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../core/app_colors.dart';
import '../core/popup_utils.dart';
import '../viewmodels/auth_viewmodel.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    if (authViewModel.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        PopupUtils.showCenterPopup(
          context: context,
          title: 'Error',
          message: authViewModel.errorMessage!,
          icon: Icons.error_outline,
          color: AppColors.error,
        );
        authViewModel.clearError();
      });
    }

    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.primary,
      appBar: AppBar(
        title: const Text('CineBook', style: TextStyle(color: Colors.white)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 24),
        decoration: BoxDecoration(
          color: colorScheme.background,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              
              // Custom Login / Sign Up Tab Mock
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => context.pushReplacement('/login'),
                    child: Text('Login', style: TextStyle(fontWeight: FontWeight.normal, color: colorScheme.onSurfaceVariant, fontSize: 18)),
                  ),
                  const SizedBox(width: 32),
                  Text('Sign Up', style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface, fontSize: 18)),
                ],
              ),
              const SizedBox(height: 48),

              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'John Doe',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'you@example.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '+94 77 123 4567',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Checkbox(value: false, onChanged: (v){}),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
                        children: [
                          const TextSpan(text: 'I agree to the '),
                          TextSpan(text: 'Terms of Service', style: TextStyle(color: colorScheme.primary)),
                          const TextSpan(text: ' and '),
                          TextSpan(text: 'Privacy Policy', style: TextStyle(color: colorScheme.primary)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              FilledButton(
                onPressed: authViewModel.isLoading 
                  ? null 
                  : () async {
                      if (_emailController.text.isEmpty || _passwordController.text.isEmpty || _nameController.text.isEmpty) {
                         PopupUtils.showCenterPopup(
                           context: context,
                           title: 'Validation Error',
                           message: 'Please fill all required fields',
                           icon: Icons.warning_amber_rounded,
                           color: AppColors.secondary,
                         );
                         return;
                      }
                      final success = await authViewModel.signUp(
                        _nameController.text.trim(),
                        _emailController.text.trim(), 
                        _passwordController.text.trim(),
                        _phoneController.text.trim()
                      );
                      if (success && mounted) {
                        await PopupUtils.showCenterPopup(
                          context: context,
                          title: 'Success',
                          message: 'Account created successfully!',
                          icon: Icons.check_circle_outline,
                          color: AppColors.success,
                        );
                        if (mounted) context.go('/home');
                      } else if (!success && mounted) {
                        PopupUtils.showCenterPopup(
                          context: context,
                          title: 'Sign Up Failed',
                          message: authViewModel.errorMessage ?? "Error occurred.",
                          icon: Icons.error_outline,
                          color: AppColors.error,
                        );
                      }
                  },
                child: authViewModel.isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Create Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
