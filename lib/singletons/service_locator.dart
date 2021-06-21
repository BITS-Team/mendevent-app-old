import 'package:mend_doctor/utils/local_authentication_service.dart';
import 'package:get_it/get_it.dart';

GetIt locator = GetIt.I;

void setupLocator() {
  locator.registerLazySingleton(() => LocalAuthenticationService());
}