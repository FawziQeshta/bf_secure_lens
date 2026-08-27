import 'package:get_it/get_it.dart';
import '../../data/datasources/local_scanner_datasource.dart';
import '../../data/repositories/security_audit_repository_impl.dart';
import '../../domain/repositories/security_audit_repository.dart';
import '../../domain/usecases/run_security_audit_usecase.dart';
import '../../domain/usecases/export_audit_report_usecase.dart';
import '../../presentation/cubits/audit/audit_cubit.dart';
import '../../presentation/cubits/advisory/advisory_cubit.dart';
import '../../presentation/cubits/theme/theme_cubit.dart';

final sl = GetIt.instance;

void initDependencyInjection() {
  // Cubits
  sl.registerFactory(() => AuditCubit(
        runSecurityAuditUseCase: sl(),
        exportAuditReportUseCase: sl(),
      ));
  sl.registerFactory(() => AdvisoryCubit(repository: sl()));
  sl.registerLazySingleton(() => ThemeCubit());

  // Use Cases
  sl.registerLazySingleton(() => RunSecurityAuditUseCase(sl()));
  sl.registerLazySingleton(() => ExportAuditReportUseCase(sl()));

  // Repository
  sl.registerLazySingleton<SecurityAuditRepository>(
    () => SecurityAuditRepositoryImpl(localScannerDataSource: sl()),
  );

  // Data Source
  sl.registerLazySingleton<LocalScannerDataSource>(
    () => LocalScannerDataSourceImpl(),
  );
}
