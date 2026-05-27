import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tapovana_mobile_app/core/api/app_error.dart';
import 'package:tapovana_mobile_app/features/services/bloc/service_state.dart';
import 'package:tapovana_mobile_app/features/services/data/repositories/service_repository.dart';

/// Cubit for fetching a single service's full details.
class ServiceDetailCubit extends Cubit<ServiceDetailState> {
  final ServiceRepository _repository;

  ServiceDetailCubit({required ServiceRepository repository})
      : _repository = repository,
        super(ServiceDetailInitial());

  /// Fetch service details by ID from the API.
  Future<void> fetchServiceById(String id) async {
    emit(ServiceDetailLoading());
    try {
      final service = await _repository.getServiceById(id);
      emit(ServiceDetailLoaded(service: service));
    } catch (e) {
      emit(ServiceDetailError(
        message: e.toString(),
        errorType: AppError.classify(e),
      ));
    }
  }
}
