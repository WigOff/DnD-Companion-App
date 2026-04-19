import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:dnd_app/providers/player_provider.dart';

/// Scrollable combat log showing all dice rolls from the current session.
/// Auto-scrolls to the newest entry. Color-coded for nat 1/20.
class CombatLog extends StatefulWidget {
  final bool shrinkWrap;
  const CombatLog({super.key, this.shrinkWrap = false});

  @override
  State<CombatLog> createState() => _CombatLogState();
}

class _CombatLogState extends State<CombatLog> {
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (widget.shrinkWrap) return; // Parent handles scrolling
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, provider, _) {
        final log = provider.log;
        if (log.isNotEmpty) _scrollToBottom();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: widget.shrinkWrap ? MainAxisSize.min : MainAxisSize.max,
          children: [
            // ── Header ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.history_edu,
                    color: Colors.white30,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'SESSION LOG',
                    style: GoogleFonts.cinzel(
                      fontSize: 11,
                      letterSpacing: 2.5,
                      color: Colors.white30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${log.length} event${log.length == 1 ? '' : 's'}',
                    style: const TextStyle(color: Colors.white24, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white10, height: 1),

            // ── Log entries ───────────────────────────────────────────────
            if (log.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'No logs yet — make history!',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.25),
                      fontSize: 13,
                    ),
                  ),
                ),
              )
            else if (widget.shrinkWrap)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: Column(
                  children: log.map((e) => _LogEntry(entry: e)).toList(),
                ),
              )
            else
              SizedBox(
                height: 220,
                child: ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  itemCount: log.length,
                  itemBuilder: (_, i) => _LogEntry(entry: log[i]),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ─── Single log entry ─────────────────────────────────────────────────────────

class _LogEntry extends StatelessWidget {
  final Map<String, dynamic> entry;
  const _LogEntry({required this.entry});

  @override
  Widget build(BuildContext context) {
    final category = entry['category'] as String? ?? 'dice';
    final result = entry['result'] as int? ?? 0;
    final message = entry['message'] as String? ?? '';

    Color mainColor = Colors.white70;
    Color bgColor = Colors.white.withOpacity(0.03);
    Color borderColor = Colors.white.withOpacity(0.06);
    Color badgeColor = Colors.white.withOpacity(0.08);
    String emoji = '🎲';
    bool showBadge = false;

    switch (category) {
      case 'system':
        mainColor = Colors.white54;
        bgColor = Colors.white.withValues(alpha: 0.02);
        borderColor = Colors.white.withValues(alpha: 0.1);
        emoji = 'ℹ️';
        break;
      case 'dice':
        final isNat20 = result == 20;
        final isNat1 = result == 1;
        showBadge = true;
        if (isNat20) {
          mainColor = Colors.amber.shade300;
          bgColor = Colors.amber.withValues(alpha: 0.08);
          borderColor = Colors.amber.withValues(alpha: 0.4);
          badgeColor = Colors.amber.withValues(alpha: 0.3);
          emoji = '⚔️';
        } else if (isNat1) {
          mainColor = Colors.red.shade300;
          bgColor = Colors.red.withValues(alpha: 0.08);
          borderColor = Colors.red.withValues(alpha: 0.4);
          badgeColor = Colors.red.withValues(alpha: 0.3);
          emoji = '💀';
        } else {
          emoji = '🎲';
        }
        break;
      case 'level_up':
        mainColor = Colors.purpleAccent.shade100;
        bgColor = Colors.purple.withValues(alpha: 0.1);
        borderColor = Colors.purpleAccent.withValues(alpha: 0.4);
        emoji = '⬆️';
        break;
      case 'stat_alloc':
        mainColor = Colors.blueAccent.shade100;
        bgColor = Colors.blue.withValues(alpha: 0.1);
        borderColor = Colors.blueAccent.withValues(alpha: 0.4);
        emoji = '📊';
        break;
      case 'hp_change':
        final isDamage = message.contains('(-');
        mainColor = isDamage
            ? Colors.redAccent.shade100
            : Colors.greenAccent.shade100;
        bgColor = (isDamage ? Colors.red : Colors.green).withValues(
          alpha: 0.08,
        );
        borderColor = (isDamage ? Colors.redAccent : Colors.greenAccent)
            .withValues(alpha: 0.3);
        emoji = isDamage ? '💥' : '💖';
        break;
      case 'mp_change':
        mainColor = Colors.blue.shade200;
        bgColor = Colors.blue.withValues(alpha: 0.08);
        borderColor = Colors.blue.withValues(alpha: 0.3);
        emoji = '💧';
        break;
      case 'gold_change':
        mainColor = Colors.amber.shade200;
        bgColor = Colors.amber.withValues(alpha: 0.08);
        borderColor = Colors.amber.withValues(alpha: 0.3);
        emoji = '💰';
        break;
      case 'reward':
        mainColor = Colors.amberAccent;
        bgColor = Colors.amber.withValues(alpha: 0.1);
        borderColor = Colors.amberAccent.withValues(alpha: 0.4);
        emoji = '⭐';
        break;
      case 'equip':
        mainColor = Colors.orangeAccent;
        bgColor = Colors.orange.withValues(alpha: 0.08);
        borderColor = Colors.orangeAccent.withValues(alpha: 0.3);
        emoji = '🛡️';
        break;
      case 'attack':
        mainColor = Colors.redAccent.shade100;
        bgColor = Colors.red.withValues(alpha: 0.08);
        borderColor = Colors.redAccent.withValues(alpha: 0.4);
        emoji = '⚔️';
        break;
      case 'spell':
        mainColor = Colors.deepPurpleAccent.shade100;
        bgColor = Colors.deepPurple.withValues(alpha: 0.1);
        borderColor = Colors.deepPurpleAccent.withValues(alpha: 0.4);
        emoji = '✨';
        break;
      case 'heal':
        mainColor = Colors.greenAccent.shade100;
        bgColor = Colors.green.withValues(alpha: 0.1);
        borderColor = Colors.greenAccent.withValues(alpha: 0.4);
        emoji = '💚';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 13, color: mainColor),
            ),
          ),
          if (showBadge) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$result',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: mainColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
