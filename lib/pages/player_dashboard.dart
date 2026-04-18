import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dnd_app/models/player.dart';
import 'package:dnd_app/providers/player_provider.dart';
import 'package:dnd_app/widgets/dice_roller.dart';
import 'package:dnd_app/widgets/combat_log.dart';

/// Personal player dashboard — shows only this player's stats,
/// and listens to live updates from the WebSocket via PlayerProvider.
class PlayerDashboard extends StatelessWidget {
  final Player player;
  const PlayerDashboard({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, provider, _) {
        // Always show the live version from provider if available
        final live = provider.players.firstWhere(
          (p) => p.id == player.id,
          orElse: () => player,
        );

        return Scaffold(
          backgroundColor: const Color(0xFF0D0D1A),
          body: CustomScrollView(
            slivers: [
              // ── Header ─────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: const Color(0xFF1A0A2E),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF2D1B69), Color(0xFF0D0D1A)],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        CircleAvatar(
                          radius: 38,
                          backgroundColor: Colors.deepPurple.withValues(
                            alpha: 0.5,
                          ),
                          child: Text(
                            live.name.isNotEmpty
                                ? live.name[0].toUpperCase()
                                : '?',
                            style: GoogleFonts.cinzel(
                              fontSize: 32,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          live.name,
                          style: GoogleFonts.cinzel(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${live.race}  ·  ${live.playerClass}  ·  Level ${live.level}',
                          style: GoogleFonts.cinzel(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Content ────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // XP Bar
                    _XpBar(xp: live.xp, level: live.level),
                    const SizedBox(height: 20),

                    // Vital stats
                    Row(
                      children: [
                        Expanded(
                          child: _VitalCard(
                            label: 'HP',
                            current: live.health,
                            max: live.maxHealth,
                            color: Colors.redAccent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _VitalCard(
                            label: 'MP',
                            current: live.mana,
                            max: live.maxMana,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _StatChip(
                            label: 'Gold',
                            value: '${live.gold}',
                            icon: Icons.monetization_on,
                            color: Colors.amber,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatChip(
                            label: 'Armor Class',
                            value: '${live.armorClass}',
                            icon: Icons.shield,
                            color: Colors.tealAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Ability scores
                    Row(
                      children: [
                        _SectionTitle('Ability Scores'),
                        const SizedBox(width: 8),
                        if (live.availablePoints > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.blueAccent.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.stars,
                                  color: Colors.blueAccent,
                                  size: 14,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  '${live.availablePoints} PTS AVAILABLE',
                                  style: const TextStyle(
                                    color: Colors.blueAccent,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.1,
                      children: [
                        _AbilityScore(
                          abbr: 'STR',
                          value: live.strength,
                          playerId: live.id!,
                          statKey: 'strength',
                          canIncrease: live.availablePoints > 0,
                        ),
                        _AbilityScore(
                          abbr: 'DEX',
                          value: live.dexterity,
                          playerId: live.id!,
                          statKey: 'dexterity',
                          canIncrease: live.availablePoints > 0,
                        ),
                        _AbilityScore(
                          abbr: 'CON',
                          value: live.constitution,
                          playerId: live.id!,
                          statKey: 'constitution',
                          canIncrease: live.availablePoints > 0,
                        ),
                        _AbilityScore(
                          abbr: 'INT',
                          value: live.intelligence,
                          playerId: live.id!,
                          statKey: 'intelligence',
                          canIncrease: live.availablePoints > 0,
                        ),
                        _AbilityScore(
                          abbr: 'WIS',
                          value: live.wisdom,
                          playerId: live.id!,
                          statKey: 'wisdom',
                          canIncrease: live.availablePoints > 0,
                        ),
                        _AbilityScore(
                          abbr: 'CHA',
                          value: live.charisma,
                          playerId: live.id!,
                          statKey: 'charisma',
                          canIncrease: live.availablePoints > 0,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Misc
                    _SectionTitle('Combat'),
                    const SizedBox(height: 12),
                    _InfoRow('Proficiency Bonus', '+${live.proficiencyBonus}'),
                    _InfoRow(
                      'XP to next level',
                      '${(live.level * 10) - live.xp} xp',
                    ),

                    // ── Dice roller ────────────────────────────────────
                    const SizedBox(height: 24),
                    const Divider(color: Colors.white12, height: 1),
                    DiceRoller(playerId: live.id, displayName: live.name),

                    // ── Combat log ─────────────────────────────────────
                    const Divider(color: Colors.white12, height: 1),
                    const CombatLog(),
                    const SizedBox(height: 12),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _XpBar extends StatelessWidget {
  final int xp, level;
  const _XpBar({required this.xp, required this.level});

  @override
  Widget build(BuildContext context) {
    final needed = level * 10;
    final progress = (xp / needed).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level $level',
                style: GoogleFonts.cinzel(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$xp / $needed XP',
                style: GoogleFonts.cinzel(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Colors.deepPurpleAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VitalCard extends StatelessWidget {
  final String label;
  final int current, max;
  final Color color;
  const _VitalCard({
    required this.label,
    required this.current,
    required this.max,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (current / max).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.cinzel(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$current / $max',
            style: GoogleFonts.cinzel(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.cinzel(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 11,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.cinzel(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AbilityScore extends StatelessWidget {
  final String abbr;
  final int value;
  final String playerId;
  final String statKey;
  final bool canIncrease;

  const _AbilityScore({
    required this.abbr,
    required this.value,
    required this.playerId,
    required this.statKey,
    required this.canIncrease,
  });

  int get _modifier => ((value - 10) / 2).floor();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: canIncrease
              ? Colors.blueAccent.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  abbr,
                  style: GoogleFonts.cinzel(
                    color: Colors.white38,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$value',
                  style: GoogleFonts.cinzel(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _modifier >= 0 ? '+$_modifier' : '$_modifier',
                  style: GoogleFonts.cinzel(
                    color: _modifier >= 0
                        ? Colors.greenAccent
                        : Colors.redAccent,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (canIncrease)
            Positioned(
              right: 0,
              top: 0,
              child: GestureDetector(
                onTap: () => context.read<PlayerProvider>().allocateStat(
                  playerId,
                  statKey,
                ),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(11),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                  child: const Icon(Icons.add, size: 14, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: GoogleFonts.cinzel(
      fontSize: 15,
      color: Colors.white54,
      fontWeight: FontWeight.bold,
    ),
  );
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.cinzel(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.cinzel(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
