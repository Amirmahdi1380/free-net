abstract class GetConfigEvent {}

class GetConfigStartEvent extends GetConfigEvent {}

class GetConfigRebuildEvent extends GetConfigEvent {
  String content;
  GetConfigRebuildEvent(this.content);
}
// class GetDelayStartEvent extends GetConfigEvent {
//   String link;
//   GetDelayStartEvent(this.link);
// }
