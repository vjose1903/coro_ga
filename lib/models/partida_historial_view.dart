import 'models.dart';

class PartidaHistorialPlayerEntry {
  const PartidaHistorialPlayerEntry({
    required this.turn,
    required this.jugador,
    required this.score,
    required this.isIncrease,
    required this.isPlaceholder,
    this.historial,
  });

  final int turn;
  final Jugador jugador;
  final int score;
  final bool isIncrease;
  final bool isPlaceholder;
  final HistorialJugada? historial;
}

class PartidaHistorialTurn {
  const PartidaHistorialTurn({
    required this.turn,
    required this.sourceJugador,
    required this.sourceHistorial,
    required this.entries,
  });

  final int turn;
  final Jugador sourceJugador;
  final HistorialJugada sourceHistorial;
  final List<PartidaHistorialPlayerEntry> entries;
}

class PartidaHistorialTimeline {
  static List<PartidaHistorialTurn> buildTurns(Partida partida) {
    final jugadores = _sortedJugadores(partida);
    final rawEntries = <_RawHistorialEntry>[];

    for (final jugador in jugadores) {
      final historiales = List<HistorialJugada>.from(
          jugador.historialJugadas ?? <HistorialJugada>[]);
      historiales.sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));

      for (final historial in historiales) {
        rawEntries
            .add(_RawHistorialEntry(jugador: jugador, historial: historial));
      }
    }

    rawEntries
        .sort((a, b) => (a.historial.id ?? 0).compareTo(b.historial.id ?? 0));

    return rawEntries.asMap().entries.map((entry) {
      final turn = entry.key + 1;
      final rawEntry = entry.value;
      final historial = rawEntry.historial;
      final isIncrease = historial.tipo != 'reducir';

      return PartidaHistorialTurn(
        turn: turn,
        sourceJugador: rawEntry.jugador,
        sourceHistorial: historial,
        entries: jugadores.map((jugador) {
          final isSource = jugador.id == rawEntry.jugador.id;
          return PartidaHistorialPlayerEntry(
            turn: turn,
            jugador: jugador,
            score: isSource ? (historial.puntuacion ?? 0) : 0,
            isIncrease: isSource ? isIncrease : true,
            isPlaceholder: !isSource,
            historial: isSource ? historial : null,
          );
        }).toList(),
      );
    }).toList();
  }

  static List<PartidaHistorialPlayerEntry> buildEntriesForJugador(
      Partida partida, Jugador jugador) {
    return buildTurns(partida).map((turn) {
      return turn.entries.firstWhere((entry) => entry.jugador.id == jugador.id);
    }).toList();
  }

  static List<Jugador> _sortedJugadores(Partida partida) {
    final jugadores = List<Jugador>.from(partida.jugadores ?? <Jugador>[]);
    jugadores.sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));
    return jugadores;
  }
}

class _RawHistorialEntry {
  const _RawHistorialEntry({
    required this.jugador,
    required this.historial,
  });

  final Jugador jugador;
  final HistorialJugada historial;
}
