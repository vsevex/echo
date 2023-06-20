part of 'muc_extension.dart';

class Occupant {
  const Occupant({
    required this.nick,
    this.affiliation,
  });

  final String nick;
  final String? affiliation;

  factory Occupant.fromMap(Map<String, dynamic> map) => Occupant(
        nick: map['nick'] as String,
        affiliation: map['affiliation'] as String?,
      );

  Occupant? update(dynamic occupant) {
    if (occupant != null) {
      if (occupant is Occupant) {
        return Occupant(
          nick: occupant.nick,
          affiliation: occupant.affiliation ?? affiliation,
        );
      } else {
        final data = occupant as Map<String, dynamic>;
        return Occupant(
          nick: data['nick'] as String,
          affiliation: data['affiliation'] as String?,
        );
      }
    }
    return null;
  }
}
