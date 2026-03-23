part of 'more_bloc.dart';

abstract class MoreEvent extends Equatable {
  const MoreEvent();

  @override
  List<Object?> get props => [];
}

class LoadMoreContent extends MoreEvent {
  const LoadMoreContent();
}

class RefreshMoreContent extends MoreEvent {
  const RefreshMoreContent();
}
