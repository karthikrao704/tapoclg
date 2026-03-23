import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/more_models.dart';

part 'more_event.dart';
part 'more_state.dart';

class MoreBloc extends Bloc<MoreEvent, MoreState> {
  MoreBloc() : super(const MoreState()) {
    on<LoadMoreContent>(_onLoadMoreContent);
    on<RefreshMoreContent>(_onRefreshMoreContent);
  }

  Future<void> _onLoadMoreContent(
    LoadMoreContent event,
    Emitter<MoreState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      // Simulate API fetch - replace with real data source when ready
      await Future.delayed(const Duration(milliseconds: 600));

      emit(
        state.copyWith(
          isLoading: false,
          featuredWorkshop: const FeaturedWorkshop(
            tag: 'LIVE WORKSHOP',
            title: 'Pranayama &\nBreathwork',
            subtitle: 'Pranayama & Breathwork',
            description:
                'Deepen your life force through ancient breathing techniques and mindful stillness.',
            time: '10:00 AM',
            duration: '90 mins',
            date: 'Oct 24',
            imagePath: 'assets/images/pranayam.png',
          ),
          vedicPackages: const [
            VedicPackage(
              title: 'Prakruthi\nJourney',
              subtitle: '14 Day Detox',
              imagePath: 'assets/images/nature1.png',
            ),
            VedicPackage(
              title: 'Sattva Retreat',
              subtitle: 'Purity & Mindset',
              imagePath: 'assets/images/nature2.png',
            ),
          ],
          educationalCourses: const [
            EducationalCourse(
              title: 'Intro to Ayurveda',
              lessons: '12 Lessons',
              level: 'Beginner',
              iconType: 'book',
            ),
            EducationalCourse(
              title: 'Yoga for Stress',
              lessons: '8 Lessons',
              level: 'Intermediate',
              iconType: 'lotus',
            ),
          ],
          blogPosts: const [
            WellnessBlogPost(
              category: 'NATURAL HEALING',
              title: 'The Power of Sandalwood',
              imagePath: 'assets/images/sandalwood.png',
            ),
            WellnessBlogPost(
              category: 'ROUTINES',
              title: 'Morning Rituals',
              imagePath: 'assets/images/morningritual.png',
            ),
          ],
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
