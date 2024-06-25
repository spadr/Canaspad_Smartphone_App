import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/beam.dart';
import '../models/engineer.dart';
import '../models/insect.dart';
import '../services/game_service.dart';

const double iconSize = 48;
const Color engineerColor = Color(0xFF607D8B);

Widget buildGameElements(BuildContext context, GameState gameState, ProviderContainer container) {
  final engineerState = container.read(engineerProvider);

  return Stack(
    children: [
      Positioned(
        left: engineerState.x * MediaQuery.of(context).size.width - iconSize / 2,
        top: engineerState.y * MediaQuery.of(context).size.height - iconSize / 2,
        child: Icon(Icons.engineering, size: iconSize, color: engineerColor),
      ),
      ...gameState.insects.asMap().entries.map((entry) {
        int index = entry.key;
        InsectState insectState = entry.value;
        return Positioned(
          key: Key('insect_$index'),
          left: insectState.x * MediaQuery.of(context).size.width - iconSize / 2,
          top: insectState.y * MediaQuery.of(context).size.height,
          child: Icon(Icons.bug_report),
        );
      }).toList(),
      ...gameState.beams.asMap().entries.map((entry) {
        int index = entry.key;
        BeamState beamState = entry.value;
        return Positioned(
          key: Key('beam_$index'),
          left: beamState.x * MediaQuery.of(context).size.width - iconSize / 2,
          top: beamState.y * MediaQuery.of(context).size.height,
          child: Icon(Icons.build),
        );
      }).toList(),
    ],
  );
}
