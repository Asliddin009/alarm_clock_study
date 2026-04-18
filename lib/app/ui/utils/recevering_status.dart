class ReceivingStatus {
  const ReceivingStatus._();

  factory ReceivingStatus.initial() => const Initial();
  factory ReceivingStatus.loading({String? message}) => Loading(message ?? '');
  factory ReceivingStatus.success([String message = '']) => Success(message);
  factory ReceivingStatus.failure(String message) => Failure(message);

  bool get isLoading => this is Loading;
  bool get isFailure => this is Failure;
  bool get isSuccess => this is Success;
  bool get isInitial => this is Initial;
  String? get failureMessage =>
      this is Failure ? (this as Failure).message : null;

  String get message {
    if (this is Success) {
      return (this as Success).message;
    } else if (this is Failure) {
      return (this as Failure).message;
    } else if (this is Loading) {
      return (this as Loading).message;
    }

    return '';
  }
}

class Initial extends ReceivingStatus {
  const Initial() : super._();
}

class Loading extends ReceivingStatus {
  @override
  final String message;

  const Loading(this.message) : super._();
}

class Success extends ReceivingStatus {
  @override
  final String message;

  const Success(this.message) : super._();
}

class Failure extends ReceivingStatus {
  @override
  final String message;

  const Failure(this.message) : super._();
}
