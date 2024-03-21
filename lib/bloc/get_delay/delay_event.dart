abstract class DelayEvent {}

class GetDelayStartEvent extends DelayEvent {}

class DelayStartEvent extends DelayEvent {
  String link;
  DelayStartEvent(this.link);
}
