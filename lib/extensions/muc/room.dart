part of 'muc_extension.dart';

class Room {
  const Room(this.messageHandlers, this.presenceHandlers);

  

  final Map<String, Handler> messageHandlers;
  final Map<String, Handler> presenceHandlers;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Room &&
          runtimeType == other.runtimeType &&
          messageHandlers == other.messageHandlers &&
          presenceHandlers == other.presenceHandlers;
  @override
  int get hashCode => messageHandlers.hashCode ^ presenceHandlers.hashCode;

  @override
  String toString() =>
      '''Room: (Message Handlers (LIST): $messageHandlers, Presence Handlers (LIST): $presenceHandlers)''';
}
