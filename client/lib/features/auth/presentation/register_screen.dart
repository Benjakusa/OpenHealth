import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import '../../../core/config/theme.dart';
import 'auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _tenantNameController = TextEditingController();
  final _tenantCodeController = TextEditingController();
  final _tenantEmailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  String? _error;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _tenantNameController.dispose();
    _tenantCodeController.dispose();
    _tenantEmailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await ref.read(authStateProvider.notifier).register(
      tenantName: _tenantNameController.text.trim(),
      tenantCode: _tenantCodeController.text.trim().toUpperCase(),
      tenantEmail: _tenantEmailController.text.trim(),
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (result.success) {
        context.go('/patients');
      } else {
        setState(() => _error = result.error ?? 'Registration failed');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 1024;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Row(
        children: [
          if (isDesktop)
            Expanded(
              flex: 2,
              child: Container(
                color: AppTheme.primaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: () => context.go('/setup'),
                        icon: const Icon(BootstrapIcons.arrow_left, color: Colors.white),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      const Text(
                        'Join OpenHealth',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Set up your facility in minutes. Scale your healthcare services with modern tools.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 18,
                        ),
                      ),
                      const Spacer(),
                      _buildFeatureRow(BootstrapIcons.hospital, 'Multi-tenant Support'),
                      const SizedBox(height: AppSpacing.lg),
                      _buildFeatureRow(BootstrapIcons.people, 'Patient Management'),
                      const SizedBox(height: AppSpacing.lg),
                      _buildFeatureRow(BootstrapIcons.shield_check, 'Secure & Compliant'),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(
            flex: 3,
            child: Container(
              color: AppTheme.surfaceLight,
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (!isDesktop) ...[
                              IconButton(
                                alignment: Alignment.centerLeft,
                                onPressed: () => context.go('/setup'),
                                icon: const Icon(BootstrapIcons.arrow_left, color: AppTheme.primaryColor),
                              ),
                              const SizedBox(height: AppSpacing.md),
                            ],
                            const Text(
                              'Create Facility Account',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimaryLight,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxl),
                            
                            _buildSectionHeader('Facility Details'),
                            const SizedBox(height: AppSpacing.lg),
                            TextFormField(
                              controller: _tenantNameController,
                              decoration: const InputDecoration(
                                labelText: 'Hospital / Clinic Name',
                                prefixIcon: Icon(BootstrapIcons.building),
                              ),
                              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _tenantCodeController,
                                    decoration: const InputDecoration(
                                      labelText: 'Unique Code',
                                      hintText: 'e.g. CITY01',
                                      prefixIcon: Icon(BootstrapIcons.hash),
                                    ),
                                    textCapitalization: TextCapitalization.characters,
                                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: TextFormField(
                                    controller: _tenantEmailController,
                                    decoration: const InputDecoration(
                                      labelText: 'Official Email',
                                      prefixIcon: Icon(BootstrapIcons.envelope_at),
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: AppSpacing.xxl),
                            _buildSectionHeader('Administrator Details'),
                            const SizedBox(height: AppSpacing.lg),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _firstNameController,
                                    decoration: const InputDecoration(
                                      labelText: 'First Name',
                                      prefixIcon: Icon(BootstrapIcons.person),
                                    ),
                                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: TextFormField(
                                    controller: _lastNameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Last Name',
                                    ),
                                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Admin Email',
                                prefixIcon: Icon(BootstrapIcons.envelope),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _passwordController,
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      prefixIcon: const Icon(BootstrapIcons.lock),
                                      suffixIcon: IconButton(
                                        icon: Icon(_obscurePassword ? BootstrapIcons.eye_slash : BootstrapIcons.eye),
                                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                      ),
                                    ),
                                    obscureText: _obscurePassword,
                                    validator: (v) => v == null || v.length < 6 ? 'Min 6 chars' : null,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: TextFormField(
                                    controller: _confirmPasswordController,
                                    decoration: const InputDecoration(
                                      labelText: 'Confirm',
                                      prefixIcon: Icon(BootstrapIcons.lock_fill),
                                    ),
                                    obscureText: true,
                                    validator: (v) => v != _passwordController.text ? 'Mismatch' : null,
                                  ),
                                ),
                              ],
                            ),
                            
                            if (_error != null) ...[
                              const SizedBox(height: AppSpacing.lg),
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: AppTheme.errorColor.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                ),
                                child: Text(_error!, style: const TextStyle(color: AppTheme.errorColor)),
                              ),
                            ],
                            
                            const SizedBox(height: AppSpacing.xxl),
                            SizedBox(
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _register,
                                child: _isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text('Complete Registration'),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Center(
                              child: TextButton(
                                onPressed: () => context.go('/login'),
                                child: const Text('Already have an account? Sign In'),
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        const Divider(),
      ],
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.7), size: 20),
        const SizedBox(width: AppSpacing.md),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 16)),
      ],
    );
  }
}
