import 'package:equatable/equatable.dart';

/// Domain-facing error. Widgets display [message]; raw exceptions never leave the data layer.
sealed class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class ServerFailure extends Failure {
  const ServerFailure({required this.code, required String message})
    : super(message);

  final String code;

  @override
  List<Object?> get props => [code, message];
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}
