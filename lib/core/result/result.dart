import '../error/failures.dart';

/// Outcome of an operation that can fail: either [Success] or [Err].
sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);

  final Failure failure;
}
