import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import '../../../core/config/theme.dart';
import '../../../core/config/environment.dart';
import 'auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authStateProvider.notifier).login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      context.go('/patients');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.isLoading;
    final error = authState.error?.toString();
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 1024;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Row(
        children: [
          if (isDesktop)
            Expanded(
              flex: 3,
              child: Container(
                color: AppTheme.primaryColor,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.1,
                        child: CustomPaint(
                          painter: _GridPainter(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.xxl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.sm),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                ),
                                child: const Icon(
                                  BootstrapIcons.heart_pulse_fill,
                                  color: AppTheme.primaryColor,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              const Text(
                                'OpenHealth',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          const Text(
                            'Modern Healthcare\nManagement.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            'Streamlined clinical workflows, patient records, and hospital operations in one secure platform.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 18,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'v1.0.0 © 2024 OpenHealth Systems',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            flex: 2,
            child: Container(
              color: AppTheme.surfaceLight,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!isDesktop) ...[
                          const Icon(
                            BootstrapIcons.heart_pulse_fill,
                            color: AppTheme.primaryColor,
                            size: 48,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          const Text(
                            'OpenHealth',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                        ],
                        const Text(
                          'Staff Login',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          Environment.tenantName.isNotEmpty
                              ? 'Accessing ${Environment.tenantName}'
                              : 'Sign in to your facility account',
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppTheme.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextFormField(
                                controller: _emailController,
                                decoration: const InputDecoration(
                                  labelText: 'Email Address',
                                  prefixIcon: Icon(BootstrapIcons.envelope),
                                  hintText: 'name@hospital.com',
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) => 
                                  value == null || value.isEmpty ? 'Required' : null,
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              TextFormField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(BootstrapIcons.lock),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword 
                                        ? BootstrapIcons.eye_slash 
                                        : BootstrapIcons.eye,
                                    ),
                                    onPressed: () => 
                                      setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                ),
                                obscureText: _obscurePassword,
                                onFieldSubmitted: (_) => _login(),
                                validator: (value) => 
                                  value == null || value.isEmpty ? 'Required' : null,
                              ),
                              if (error != null) ...[
                                const SizedBox(height: AppSpacing.lg),
                                Container(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  decoration: BoxDecoration(
                                    color: AppTheme.errorColor.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(AppRadius.md),
                                    border: Border.all(color: AppTheme.errorColor.withOpacity(0.2)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(BootstrapIcons.exclamation_triangle, 
                                        color: AppTheme.errorColor, size: 20),
                                      const SizedBox(width: AppSpacing.md),
                                      Expanded(
                                        child: Text(
                                          error.contains('Invalid credentials') 
                                            ? 'The email or password you entered is incorrect.'
                                            : error,
                                          style: const TextStyle(
                                            color: AppTheme.errorColor,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: AppSpacing.xl),
                              SizedBox(
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : _login,
                                  child: isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('Sign In'),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              Row(
                                children: [
                                  const Expanded(child: Divider()),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                                    child: Text(
                                      'OR',
                                      style: TextStyle(
                                        color: AppTheme.textSecondaryLight.withOpacity(0.5),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const Expanded(child: Divider()),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              OutlinedButton.icon(
                                onPressed: () => context.go('/setup'),
                                icon: const Icon(BootstrapIcons.hospital, size: 18),
                                label: const Text('Switch Facility'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'System Admin?',
                              style: TextStyle(color: AppTheme.textSecondaryLight),
                            ),
                            TextButton(
                              onPressed: () => context.go('/admin/login'),
                              child: const Text('Admin Portal'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0;

    const spacing = 40.0;
    for (var i = 0.0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (var i = 0.0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
