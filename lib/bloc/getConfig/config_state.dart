import 'package:dartz/dartz.dart';

abstract class GetConfigState {}

class GetConfigInitState extends GetConfigState {}

class GetConfigLoadingState extends GetConfigState {}

class GetConfigResponseState extends GetConfigState {
  Either<String, String> getConfig;
  GetConfigResponseState(this.getConfig);
}
