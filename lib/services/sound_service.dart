import 'package:audioplayers/audioplayers.dart';

/// Handles dice rolling sounds.
/// Place MP3 files in assets/sounds/:
///   - dice_roll.mp3       (rolling rattle sound)
///   - dice_land.mp3       (soft thud on table)
///   - critical_success.mp3 (triumphant chime)
///   - critical_failure.mp3 (ominous tone)
class SoundService {
  static final SoundService instance = SoundService._();
  SoundService._();

  final AudioPlayer _player = AudioPlayer();

  /// Attempts to play [assetPath]; silently ignores missing assets.
  Future<void> _play(String assetPath) async {
    try {
      await _player.stop();
      await _player.play(AssetSource(assetPath));
    } catch (_) {
      // Asset not found or playback failed — continue without sound
    }
  }

  Future<void> playRolling() => _play('sounds/dice_roll.mp3');
  Future<void> playResult() => _play('sounds/dice_land.mp3');
  Future<void> playCriticalSuccess() => _play('sounds/critical_success.mp3');
  Future<void> playCriticalFailure() => _play('sounds/critical_failure.mp3');
}
