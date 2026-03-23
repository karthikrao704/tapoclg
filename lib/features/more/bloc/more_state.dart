part of 'more_bloc.dart';

class MoreState extends Equatable {
  final bool isLoading;
  final String? error;
  final FeaturedWorkshop? featuredWorkshop;
  final List<VedicPackage> vedicPackages;
  final List<EducationalCourse> educationalCourses;
  final List<WellnessBlogPost> blogPosts;

  const MoreState({
    this.isLoading = false,
    this.error,
    this.featuredWorkshop,
    this.vedicPackages = const [],
    this.educationalCourses = const [],
    this.blogPosts = const [],
  });

  MoreState copyWith({
    bool? isLoading,
    String? error,
    FeaturedWorkshop? featuredWorkshop,
    List<VedicPackage>? vedicPackages,
    List<EducationalCourse>? educationalCourses,
    List<WellnessBlogPost>? blogPosts,
  }) {
    return MoreState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      featuredWorkshop: featuredWorkshop ?? this.featuredWorkshop,
      vedicPackages: vedicPackages ?? this.vedicPackages,
      educationalCourses: educationalCourses ?? this.educationalCourses,
      blogPosts: blogPosts ?? this.blogPosts,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    error,
    featuredWorkshop,
    vedicPackages,
    educationalCourses,
    blogPosts,
  ];
}
