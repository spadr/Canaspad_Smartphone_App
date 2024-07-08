import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/beam.dart';
import '../models/engineer.dart';
import '../models/insect.dart';

class GameState {
  List<InsectState> insects;
  List<BeamState> beams;
  int score;
  int highScore;
  Timer? gameTimer;
  Timer? beamTimer;
  Timer? spawnTimer;
  bool isGameOver;

  GameState({
    required this.insects,
    required this.beams,
    required this.score,
    required this.highScore,
    this.gameTimer,
    this.beamTimer,
    this.spawnTimer,
    this.isGameOver = false,
  });

  GameState copyWith({
    List<InsectState>? insects,
    List<BeamState>? beams,
    int? score,
    int? highScore,
    Timer? gameTimer,
    Timer? beamTimer,
    Timer? spawnTimer,
    bool? isGameOver,
  }) {
    return GameState(
      insects: insects ?? this.insects,
      beams: beams ?? this.beams,
      score: score ?? this.score,
      highScore: highScore ?? this.highScore,
      gameTimer: gameTimer ?? this.gameTimer,
      beamTimer: beamTimer ?? this.beamTimer,
      spawnTimer: spawnTimer ?? this.spawnTimer,
      isGameOver: isGameOver ?? this.isGameOver,
    );
  }

  void cancelTimers() {
    gameTimer?.cancel();
    beamTimer?.cancel();
    spawnTimer?.cancel();
  }
}

class GameService extends StateNotifier<GameState> {
  final Ref ref;

  GameService(this.ref)
      : super(GameState(
          insects: [],
          beams: [],
          score: 0,
          highScore: 0,
        )) {
    loadHighScore();
  }

  Random random = Random();
  late Function gameOverCallback;

  int get score => state.score;
  set score(int value) {
    if (!state.isGameOver) {
      state = state.copyWith(score: value);
    }
  }

  int get highScore => state.highScore;
  set highScore(int value) {
    state = state.copyWith(highScore: value);
  }

  List<InsectState> get insects => state.insects;
  List<BeamState> get beams => state.beams;

  Timer? get gameTimer => state.gameTimer;
  Timer? get beamTimer => state.beamTimer;
  Timer? get spawnTimer => state.spawnTimer;

  @override
  void dispose() {
    cancelTimers();
    super.dispose();
  }

  void cancelTimers() {
    state.gameTimer?.cancel();
    state.beamTimer?.cancel();
    state.spawnTimer?.cancel();
  }

  Future<void> startGame(Function onGameOver) async {
    await resetGame();
    gameOverCallback = onGameOver;
    state = state.copyWith(isGameOver: false);
    startSpawningInsects();
    startGameLoop();
    startShootingBeams();
  }

  Future<void> resetGame() async {
    cancelTimers();
    ref.read(engineerProvider.notifier).reset();
    state = GameState(
      insects: [],
      beams: [],
      score: 0,
      highScore: state.highScore,
      isGameOver: false,
    );
  }

  void startSpawningInsects() {
    state = state.copyWith(
      spawnTimer: Timer.periodic(
        Duration(milliseconds: 600),
        (timer) {
          if (!state.isGameOver) {
            final insectState = InsectState(
              health: random.nextBool() ? 50 : 100,
              x: random.nextDouble() * 0.8 + 0.1,
              y: 0,
            );
            state = state.copyWith(
              insects: [
                ...state.insects,
                insectState,
              ],
            );
          }
        },
      ),
    );
  }

  void startGameLoop() {
    state = state.copyWith(
      gameTimer: Timer.periodic(Duration(milliseconds: 50), (timer) {
        if (!state.isGameOver) {
          updateInsects();
          updateBeams();
        }
      }),
    );
  }

  void startShootingBeams() {
    state = state.copyWith(
      beamTimer: Timer.periodic(Duration(milliseconds: 1000), (timer) {
        if (!state.isGameOver) {
          final beamState = BeamState(
            x: ref.read(engineerProvider).x,
            y: ref.read(engineerProvider).y - 0.1,
          );
          state = state.copyWith(
            beams: [
              ...state.beams,
              beamState,
            ],
          );
        }
      }),
    );
  }

  void updateInsects() {
    if (state.isGameOver) return;

    List<InsectState> updatedInsects = [];

    for (var insectState in state.insects) {
      double newY = insectState.y + 0.01;
      double newX = insectState.x + insectState.dx;

      if (newX < 0.1 || newX > 0.9) {
        insectState = insectState.copyWith(dx: -insectState.dx);
      }

      if ((newX - ref.read(engineerProvider).x).abs() < 0.05 && (newY - ref.read(engineerProvider).y).abs() < 0.05) {
        ref.read(engineerProvider.notifier).updateHealth(ref.read(engineerProvider).health - insectState.health);
        insectState = insectState.copyWith(health: 0);
        if (insectState.health <= 0) {
          state = state.copyWith(score: state.score + 10);
        }
      } else {
        updatedInsects.add(insectState.copyWith(x: newX, y: newY));
      }
    }

    state = state.copyWith(insects: updatedInsects);

    if (ref.read(engineerProvider).health <= 0) {
      gameOver();
    }
  }

  void updateBeams() {
    if (state.isGameOver) return;

    List<BeamState> updatedBeams = [];
    List<InsectState> updatedInsects = List.from(state.insects);

    for (var beamState in state.beams) {
      double newY = beamState.y - 0.05;
      if (newY < 0) {
        continue;
      }

      bool shouldRemoveBeam = false;
      for (int i = 0; i < updatedInsects.length; i++) {
        var insectState = updatedInsects[i];
        if ((insectState.x - beamState.x).abs() < 0.05 && (insectState.y - beamState.y).abs() < 0.05) {
          final initialInsectHealth = insectState.health;
          final initialBeamHealth = beamState.health;
          insectState.health -= initialBeamHealth;
          beamState.health -= initialInsectHealth;

          if (insectState.health <= 0) {
            updatedInsects.removeAt(i);
            state = state.copyWith(score: state.score + 10);
          }

          shouldRemoveBeam = beamState.health <= 0;
        }
      }

      if (!shouldRemoveBeam) {
        updatedBeams.add(beamState.copyWith(y: newY));
      }
    }

    state = state.copyWith(beams: updatedBeams, insects: updatedInsects);
  }

  Future<void> loadHighScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    state = state.copyWith(highScore: prefs.getInt('highScore') ?? 0);
  }

  Future<void> updateHighScore() async {
    if (state.score > state.highScore) {
      state = state.copyWith(highScore: state.score);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('highScore', state.highScore);
    }
  }

  void gameOver() {
    state = state.copyWith(isGameOver: true);
    updateHighScore().then((_) {
      gameOverCallback();
    });
  }
}

final gameServiceProvider = StateNotifierProvider<GameService, GameState>((ref) {
  return GameService(ref);
});
