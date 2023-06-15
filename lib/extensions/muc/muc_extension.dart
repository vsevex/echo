import 'package:echo/echo.dart';
import 'package:echo/src/constants.dart';

part 'room.dart';

class MUCExtension extends Extension {
  MUCExtension() : super('multi-chat user');

  Handler? handler;
  final rooms = <String, Room>{};

  @override
  void initialize(Echo echo) {
    super.echo = echo;
    final mucNs = ns['MUC'];
    super.echo!
      ..addNamespace('MUC_OWNER', '$mucNs#owner')
      ..addNamespace('MUC_ADMIN', '$mucNs#admin')
      ..addNamespace('MUC_USER', '$mucNs#user')
      ..addNamespace('MUC_ROOMCONF', '$mucNs#roomconfig')
      ..addNamespace('MUC_REGISTER', 'jabber:iq:register');
  }

  Future<void> queryOccupants(String room) {
    final info = EchoBuilder.iq(
      attributes: {'type': 'get', 'from': echo!.jid, 'to': room},
    ).c('query', attributes: {'xmlns': ns['DISCO_ITEMS']!});

    return echo!.sendIQ(
        element: info.nodeTree!,
        callback: (element) {
          print(element);
        });
  }

  Future<void> createInstantRoom(String room) => super.echo!.sendIQ(
      element: EchoBuilder.iq(
        attributes: {
          'to': room,
          'type': 'set',
        },
      ).c(
        'query',
        attributes: {
          'xmlns': ns['MUC_OWNER']!,
        },
      ).c(
        'x',
        attributes: {'xmlns': 'jabber:x:data', 'type': 'submit'},
      ).nodeTree!,
      callback: (element) {
        print(element);
      },
      onError: (error) {
        print('error:$error');
      });

  // Future<void> join(
  //   String room,
  //   String nickname, {
  //   String? roomcode,
  //   Map<String, String>? historyAttributes,
  //   XmlElement? extendedPresence,
  // }) async {
  //   final presence = EchoBuilder.pres(
  //     attributes: {
  //       'from': echo!.jid,
  //       'to': _roomNickname(room, nickname: nickname)
  //     },
  //   ).c('x', attributes: {'xmlns': ns['MUC']!});

  //   if (historyAttributes != null) {
  //     presence.c('history', attributes: historyAttributes).up();
  //   }

  //   if (roomcode != null) {
  //     presence.cnode(Echotils.xmlElement('password', text: roomcode)!);
  //   }

  //   if (extendedPresence != null) {
  //     presence.up().cnode(extendedPresence);
  //   }

  //   handler = Handler((stanza) async {
  //     final from = stanza.getAttribute('from');
  //     if (from == null) {
  //       return true;
  //     }

  //     final roomname = from.split('/')[0];

  //     if (!rooms.containsKey(roomname)) {
  //       return true;
  //     }

  //     final room = rooms[roomname];
  //     Map<String, Handler> handlers = <String, Handler>{};

  //     if (stanza.localName == 'message') {
  //       handlers = room!.messageHandlers;
  //     } else if (stanza.localName == 'presence') {
  //       final xQuery = stanza.findAllElements('x');

  //       for (final x in xQuery) {
  //         final xmlns = x.getAttribute('xnlns');
  //         if (xmlns != null && xmlns.contains(ns['MUC']!)) {
  //           handlers = room!.presenceHandlers;
  //           break;
  //         }
  //       }
  //     }

  //     handlers.entries.map((item) async {
  //       if (!await item.value.handler!(stanza)) {
  //         handlers.remove(item.key);
  //       }
  //     });

  //     if (!rooms.containsValue(room)) {

  //     }
  //   });
  // }

  String _roomNickname(String room, {String? nickname}) {
    final node = Echotils.escapeNode(Echotils().getNodeFromJID(room)!);
    final domain = Echotils().getDomainFromJID(node);

    final suffix = nickname != null ? '#/$nickname' : '';

    return '$node@$domain $suffix';
  }
}
