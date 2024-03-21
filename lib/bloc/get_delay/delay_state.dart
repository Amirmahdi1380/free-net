import 'package:dartz/dartz.dart';

abstract class DelayState {}

class DelayInitState extends DelayState {}

class DelayLoadingState extends DelayState {}

class DelayResponseState extends DelayState {
  Either<String, int> getDelayConfig;
  DelayResponseState(this.getDelayConfig);
}
