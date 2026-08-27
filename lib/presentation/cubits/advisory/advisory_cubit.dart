import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/security_audit_repository.dart';
import 'advisory_state.dart';

class AdvisoryCubit extends Cubit<AdvisoryState> {
  final SecurityAuditRepository repository;

  AdvisoryCubit({required this.repository}) : super(AdvisoryInitialState());

  void loadHardeningGuides() {
    final guides = repository.getHardeningGuides();
    emit(AdvisoryLoadedState(guides));
  }
}
