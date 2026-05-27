import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tapovana_mobile_app/core/api/app_error.dart';
import 'package:tapovana_mobile_app/features/services/bloc/service_state.dart';
import 'package:tapovana_mobile_app/features/services/data/repositories/service_repository.dart';

/// Cubit for fetching the list of all services.
class ServiceCubit extends Cubit<ServiceState> {
  final ServiceRepository _repository;

  ServiceCubit({required ServiceRepository repository})
      : _repository = repository,
        super(ServiceInitial());

  /// Fetch all services from the API.
  Future<void> fetchServices() async {
    emit(ServiceLoading());
    try {
      final services = await _repository.getAllServices();
      emit(ServiceLoaded(services: services));
    } catch (e) {
      emit(ServiceError(
        message: e.toString(),
        errorType: AppError.classify(e),
      ));
    }
  }

  /// Fetch services filtered by [category] from the API.
  Future<void> fetchServicesByCategory(String category) async {
    emit(ServiceLoading());
    try {
      final services = await _repository.getServicesByCategory(category);
      emit(ServiceLoaded(services: services));
    } catch (e) {
      emit(ServiceError(
        message: e.toString(),
        errorType: AppError.classify(e),
      ));
    }
  }
}
