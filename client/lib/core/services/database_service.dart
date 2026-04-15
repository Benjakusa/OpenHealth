export 'database_service_stub.dart'
    if (dart.library.io) 'database_service_native.dart'
    if (dart.library.html) 'database_service_web.dart';

export 'factory/database_service_factory_stub.dart'
    if (dart.library.io) 'factory/database_service_factory_native.dart'
    if (dart.library.html) 'factory/database_service_factory_web.dart';
