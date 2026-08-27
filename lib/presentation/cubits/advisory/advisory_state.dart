import 'package:equatable/equatable.dart';
import '../../../domain/entities/security_issue.dart';

abstract class AdvisoryState extends Equatable {
  const AdvisoryState();

  @override
  List<Object?> get props => [];
}

class AdvisoryInitialState extends AdvisoryState {}

class AdvisoryLoadedState extends AdvisoryState {
  final List<SecurityGuideline> guides;

  const AdvisoryLoadedState(this.guides);

  @override
  List<Object?> get props => [guides];
}
