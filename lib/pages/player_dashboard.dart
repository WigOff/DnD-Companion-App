import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dnd_app/models/player.dart';
import 'package:dnd_app/providers/player_provider.dart';
import 'package:dnd_app/widgets/dice_roller.dart';
import 'package:dnd_app/widgets/combat_log.dart';
import 'package:dnd_app/data/class_loadouts.dart';

/// Personal player dashboard — shows only this player's stats,
/// and listens to live updates from the WebSocket via PlayerProvider.
class PlayerDashboard extends StatefulWidget {
  final Player player;
  const PlayerDashboard({super.key, required this.player});

  @override
  State<PlayerDashboard> createState() => _PlayerDashboardState();
}

class _PlayerDashboardState extends State<PlayerDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedSpell;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, provider, _) {
        // Always show the live version from provider if available
        final live = provider.players.firstWhere(
          (p) => p.id == widget.player.id,
          orElse: () => widget.player,
        );

        return Scaffold(
          backgroundColor: const Color(0xFF0D0D1A),
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
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
                          backgroundColor:
                              Colors.deepPurple.withValues(alpha: 0.5),
                          backgroundImage: AssetImage(
                            'assets/images/races/${live.race.toLowerCase().replaceAll('-', '_')}.png',
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
                        if (live.subclass != 'None')
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              live.subclass,
                              style: GoogleFonts.cinzel(
                                fontSize: 13,
                                color: Colors.amberAccent,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                bottom: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.deepPurpleAccent,
                  labelStyle: GoogleFonts.cinzel(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  unselectedLabelStyle: GoogleFonts.cinzel(fontSize: 11),
                  tabs: const [
                    Tab(icon: Icon(Icons.bar_chart, size: 18), text: 'Stats'),
                    Tab(
                      icon: Icon(Icons.sports_kabaddi, size: 18),
                      text: 'Actions',
                    ),
                    Tab(
                      icon: Icon(Icons.menu_book, size: 18),
                      text: 'Log',
                    ),
                  ],
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildStatsTab(live, provider),
                _buildActionsTab(live, provider),
                _buildLogTab(live),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Tab 1: Stats ───────────────────────────────────────────────────────────

  Widget _buildStatsTab(Player live, PlayerProvider provider) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      children: [
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
        if (live.weapon.isNotEmpty)
          _InfoRow('Equipped Weapon', live.weapon),
      ],
    );
  }

  // ── Tab 2: Actions ─────────────────────────────────────────────────────────

  Widget _buildActionsTab(Player live, PlayerProvider provider) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      children: [
        // ── Weapon Section ──────────────────────────────────
        _SectionTitle('Weapon'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.orangeAccent.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              // Weapon dropdown
              DropdownButtonFormField<String>(
                value: live.weapon.isNotEmpty ? live.weapon : null,
                dropdownColor: const Color(0xFF1A0A2E),
                style: GoogleFonts.cinzel(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Equipped Weapon',
                  labelStyle: GoogleFonts.cinzel(
                    color: Colors.orangeAccent,
                    fontSize: 12,
                  ),
                  prefixIcon: const Icon(
                    Icons.gavel,
                    color: Colors.orangeAccent,
                    size: 18,
                  ),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: live.inventoryWeapons
                    .map(
                      (w) => DropdownMenuItem(
                        value: w,
                        child: Row(
                          children: [
                            Text(w),
                            if (kAllWeapons.containsKey(w)) ...[
                              const SizedBox(width: 8),
                              Text(
                                '(${kAllWeapons[w]!.damage})',
                                style: GoogleFonts.cinzel(
                                  color: Colors.white38,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    provider.equipWeapon(live.id!, v);
                  }
                },
              ),
              const SizedBox(height: 12),
              // Attack button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: live.weapon.isNotEmpty
                      ? () => provider.attack(live.id!)
                      : null,
                  icon: const Icon(Icons.gavel, size: 18),
                  label: Text(
                    live.weapon.isNotEmpty
                        ? '⚔️  Attack with ${live.weapon}'
                        : 'No weapon equipped',
                    style: GoogleFonts.cinzel(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent.withValues(alpha: 0.2),
                    foregroundColor: Colors.orangeAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // ── Spell Section ───────────────────────────────────
        _SectionTitle('Spells'),
        const SizedBox(height: 12),
        if (live.knownSpells.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: Center(
              child: Text(
                'No spells known yet',
                style: GoogleFonts.cinzel(
                  color: Colors.white38,
                  fontSize: 13,
                ),
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.deepPurpleAccent.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                // Spell dropdown
                DropdownButtonFormField<String>(
                  value: _selectedSpell != null &&
                          live.knownSpells.contains(_selectedSpell)
                      ? _selectedSpell
                      : null,
                  dropdownColor: const Color(0xFF1A0A2E),
                  style: GoogleFonts.cinzel(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Select Spell',
                    labelStyle: GoogleFonts.cinzel(
                      color: Colors.deepPurpleAccent,
                      fontSize: 12,
                    ),
                    prefixIcon: const Icon(
                      Icons.auto_fix_high,
                      color: Colors.deepPurpleAccent,
                      size: 18,
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: live.knownSpells.map((s) {
                    final info = kAllSpells[s];
                    String suffix = '';
                    if (info != null) {
                      if (info.healing) {
                        suffix = ' (heal ${info.damage})';
                      } else if (info.damage != '0') {
                        suffix = ' (${info.damage})';
                      } else {
                        suffix = ' (utility)';
                      }
                    }
                    return DropdownMenuItem(
                      value: s,
                      child: Text('$s$suffix'),
                    );
                  }).toList(),
                  onChanged: (v) {
                    setState(() => _selectedSpell = v);
                  },
                ),
                const SizedBox(height: 12),
                // Cast button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _selectedSpell != null
                        ? () =>
                            provider.castSpell(live.id!, _selectedSpell!)
                        : null,
                    icon: const Icon(Icons.auto_fix_high, size: 18),
                    label: Text(
                      _selectedSpell != null
                          ? '✨  Cast $_selectedSpell'
                          : 'Select a spell first',
                      style: GoogleFonts.cinzel(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.deepPurpleAccent.withValues(alpha: 0.2),
                      foregroundColor: Colors.deepPurpleAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 24),

        // ── Inventory Overview ───────────────────────────────
        _SectionTitle('Inventory'),
        const SizedBox(height: 12),
        // Weapons
        if (live.inventoryWeapons.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: live.inventoryWeapons.map((w) {
              final isEquipped = w == live.weapon;
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isEquipped
                      ? Colors.orangeAccent.withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isEquipped
                        ? Colors.orangeAccent.withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.gavel,
                      size: 14,
                      color:
                          isEquipped ? Colors.orangeAccent : Colors.white38,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      w,
                      style: GoogleFonts.cinzel(
                        fontSize: 12,
                        color:
                            isEquipped ? Colors.orangeAccent : Colors.white70,
                        fontWeight:
                            isEquipped ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    if (isEquipped) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.check_circle,
                        size: 12,
                        color: Colors.orangeAccent,
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        const SizedBox(height: 12),
        // Spells
        if (live.knownSpells.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: live.knownSpells.map((s) {
              final info = kAllSpells[s];
              final isHealing = info?.healing ?? false;
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isHealing
                      ? Colors.greenAccent.withValues(alpha: 0.1)
                      : Colors.deepPurpleAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isHealing
                        ? Colors.greenAccent.withValues(alpha: 0.3)
                        : Colors.deepPurpleAccent.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isHealing ? Icons.healing : Icons.auto_fix_high,
                      size: 14,
                      color: isHealing
                          ? Colors.greenAccent
                          : Colors.deepPurpleAccent,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      s,
                      style: GoogleFonts.cinzel(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

        const SizedBox(height: 24),
        // ── Dice roller ────────────────────────────────────
        const Divider(color: Colors.white12, height: 1),
        DiceRoller(playerId: live.id, displayName: live.name),
      ],
    );
  }

  // ── Tab 3: Combat Log ──────────────────────────────────────────────────────

  Widget _buildLogTab(Player live) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 40),
      child: CombatLog(),
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
