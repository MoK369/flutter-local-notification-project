sealed class BaseViewState<T> {}

class IdleState<T> extends BaseViewState<T> {}

class LoadingState<T> extends BaseViewState<T> {
  String? message;
  LoadingState({this.message});
}

class SuccessState<T> extends BaseViewState<T> {
  T data;
  SuccessState({required this.data});
}

class ErrorState<T> extends BaseViewState<T> {
  Object? error;
  ErrorState({this.error});
}
