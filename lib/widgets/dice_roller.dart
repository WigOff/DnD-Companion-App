import 'dart:async';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:dnd_app/providers/player_provider.dart';
import 'package:dnd_app/services/sound_service.dart';

/// Reusable D20 dice roller widget with full animation and special effects.
///
/// - [playerId]   : the player's UUID. Pass null for a GM / anonymous roll.
/// - [displayName]: shown for context (e.g. "Aragorn").
class DiceRoller extends StatefulWidget {
  final String? playerId;
  final String displayName;

  const DiceRoller({super.key, this.playerId, required this.displayName});

  @override
  State<DiceRoller> createState() => _DiceRollerState();
}

class _DiceRollerState extends State<DiceRoller> with TickerProviderStateMixin {
  bool _isRolling = false;
  int _selectedSides = 20;
  int _displayNumber = 20;
  int? _result;

  Timer? _rollTimer;
  StreamSubscription? _rollSub;
  final _rng = Random();

  final List<int> _diceOptions = [4, 6, 8, 10, 12, 20];

  // ── Animation controllers ──────────────────────────────────────────────────
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  late AnimationController _revealCtrl;
  late Animation<double> _revealAnim;
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;
  late ConfettiController _confettiCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _pulseAnim = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _revealCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _revealAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.35), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 0.88), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.88, end: 1.0), weight: 25),
    ]).animate(CurvedAnimation(parent: _revealCtrl, curve: Curves.easeOut));

    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -14.0), weight: 17),
      TweenSequenceItem(tween: Tween(begin: -14.0, end: 14.0), weight: 17),
      TweenSequenceItem(tween: Tween(begin: 14.0, end: -11.0), weight: 17),
      TweenSequenceItem(tween: Tween(begin: -11.0, end: 11.0), weight: 17),
      TweenSequenceItem(tween: Tween(begin: 11.0, end: -5.0), weight: 16),
      TweenSequenceItem(tween: Tween(begin: -5.0, end: 0.0), weight: 16),
    ]).animate(_shakeCtrl);

    _confettiCtrl = ConfettiController(duration: const Duration(seconds: 3));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _rollSub = context.read<PlayerProvider>().rollStream.listen(
          _onRollResult,
        );
      }
    });
  }

  @override
  void dispose() {
    _rollTimer?.cancel();
    _rollSub?.cancel();
    _pulseCtrl.dispose();
    _revealCtrl.dispose();
    _shakeCtrl.dispose();
    _confettiCtrl.dispose();
    super.dispose();
  }

  void _onRollResult(Map<String, dynamic> roll) {
    if (!_isRolling || !mounted) return;
    if (roll['category'] != 'dice') return;

    final pid = roll['playerid'] as String? ?? '';
    final myPid = widget.playerId ?? 'gm';
    if (pid == myPid && roll.containsKey('result')) {
      _stopRolling(roll['result'] as int);
    }
  }

  Future<void> _startRoll() async {
    if (_isRolling) return;

    _revealCtrl.reset();
    _shakeCtrl.reset();

    setState(() {
      _isRolling = true;
      _result = null;
    });

    _triggerRollHaptics();
    SoundService.instance.playRolling();
    context.read<PlayerProvider>().rollDice(
      widget.playerId,
      sides: _selectedSides,
    );

    _pulseCtrl.repeat(reverse: true);
    _rollTimer = Timer.periodic(const Duration(milliseconds: 55), (_) {
      if (mounted)
        setState(() => _displayNumber = _rng.nextInt(_selectedSides) + 1);
    });

    Future.delayed(const Duration(seconds: 5), () {
      if (_isRolling && mounted) _stopRolling(null);
    });
  }

  void _stopRolling(int? result) {
    _rollTimer?.cancel();
    _pulseCtrl.stop();

    final finalResult = result ?? (_rng.nextInt(_selectedSides) + 1);
    if (_selectedSides == 20 && finalResult != 1)
      _revealCtrl.value = 0.0;
    else if (_selectedSides != 20)
      _revealCtrl.value = 0.0;

    setState(() {
      _isRolling = false;
      _result = finalResult;
      _displayNumber = finalResult;
    });

    _playResultEffects(finalResult);
  }

  Future<void> _playResultEffects(int result) async {
    if (_selectedSides == 20) {
      if (result == 20) {
        await HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 110));
        await HapticFeedback.heavyImpact();
        _confettiCtrl.play();
        _revealCtrl.forward(from: 0.0);
        SoundService.instance.playCriticalSuccess();
        return;
      } else if (result == 1) {
        for (int i = 0; i < 4; i++) {
          await HapticFeedback.mediumImpact();
          await Future.delayed(const Duration(milliseconds: 80));
        }
        _shakeCtrl.forward(from: 0.0);
        SoundService.instance.playCriticalFailure();
        return;
      }
    }

    await HapticFeedback.heavyImpact();
    _revealCtrl.forward(from: 0.0);
    SoundService.instance.playResult();
  }

  Future<void> _triggerRollHaptics() async {
    for (int i = 0; i < 3; i++) {
      await HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 90));
    }
  }

  // ── Styling helpers ───────────────────────────────────────────────────────
  Color get _borderColor {
    if (_selectedSides == 20) {
      if (_result == 20) return Colors.amber;
      if (_result == 1) return Colors.redAccent;
    }
    if (_isRolling) return Colors.deepPurpleAccent;
    if (_result != null) return Colors.deepPurple;
    return Colors.deepPurple.withOpacity(0.4);
  }

  Color get _bgColor {
    if (_selectedSides == 20) {
      if (_result == 20) return const Color(0xFF1F1200);
      if (_result == 1) return const Color(0xFF1F0000);
    }
    return const Color(0xFF12082E);
  }

  List<BoxShadow> get _glow {
    if (_selectedSides == 20) {
      if (_result == 20) {
        return [
          BoxShadow(
            color: Colors.amber.withOpacity(0.55),
            blurRadius: 32,
            spreadRadius: 6,
          ),
        ];
      }
      if (_result == 1) {
        return [
          BoxShadow(
            color: Colors.red.withOpacity(0.55),
            blurRadius: 32,
            spreadRadius: 6,
          ),
        ];
      }
    }
    if (_isRolling)
      return [
        BoxShadow(
          color: Colors.deepPurpleAccent.withOpacity(0.4),
          blurRadius: 20,
        ),
      ];
    return [];
  }

  Color get _numberColor {
    if (_selectedSides == 20) {
      if (_result == 20) return Colors.amber;
      if (_result == 1) return Colors.redAccent;
    }
    return Colors.white;
  }

  String get _statusLabel {
    if (_selectedSides == 20) {
      if (_result == 20) return '⚔️  CRITICAL SUCCESS!';
      if (_result == 1) return '💀  CRITICAL FAILURE!';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        ConfettiWidget(
          confettiController: _confettiCtrl,
          blastDirectionality: BlastDirectionality.explosive,
          colors: const [
            Colors.amber,
            Colors.orange,
            Colors.yellow,
            Colors.white,
            Colors.deepPurpleAccent,
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'MULTI-DICE ROLLER',
                style: GoogleFonts.cinzel(
                  fontSize: 12,
                  letterSpacing: 3,
                  color: Colors.white24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // ── Dice Selector ─────────────────────────────────────────────
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _diceOptions.map((s) {
                    final isSelected = _selectedSides == s;
                    return GestureDetector(
                      onTap: () {
                        if (_isRolling) return;
                        setState(() {
                          _selectedSides = s;
                          _displayNumber = s;
                          _result = null;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.deepPurpleAccent
                              : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.white12,
                          ),
                        ),
                        child: Text(
                          'D$s',
                          style: GoogleFonts.cinzel(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.white38,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 30),

              // ── Die face ────────────────────────────────────────────────
              AnimatedBuilder(
                animation: Listenable.merge([
                  _pulseCtrl,
                  _revealCtrl,
                  _shakeCtrl,
                ]),
                builder: (context, _) {
                  double scale = 1.0;
                  if (_isRolling)
                    scale = _pulseAnim.value;
                  else if (_result != null &&
                      (_selectedSides != 20 || _result != 1))
                    scale = _revealAnim.value;

                  return Transform.translate(
                    offset: Offset(_shakeAnim.value, 0),
                    child: Transform.scale(
                      scale: scale.clamp(0.0, 2.0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _bgColor,
                          border: Border.all(color: _borderColor, width: 3.5),
                          boxShadow: _glow,
                        ),
                        child: Center(
                          child: Text(
                            '$_displayNumber',
                            style: GoogleFonts.cinzel(
                              fontSize: 52,
                              fontWeight: FontWeight.w900,
                              color: _numberColor,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 14),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _statusLabel.isNotEmpty
                    ? Text(
                        _statusLabel,
                        key: ValueKey(_statusLabel),
                        style: GoogleFonts.cinzel(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: _result == 20
                              ? Colors.amber
                              : Colors.redAccent,
                        ),
                      )
                    : SizedBox(
                        key: const ValueKey('empty'),
                        height: _result != null ? 0 : 20,
                      ),
              ),

              const SizedBox(height: 24),

              // ── Roll button ───────────────────────────────────────────────
              GestureDetector(
                onTap: _isRolling ? null : _startRoll,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isRolling
                          ? [Colors.grey.shade700, Colors.grey.shade800]
                          : [const Color(0xFF7C3AED), const Color(0xFF4C1D95)],
                    ),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: _isRolling
                        ? []
                        : [
                            BoxShadow(
                              color: Colors.deepPurple.withOpacity(0.5),
                              blurRadius: 14,
                              offset: const Offset(0, 5),
                            ),
                          ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.casino, color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        _isRolling ? 'Rolling...' : 'Roll D$_selectedSides',
                        style: GoogleFonts.cinzel(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
