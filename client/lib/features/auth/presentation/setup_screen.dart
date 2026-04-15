import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import '../../../core/config/theme.dart';
import '../../../core/config/environment.dart';
import '../../../core/services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tenantIdController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  bool _showConnectForm = false;

  @override
  void dispose() {
    _tenantIdController.dispose();
    super.dispose();
  }

  Future<void> _setup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final api = ref.read(apiServiceProvider);
      final response = await api.get('/tenants/${_tenantIdController.text.trim()}');
      
      if (response.statusCode == 200) {
        await Environment.setTenant(
          response.data['id'],
          response.data['name'],
        );
        if (mounted) {
          context.go('/login');
        }
      } else {
        setState(() => _error = 'Invalid Tenant ID. Please check and try again.');
      }
    } catch (e) {
      setState(() => _error = 'Connection failed. Please check your internet.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHero(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xxl),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: _showConnectForm ? _buildConnectForm(context) : _buildMainMenu(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    return Container(
      width: double.infinity,
      color: AppTheme.primaryColor,
      padding: EdgeInsets.symmetric(
        vertical: isDesktop ? AppSpacing.xxl * 2 : AppSpacing.xxl,
        horizontal: AppSpacing.xl,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(BootstrapIcons.heart_pulse_fill, color: AppTheme.primaryColor, size: 32),
              ),
              const SizedBox(width: AppSpacing.md),
              const Text(
                'OpenHealth',
                style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          const Text(
            'Healthcare Management evolved.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold, height: 1.1),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Unified solution for clinics, dispensaries, and hospitals.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildMainMenu(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    return Column(
      children: [
        if (isMobile) ...[
          _ActionCard(
            icon: BootstrapIcons.person_plus,
            title: 'Register',
            subtitle: 'Register your organization',
            color: Colors.teal,
            onTap: () => context.go('/register'),
          ),
          const SizedBox(height: AppSpacing.md),
          _ActionCard(
            icon: BootstrapIcons.box_arrow_in_right,
            title: 'Sign in to Clinic',
            subtitle: 'Access your facility dashboard',
            color: AppTheme.primaryColor,
            onTap: () => context.go('/login'),
          ),
          const SizedBox(height: AppSpacing.md),
          _ActionCard(
            icon: BootstrapIcons.shield_lock,
            title: 'OpenHealth Log in',
            subtitle: 'Platform administration',
            color: Colors.purple,
            onTap: () => context.go('/admin/login'),
          ),
        ] else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _ActionCard(
                  icon: BootstrapIcons.person_plus,
                  title: 'Register',
                  subtitle: 'Start managing your healthcare operations with our secure multi-tenant platform.',
                  color: Colors.teal,
                  onTap: () => context.go('/register'),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: _ActionCard(
                  icon: BootstrapIcons.box_arrow_in_right,
                  title: 'Sign in to Clinic',
                  subtitle: 'Access your clinic dashboard, patient records, and pharmacy management.',
                  color: AppTheme.primaryColor,
                  onTap: () => context.go('/login'),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: _ActionCard(
                  icon: BootstrapIcons.shield_lock,
                  title: 'OpenHealth Log in',
                  subtitle: 'Centralized platform management for system administrators and support.',
                  color: Colors.purple,
                  onTap: () => context.go('/admin/login'),
                ),
              ),
            ],
          ),
        const SizedBox(height: AppSpacing.xxl),
        const Divider(),
        const SizedBox(height: AppSpacing.xxl),
        _buildFeaturesGrid(),
      ],
    );
  }

  Widget _buildConnectForm(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(BootstrapIcons.arrow_left),
                        onPressed: () => setState(() => _showConnectForm = false),
                      ),
                      const Text('Connect Facility', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  TextFormField(
                    controller: _tenantIdController,
                    decoration: const InputDecoration(
                      labelText: 'Facility/Tenant ID',
                      prefixIcon: Icon(BootstrapIcons.building),
                      hintText: 'e.g. city-hosp-01',
                    ),
                    onFieldSubmitted: (_) => _setup(),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(_error!, style: const TextStyle(color: AppTheme.errorColor, fontSize: 13)),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _setup,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                      child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Verify & Connect'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesGrid() {
    return LayoutBuilder(builder: (context, constraints) {
      final cols = constraints.maxWidth > 800 ? 3 : (constraints.maxWidth > 500 ? 2 : 1);
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: cols,
        mainAxisSpacing: AppSpacing.xl,
        crossAxisSpacing: AppSpacing.xl,
        childAspectRatio: 2.5,
        children: [
          _buildFeatureItem(BootstrapIcons.people, 'Patient Records', 'Complete health history and demographics.'),
          _buildFeatureItem(BootstrapIcons.clipboard_pulse, 'Triaging', 'Track vital signs and emergency status.'),
          _buildFeatureItem(BootstrapIcons.capsule, 'Pharmacy', 'Inventory, dispensing, and prescriptions.'),
          _buildFeatureItem(BootstrapIcons.droplet_half, 'Laboratory', 'Order management and electronic results.'),
          _buildFeatureItem(BootstrapIcons.cash_stack, 'Billing', 'Invoicing, payments, and insurance claims.'),
          _buildFeatureItem(BootstrapIcons.graph_up, 'Reporting', 'Real-time analytics and morbidity data.'),
        ],
      );
    });
  }

  Widget _buildFeatureItem(IconData icon, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 28),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: AppSpacing.xs),
              Text(desc, style: const TextStyle(color: AppTheme.textSecondaryLight, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSpacing.sm),
              Text(subtitle, style: const TextStyle(color: AppTheme.textSecondaryLight, fontSize: 14)),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Text('Get Started', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                  const SizedBox(width: AppSpacing.sm),
                  Icon(BootstrapIcons.arrow_right, color: color, size: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
