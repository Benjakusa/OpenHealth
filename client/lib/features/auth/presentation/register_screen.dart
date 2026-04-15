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
  
  // Registration Type
  String _regType = 'ORGANIZATION'; // ORGANIZATION, STAFF

  // Organization Controllers
  final _orgNameController = TextEditingController();
  final _numClinicsController = TextEditingController(text: '1');
  final List<TextEditingController> _clinicNameControllers = [TextEditingController()];
  final List<TextEditingController> _clinicAddressControllers = [TextEditingController()];
  
  // Staff/Common Controllers
  final _clinicCodeController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  int _currentStep = 0;
  bool _isLoading = false;
  String? _error;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _orgNameController.dispose();
    _numClinicsController.dispose();
    for (var c in _clinicNameControllers) {
      c.dispose();
    }
    for (var c in _clinicAddressControllers) {
      c.dispose();
    }
    _clinicCodeController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updateClinicCount(String value) {
    final count = int.tryParse(value) ?? 1;
    if (count < 1) return;
    
    setState(() {
      if (count > _clinicNameControllers.length) {
        for (int i = _clinicNameControllers.length; i < count; i++) {
          _clinicNameControllers.add(TextEditingController());
          _clinicAddressControllers.add(TextEditingController());
        }
      } else if (count < _clinicNameControllers.length) {
        for (int i = _clinicNameControllers.length - 1; i >= count; i--) {
          _clinicNameControllers[i].dispose();
          _clinicAddressControllers[i].dispose();
          _clinicNameControllers.removeAt(i);
          _clinicAddressControllers.removeAt(i);
        }
      }
    });
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (_regType == 'ORGANIZATION') {
        final List<Map<String, dynamic>> clinics = [];
        for (int i = 0; i < _clinicNameControllers.length; i++) {
          clinics.add({
            'name': _clinicNameControllers[i].text.trim(),
            'address': {'street': _clinicAddressControllers[i].text.trim()},
          });
        }

        final result = await ref.read(authStateProvider.notifier).tenantRegister(
          organizationName: _orgNameController.text.trim(),
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          numberOfClinics: int.parse(_numClinicsController.text),
          clinics: clinics,
        );

        if (mounted) {
          if (result.success) {
            context.go('/patients');
          } else {
            setState(() => _error = result.error);
          }
        }
      } else {
        final result = await ref.read(authStateProvider.notifier).register(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          facilityCode: _clinicCodeController.text.trim().toUpperCase(),
          role: 'DOCTOR', // Default role for staff registration demo
        );

        if (mounted) {
          if (result.success) {
            if (result.error != null) {
              // Show success message and redirect
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(result.error!), duration: const Duration(seconds: 5)),
              );
              context.go('/login');
            } else {
              context.go('/patients');
            }
          } else {
            setState(() => _error = result.error);
          }
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                              'Join OpenHealth',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimaryLight,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxl),

                            // Type Selection
                            _buildTypeSelection(),
                            const SizedBox(height: AppSpacing.xxl),

                            if (_regType == 'ORGANIZATION') ...[
                              _buildOrganizationFields(),
                            ] else ...[
                              _buildStaffFields(),
                            ],
                            
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
                                labelText: 'Email Address',
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

  Widget _buildTypeSelection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          _buildTypeTab('ORGANIZATION', 'New Organization', BootstrapIcons.building),
          _buildTypeTab('STAFF', 'Join Clinic', BootstrapIcons.person_plus),
        ],
      ),
    );
  }

  Widget _buildTypeTab(String type, String label, IconData icon) {
    final isSelected = _regType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _regType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            boxShadow: isSelected ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ] : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondaryLight),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrganizationFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader('Organization Details'),
        const SizedBox(height: AppSpacing.lg),
        TextFormField(
          controller: _orgNameController,
          decoration: const InputDecoration(
            labelText: 'Organization Name',
            prefixIcon: Icon(BootstrapIcons.briefcase),
          ),
          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
        ),
        const SizedBox(height: AppSpacing.md),
        TextFormField(
          controller: _numClinicsController,
          decoration: const InputDecoration(
            labelText: 'Number of Clinics',
            prefixIcon: Icon(BootstrapIcons.hospital),
            hintText: 'e.g. 5',
          ),
          keyboardType: TextInputType.number,
          onChanged: _updateClinicCount,
          validator: (v) => v == null || int.tryParse(v) == null ? 'Invalid number' : null,
        ),
        const SizedBox(height: AppSpacing.xxl),
        _buildSectionHeader('Clinic Details'),
        const SizedBox(height: AppSpacing.lg),
        ...List.generate(_clinicNameControllers.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Clinic #${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _clinicNameControllers[index],
                  decoration: const InputDecoration(
                    labelText: 'Clinic Name',
                    prefixIcon: Icon(BootstrapIcons.building),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _clinicAddressControllers[index],
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    prefixIcon: Icon(BootstrapIcons.geo_alt),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStaffFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader('Clinic Details'),
        const SizedBox(height: AppSpacing.lg),
        TextFormField(
          controller: _clinicCodeController,
          decoration: const InputDecoration(
            labelText: 'Clinic Code',
            prefixIcon: Icon(BootstrapIcons.hash),
            hintText: 'Enter the 4-digit code provided by your admin',
          ),
          textCapitalization: TextCapitalization.characters,
          maxLength: 4,
          validator: (v) => v == null || v.length != 4 ? 'Invalid code' : null,
        ),
      ],
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
