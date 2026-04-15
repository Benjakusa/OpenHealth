import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/setup_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../../features/patients/presentation/patient_list_screen.dart';
import '../../features/patients/presentation/patient_detail_screen.dart';
import '../../features/patients/presentation/patient_form_screen.dart';
import '../../features/encounters/presentation/encounter_list_screen.dart';
import '../../features/encounters/presentation/encounter_detail_screen.dart';
import '../../features/encounters/presentation/triage_screen.dart';
import '../../features/encounters/presentation/consultation_screen.dart';
import '../../features/billing/presentation/invoice_screen.dart';
import '../../features/billing/presentation/payment_screen.dart';
import '../../features/lab/presentation/lab_queue_screen.dart';
import '../../features/lab/presentation/lab_results_entry_screen.dart';
import '../../features/pharmacy/presentation/dispensing_queue_screen.dart';
import '../../features/pharmacy/presentation/dispense_prescription_screen.dart';
import '../../features/ward/presentation/ward_list_screen.dart';
import '../../features/ward/presentation/ward_detail_screen.dart';
import '../../features/ward/presentation/admission_form_screen.dart';
import '../../features/ward/presentation/admission_detail_screen.dart';
import '../../features/reports/presentation/reports_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../widgets/main_scaffold.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/register',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isSetup = state.matchedLocation == '/setup';
      final isLogin = state.matchedLocation == '/login';
      final isRegister = state.matchedLocation == '/register';

      if (state.matchedLocation == '/') {
        if (!isLoggedIn) return '/login';
        return '/patients';
      }

      if (!isSetup && !isLoggedIn && !isLogin && !isRegister) {
        return '/setup';
      }

      if (isLoggedIn && (isLogin || isSetup || isRegister)) {
        return '/patients';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/setup',
        builder: (context, state) => const SetupScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: '/patients',
            builder: (context, state) => const PatientListScreen(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => const PatientFormScreen(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) => PatientDetailScreen(
                  patientId: state.pathParameters['id']!,
                ),
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) => PatientFormScreen(
                      patientId: state.pathParameters['id'],
                    ),
                  ),
                  GoRoute(
                    path: 'encounter/:encounterId',
                    builder: (context, state) => EncounterDetailScreen(
                      encounterId: state.pathParameters['encounterId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/encounters',
            builder: (context, state) => const EncounterListScreen(),
          ),
          GoRoute(
            path: '/encounter/:id',
            builder: (context, state) => EncounterDetailScreen(
              encounterId: state.pathParameters['id']!,
            ),
            routes: [
              GoRoute(
                path: 'triage',
                builder: (context, state) => TriageScreen(
                  encounterId: state.pathParameters['id']!,
                ),
              ),
              GoRoute(
                path: 'consultation',
                builder: (context, state) => ConsultationScreen(
                  encounterId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/billing',
            builder: (context, state) => const InvoiceScreen(),
            routes: [
              GoRoute(
                path: 'invoice/:id',
                builder: (context, state) => PaymentScreen(
                  invoiceId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/lab',
            builder: (context, state) => const LabQueueScreen(),
            routes: [
              GoRoute(
                path: 'order/:id',
                builder: (context, state) => LabResultsEntryScreen(
                  orderId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/pharmacy',
            builder: (context, state) => const DispensingQueueScreen(),
            routes: [
              GoRoute(
                path: 'dispense/:id',
                builder: (context, state) => DispensePrescriptionScreen(
                  prescriptionId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/wards',
            builder: (context, state) => const WardListScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) => WardDetailScreen(
                  wardId: state.pathParameters['id']!,
                ),
                routes: [
                  GoRoute(
                    path: 'admit',
                    builder: (context, state) => AdmissionFormScreen(
                      wardId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/admission/:id',
            builder: (context, state) => AdmissionDetailScreen(
              admissionId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/reports',
            builder: (context, state) => const ReportsDashboardScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
  );
});
