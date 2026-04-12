import 'database_service_stub.dart'
    if (dart.library.html) 'database_service_web.dart'
    if (dart.library.io) 'database_service_native.dart';

export 'database_service_stub.dart';

DatabaseService createDatabaseService() {
  throw UnsupportedError('Cannot create a database without either dart:html or dart:io');
}
