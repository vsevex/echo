part of 'muc_extension.dart';

/// Represents a room in an XMPP server's Multi-User Chat (MUC) logic.
class Room {
  /// Beforehand, the `addHandler` method is called with the arguments
  /// `presence` and `Handler(_rosterHandler)`. This line of code adds a handler
  /// for the `presence` stanza.
  Room() {
    addHandler('presence', Handler(_rosterHandler));
  }

  /// Represents the roster of [Occupant]s.
  final _roster = <String, Occupant?>{};

  /// Represents the collection of roster handlers.
  final _rosterHandlers = <int, Handler>{};

  /// Represents the collection of presence handlers.
  ///
  /// This variable is a map that represents the collection of presence
  /// handlers.
  final _presenceHandlers = <int, Handler>{};

  /// Represents the collection of message handlers.
  ///
  /// This variable is a map that represents the collection of message handlers.
  final _messageHandlers = <int, Handler>{};

  /// Represents the counter for assigning handler IDs.
  ///
  /// This variable is an [int] that serves as a counter for assigning handler
  /// IDs. It keeps track of the current ID to be assigned to handlers.
  int _handlerIds = 0;

  /// Adds a handler for a specified handler type.
  ///
  /// * @param handlerType The type of handler to add. Possible values are
  /// `presence`, `message`, and `roster`.
  /// * @param handler The handler function to be added.
  /// * @return The ID assigned to the handler, or null if the handler type
  /// is invalid.
  int? addHandler(String handlerType, Handler handler) {
    /// Increments `_handlerIds` variable and assignes it to the `id` variable
    /// to generate a unique ID for the handler.
    final id = _handlerIds++;
    switch (handlerType) {
      case 'presence':
        _presenceHandlers[id] = handler;
      case 'message':
        _messageHandlers[id] = handler;
      case 'roster':
        _rosterHandlers[id] = handler;
      default:
        _handlerIds--;
        return null;
    }
    return id;
  }

  /// This method is responsible for handling a roster update based on the
  /// information extracted from a presence XML element. The method performs
  /// several operations such as updating the roster, adding new occupants, and
  /// invoking roster handlers.
  ///
  /// * @param presence The XML element representing the presence to be handled.
  /// * @return Returns a [Future<bool>] indicating the success of the roster
  /// handling process.
  Future<bool> _rosterHandler(XmlElement presence) async {
    /// The `_parsePresence()` method is called to parse the presence XML
    /// element and extract relevant information into a [Map<String, dynamic>]
    /// object called `data`.
    final data = _parsePresence(presence);

    /// Get the `nick` from the parsed presence.
    final nick = data['nick'] as String?;

    /// Get the `newnick` from the parsed presence.
    ///
    /// This can be null.
    final newnick = data['newnick'] as String?;

    /// `Type` from the given presence stanza. Pass the parsed `type` to the
    /// switch.
    switch (data['type']) {
      case 'error':
        return true;
      case 'unavailable':

        /// Check if parsed `newnick` is not null.
        if (newnick != null) {
          data['nick'] = newnick;

          /// Check the `nick` and `newnick` values are not null, and the
          /// corresponding keys contain values.
          if ((_roster.containsKey(nick) && _roster[nick] != null) &&
              (_roster.containsKey(newnick) && _roster[newnick] != null)) {
            _roster[newnick]!.update(_roster[newnick]);
          }

          /// Check if `_roster` contains an object under the corresponding
          /// key and does not contain anything under 'newnick' key.
          if ((_roster[nick] != null && _roster[nick] != null) &&
              (!_roster.containsKey(newnick) || _roster[newnick] == null)) {
            _roster[newnick] = _roster[nick]!.update(data);
          }
        }
      default:
        if (_roster.containsKey(nick) && _roster[nick] != null) {
          _roster[nick]!.update(data);
        } else {
          _addOccupant(data);
        }
    }
    for (final entry in _rosterHandlers.entries) {
      final handler = entry.value;
      if (!await handler.run(presence)!) {
        _rosterHandlers.removeWhere((key, value) => key == entry.key);
      }
    }
    return true;
  }

  Occupant _addOccupant(Map<String, dynamic> data) {
    final occupant = Occupant.fromMap(data);
    _roster[occupant.nick] = occupant;

    return occupant;
  }

  /// Returns a [Map<String, dynamic>] object containing the parsed presence
  /// information.
  Map<String, dynamic> _parsePresence(XmlElement presence) {
    /// An empty Map<String, dynamic> object named data is initialized.
    final data = <String, dynamic>{};

    /// Equal `nick` from `presence` [XmlElement].
    data['nick'] =
        Echotils().getResourceFromJID(presence.getAttribute('from')!);

    /// Equal `type` from [XmlElement] presence.
    data['type'] = presence.getAttribute('type');

    data['states'] = [];

    /// Equal `children` of `descendantElements` from [XmlElement].
    ///
    /// Iterates from `presence`, creates a [List] from this [Iterable].
    final children = presence.descendantElements.toList();

    for (int i = 0; i < children.length; i++) {
      /// The i-th child.
      final child = children[i];

      /// Switch all possible node names.
      switch (child.localName) {
        case 'error':
          data['errorcode'] = child.getAttribute('code');

          /// Check if children of the given `child` is not empty, if yes, then
          /// take the first child's `localName`.
          data['error'] = child.descendantElements.isNotEmpty
              ? child.descendantElements.toList()[0].localName
              : null;
        case 'status':
          data['status'] = child.value;
        case 'show':
          data['show'] = child.value;
        case 'x':
          if (child.getAttribute('xmlns') == ns['MUC_USER']) {
            /// Create new [List] from child's descendant elements.
            final children = child.descendantElements.toList();

            for (int j = 0; j < children.length; j++) {
              /// The j-th child.
              final child = children[j];

              switch (child.localName) {
                case 'item':
                  data['afiliation'] = child.getAttribute('affiliation');
                  data['role'] = child.getAttribute('role');
                  data['jid'] = child.getAttribute('jid');
                  data['newnick'] = child.getAttribute('nick');
                case 'status':
                  if (child.getAttribute('code') != null) {
                    (data['states'] as List).add(child.getAttribute('code'));
                  }
              }
            }
          }
      }
    }

    return data;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Room &&
          runtimeType == other.runtimeType &&
          _messageHandlers == other._messageHandlers &&
          _presenceHandlers == other._presenceHandlers &&
          _roster == other._roster &&
          _rosterHandlers == other._rosterHandlers &&
          _handlerIds == other._handlerIds;

  @override
  int get hashCode =>
      _messageHandlers.hashCode ^
      _presenceHandlers.hashCode ^
      _roster.hashCode ^
      _rosterHandlers.hashCode ^
      _handlerIds.hashCode;

  @override
  String toString() =>
      '''Room: (Message Handlers (MAP): $_messageHandlers, Presence Handlers (MAP): $_presenceHandlers, Roster Handlers (MAP): $_rosterHandlers), Roster: $_roster, Roster ID Count: $_handlerIds''';
}
