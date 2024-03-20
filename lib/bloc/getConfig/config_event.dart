abstract class GetConfigEvent {}

class GetConfigStartEvent extends GetConfigEvent {}

class GetDelayStartEvent extends GetConfigEvent {
  String link;
  GetDelayStartEvent(this.link);
}
