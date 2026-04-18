import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:dnd_app/providers/player_provider.dart';

/// Scrollable combat log showing all dice rolls from the current session.
/// Auto-scrolls to the newest entry. Color-coded for nat 1/20.
class CombatLog extends StatefulWidget {
  const CombatLog({super.key});

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
        final log = provider.rollLog;
        if (log.isNotEmpty) _scrollToBottom();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  const Icon(Icons.history_edu, color: Colors.white30, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'COMBAT LOG',
                    style: GoogleFonts.cinzel(
                      fontSize: 11,
                      letterSpacing: 2.5,
                      color: Colors.white30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${log.length} roll${log.length == 1 ? '' : 's'}',
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
                    'No rolls yet — make history!',
                    style: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 13),
                  ),
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
    final result = entry['result'] as int? ?? 0;
    final message = entry['message'] as String? ?? '';
    final isNat20 = result == 20;
    final isNat1 = result == 1;

    final borderColor = isNat20
        ? Colors.amber.withOpacity(0.35)
        : isNat1
            ? Colors.red.withOpacity(0.35)
            : Colors.white.withOpacity(0.06);

    final bgColor = isNat20
        ? Colors.amber.withOpacity(0.06)
        : isNat1
            ? Colors.red.withOpacity(0.06)
            : Colors.white.withOpacity(0.03);

    final textColor = isNat20
        ? Colors.amber.shade300
        : isNat1
            ? Colors.red.shade300
            : Colors.white70;

    final badge = isNat20
        ? Colors.amber.withOpacity(0.25)
        : isNat1
            ? Colors.red.withOpacity(0.25)
            : Colors.white.withOpacity(0.08);

    final emoji = isNat20 ? '⚔️' : isNat1 ? '💀' : '🎲';

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
            child: Text(message, style: TextStyle(fontSize: 13, color: textColor)),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: badge,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$result',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isNat20
                    ? Colors.amber
                    : isNat1
                        ? Colors.redAccent
                        : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
