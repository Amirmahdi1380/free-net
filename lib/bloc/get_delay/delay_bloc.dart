import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:free_name/data/repository/config_repo.dart';
import 'package:free_name/di/di.dart';

import 'delay_event.dart';
import 'delay_state.dart';

class DelayBloc extends Bloc<DelayEvent, DelayState> {
  final IConfigRepository _iConfigRepository = locator.get();
  DelayBloc() : super(DelayInitState()) {
    on(
      (event, emit) async {
        if (event is GetDelayStartEvent) {
          emit(DelayLoadingState());
        }
        if (event is DelayStartEvent) {
          // emit(GetConfigDelayLoadingState());
          var getDelayConfig =
              await _iConfigRepository.getDelayConfigs(event.link);

          emit((DelayResponseState(getDelayConfig)));
          //emit(ProjectLoadingState());
        }
      },
    );
  }
}
