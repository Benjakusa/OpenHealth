import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';

export '../data/auth_repository.dart';

final loginFormProvider = StateProvider<LoginForm>((ref) => LoginForm());

class LoginForm {
  final String email;
  final String password;

  LoginForm({
    this.email = '',
    this.password = '',
  });

  LoginForm copyWith({String? email, String? password}) {
    return LoginForm(
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }

  bool get isValid => email.isNotEmpty && password.isNotEmpty;
}
