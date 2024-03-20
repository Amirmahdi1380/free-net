import 'package:dartz/dartz.dart';

abstract class GetConfigState {}

class GetConfigInitState extends GetConfigState {}

class GetConfigLoadingState extends GetConfigState {}

class GetConfigDelayLoadingState extends GetConfigState {}

class GetConfigResponseState extends GetConfigState {
  Either<String, String> getConfig;
  GetConfigResponseState(this.getConfig);
}

class GetDelayResponseState extends GetConfigState {
  Either<String, int> getDelayConfig;
  GetDelayResponseState(this.getDelayConfig);
}
