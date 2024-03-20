import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:free_name/bloc/getConfig/config_event.dart';
import 'package:free_name/bloc/getConfig/config_state.dart';
import 'package:free_name/data/repository/config_repo.dart';
import 'package:free_name/di/di.dart';

class ConfigBloc extends Bloc<GetConfigEvent, GetConfigState> {
  final IConfigRepository _iConfigRepository = locator.get();
  ConfigBloc() : super(GetConfigInitState()) {
    on(
      (event, emit) async {
        if (event is GetConfigStartEvent) {
          emit(GetConfigLoadingState());
          var getConfig = await _iConfigRepository.getAllConfigs();

          emit((GetConfigResponseState(getConfig)));
          //emit(ProjectLoadingState());
        }
        if (event is GetDelayStartEvent) {
          emit(GetConfigDelayLoadingState());
          var getDelayConfig =
              await _iConfigRepository.getDelayConfigs(event.link);

          emit((GetDelayResponseState(getDelayConfig)));
          //emit(ProjectLoadingState());
        }
      },
    );
  }
}
