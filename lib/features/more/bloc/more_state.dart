part of 'more_bloc.dart';

class MoreState extends Equatable {
  final bool isLoading;
  final String? error;
  final List<FeaturedWorkshop> workshops;
  final List<VedicPackage> vedicPackages;
  final List<WellnessBlogPost> blogPosts;

  const MoreState({
    this.isLoading = false,
    this.error,
    this.workshops = const [],
    this.vedicPackages = const [],
    this.blogPosts = const [],
  });

  MoreState copyWith({
    bool? isLoading,
    String? error,
    List<FeaturedWorkshop>? workshops,
    List<VedicPackage>? vedicPackages,
    List<WellnessBlogPost>? blogPosts,
  }) {
    return MoreState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      workshops: workshops ?? this.workshops,
      vedicPackages: vedicPackages ?? this.vedicPackages,
      blogPosts: blogPosts ?? this.blogPosts,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    error,
    workshops,
    vedicPackages,
    blogPosts,
  ];
}
