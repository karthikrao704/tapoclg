import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/more_models.dart';
import '../repositories/more_repository.dart';

part 'more_event.dart';
part 'more_state.dart';

class MoreBloc extends Bloc<MoreEvent, MoreState> {
  final MoreRepository _moreRepository;

  MoreBloc({MoreRepository? moreRepository})
      : _moreRepository = moreRepository ?? MoreRepository(),
        super(const MoreState()) {
    on<LoadMoreContent>(_onLoadMoreContent);
    on<RefreshMoreContent>(_onRefreshMoreContent);
  }

  Future<void> _onLoadMoreContent(
    LoadMoreContent event,
    Emitter<MoreState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final workshops = await _moreRepository.getWorkshops();
      
      List<WellnessBlogPost> blogs = [];
      try {
        blogs = await _moreRepository.getBlogs();
      } catch (e) {
        // Fallback if blogs fail to load
        blogs = [];
      }

      List<VedicPackage> vedicPrograms = [];
      try {
        vedicPrograms = await _moreRepository.getVedicPrograms();
      } catch (e) {
        // Fallback if vedic programs fail to load
        vedicPrograms = [];
      }

      emit(
        state.copyWith(
          isLoading: false,
          workshops: workshops,
          vedicPackages: vedicPrograms,
          blogPosts: blogs,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to load content: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onRefreshMoreContent(
    RefreshMoreContent event,
    Emitter<MoreState> emit,
  ) async {
    add(const LoadMoreContent());
  }
}
