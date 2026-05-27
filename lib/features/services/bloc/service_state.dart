import 'package:equatable/equatable.dart';
import 'package:tapovana_mobile_app/core/api/app_error.dart';
import 'package:tapovana_mobile_app/features/services/data/models/service_model.dart';
import 'package:tapovana_mobile_app/features/services/data/models/service_detail_model.dart';

// ═══════════════════════════════════════
//   Service List States
// ═══════════════════════════════════════

abstract class ServiceState extends Equatable {
  const ServiceState();

  @override
  List<Object?> get props => [];
}

class ServiceInitial extends ServiceState {}

class ServiceLoading extends ServiceState {}

class ServiceLoaded extends ServiceState {
  final List<ServiceModel> services;

  const ServiceLoaded({required this.services});

  @override
  List<Object?> get props => [services];
}

class ServiceError extends ServiceState {
  final String message;
  final AppErrorType errorType;

  const ServiceError({
    required this.message,
    this.errorType = AppErrorType.server,
  });

  @override
  List<Object?> get props => [message, errorType];
}

// ═══════════════════════════════════════
//   Service Detail States
// ═══════════════════════════════════════

abstract class ServiceDetailState extends Equatable {
  const ServiceDetailState();

  @override
  List<Object?> get props => [];
}

class ServiceDetailInitial extends ServiceDetailState {}

class ServiceDetailLoading extends ServiceDetailState {}

class ServiceDetailLoaded extends ServiceDetailState {
  final ServiceDetailModel service;

  const ServiceDetailLoaded({required this.service});

  @override
  List<Object?> get props => [service];
}

class ServiceDetailError extends ServiceDetailState {
  final String message;
  final AppErrorType errorType;

  const ServiceDetailError({
    required this.message,
    this.errorType = AppErrorType.server,
  });

  @override
  List<Object?> get props => [message, errorType];
}
