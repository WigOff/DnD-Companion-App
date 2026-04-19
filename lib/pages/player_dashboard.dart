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
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedSpell;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        final live = provider.players.firstWhere(
          (p) => p.id == widget.player.id,
          orElse: () => widget.player,
        );

        return Scaffold(
          backgroundColor: const Color(0xFF08081A),
          body: NestedScrollView(
            headerSliverBuilder: (ctx, innerScrolled) => [
              _buildSliverHeader(ctx, live),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                _StatsTab(live: live, provider: provider),
                _ActionsTab(
                  live: live,
                  provider: provider,
                  selectedSpell: _selectedSpell,
                  onSpellSelected: (s) => setState(() => _selectedSpell = s),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSliverHeader(BuildContext ctx, Player live) {
    const expandedHeight = 420.0;

    return SliverOverlapAbsorber(
      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(ctx),
      sliver: SliverAppBar(
        expandedHeight: expandedHeight,
        pinned: true,
        backgroundColor: const Color(0xFF12082E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: FlexibleSpaceBar(
          collapseMode: CollapseMode.parallax,
          background: _HeaderBackground(live: live),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF12082E),
              border: Border(
                bottom: BorderSide(
                  color: Colors.deepPurpleAccent.withValues(alpha: 0.25),
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.deepPurpleAccent,
              indicatorWeight: 3,
              labelStyle: GoogleFonts.cinzel(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              unselectedLabelStyle: GoogleFonts.cinzel(fontSize: 11),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white38,
              tabs: const [
                Tab(icon: Icon(Icons.bar_chart, size: 18), text: 'Stats'),
                Tab(
                  icon: Icon(Icons.flash_on, size: 18),
                  text: 'Actions & Log',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Header Background ────────────────────────────────────────────────────────

class _HeaderBackground extends StatelessWidget {
  final Player live;
  const _HeaderBackground({required this.live});

  @override
  Widget build(BuildContext context) {
    final hasSubclass = live.subclass.isNotEmpty && live.subclass != 'None';

    return Stack(
      fit: StackFit.expand,
      children: [
        // Base Gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A1A35), Color(0xFF08081A)],
            ),
          ),
        ),
        // Decorative background elements
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.deepPurpleAccent.withValues(alpha: 0.05),
            ),
          ),
        ),
        // Main Content
        SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 60), // Clear the back button
              // Avatar with glow
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.deepPurpleAccent.withValues(alpha: 0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurpleAccent.withValues(alpha: 0.2),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.deepPurple.withValues(alpha: 0.3),
                    backgroundImage: AssetImage(
                      'assets/images/races/${live.race.toLowerCase().replaceAll('-', '_')}.png',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Character Info Glass Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 24,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.03),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            live.name.toUpperCase(),
                            style: GoogleFonts.cinzel(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${live.race} ◈ ${live.playerClass} ◈ level ${live.level}'
                              .toUpperCase(),
                          style: GoogleFonts.cinzel(
                            fontSize: 10,
                            color: Colors.white54,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        if (hasSubclass) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.amberAccent.withValues(alpha: 0.2),
                                  Colors.orangeAccent.withValues(alpha: 0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.amberAccent.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            child: Text(
                              live.subclass.toUpperCase(),
                              style: GoogleFonts.cinzel(
                                fontSize: 11,
                                color: Colors.amberAccent,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const Spacer(), // Dynamically pushes everything away from bottom
              const SizedBox(height: 64), // Minimum buffer from Tabs
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Tab 1: Stats ─────────────────────────────────────────────────────────────

class _StatsTab extends StatelessWidget {
  final Player live;
  final PlayerProvider provider;
  const _StatsTab({required this.live, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (ctx) => CustomScrollView(
        slivers: [
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(ctx),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Subclass description card
                if (live.subclass != 'None' &&
                    live.subclassDescription.isNotEmpty)
                  _SubclassCard(
                    subclass: live.subclass,
                    description: live.subclassDescription,
                  ),
                if (live.subclass != 'None' &&
                    live.subclassDescription.isNotEmpty)
                  const SizedBox(height: 16),

                // XP bar
                _XpBar(xp: live.xp, level: live.level),
                const SizedBox(height: 16),

                // HP + MP
                Row(
                  children: [
                    Expanded(
                      child: _VitalCard(
                        label: 'HP',
                        current: live.health,
                        max: live.maxHealth,
                        color: Colors.redAccent,
                        icon: Icons.favorite,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _VitalCard(
                        label: 'MP',
                        current: live.mana,
                        max: live.maxMana,
                        color: Colors.blueAccent,
                        icon: Icons.water_drop,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Gold + AC
                Row(
                  children: [
                    Expanded(
                      child: _QuickStatCard(
                        label: 'Gold',
                        value: '${live.gold}',
                        icon: Icons.monetization_on,
                        color: Colors.amber,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickStatCard(
                        label: 'Armor Class',
                        value: '${live.armorClass}',
                        icon: Icons.shield,
                        color: Colors.tealAccent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickStatCard(
                        label: 'Prof. Bonus',
                        value: '+${live.proficiencyBonus}',
                        icon: Icons.star,
                        color: Colors.purpleAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Ability Scores
                Row(
                  children: [
                    Text(
                      'ABILITY SCORES',
                      style: GoogleFonts.cinzel(
                        fontSize: 11,
                        color: Colors.white38,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (live.availablePoints > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
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
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${live.availablePoints} pts',
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
                  childAspectRatio: 1.05,
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
                const SizedBox(height: 24),

                // Equipped weapon quick-view
                if (live.weapon.isNotEmpty) ...[
                  _SectionLabel('ARMED WITH'),
                  const SizedBox(height: 8),
                  _EquippedWeaponBanner(weapon: live.weapon),
                  const SizedBox(height: 16),
                ],

                _SectionLabel('COMBAT INFO'),
                const SizedBox(height: 8),
                _InfoRow(
                  'XP to Next Level',
                  '${(live.level * 10) - live.xp} xp',
                ),
                _InfoRow('Proficiency Bonus', '+${live.proficiencyBonus}'),
                _InfoRow(
                  'Equipped Weapon',
                  live.weapon.isEmpty ? '—' : live.weapon,
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tab 2: Actions ───────────────────────────────────────────────────────────

class _ActionsTab extends StatelessWidget {
  final Player live;
  final PlayerProvider provider;
  final String? selectedSpell;
  final ValueChanged<String?> onSpellSelected;

  const _ActionsTab({
    required this.live,
    required this.provider,
    required this.selectedSpell,
    required this.onSpellSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (ctx) => CustomScrollView(
        slivers: [
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(ctx),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Weapon ──────────────────────────────────────────
                _SectionLabel('WEAPON'),
                const SizedBox(height: 10),
                _WeaponSection(live: live, provider: provider),
                const SizedBox(height: 24),

                // ── Spells ──────────────────────────────────────────
                _SectionLabel('SPELLS'),
                const SizedBox(height: 10),
                if (live.knownSpells.isEmpty)
                  _EmptyState(
                    icon: Icons.auto_fix_high,
                    message:
                        'No spells known yet.\nYour GM can grant you spells.',
                    color: Colors.deepPurpleAccent,
                  )
                else
                  _SpellSection(
                    live: live,
                    provider: provider,
                    selectedSpell: selectedSpell,
                    onSpellSelected: onSpellSelected,
                  ),
                const SizedBox(height: 24),

                // ── Inventory ────────────────────────────────────────
                _SectionLabel('INVENTORY'),
                const SizedBox(height: 10),
                if (live.inventoryWeapons.isEmpty && live.knownSpells.isEmpty)
                  _EmptyState(
                    icon: Icons.backpack,
                    message: 'Your inventory is empty.',
                    color: Colors.white38,
                  )
                else ...[
                  if (live.inventoryWeapons.isNotEmpty) ...[
                    _SmallLabel('Weapons'),
                    const SizedBox(height: 8),
                    _InventoryChips(
                      items: live.inventoryWeapons,
                      equippedItem: live.weapon,
                      isSpell: false,
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (live.knownSpells.isNotEmpty) ...[
                    _SmallLabel('Spells'),
                    const SizedBox(height: 8),
                    _InventoryChips(
                      items: live.knownSpells,
                      equippedItem: null,
                      isSpell: true,
                    ),
                  ],
                ],
                const SizedBox(height: 24),

                // ── Dice Roller ──────────────────────────────────────
                const Divider(color: Colors.white10, height: 1),
                const SizedBox(height: 16),
                DiceRoller(playerId: live.id, displayName: live.name),
                const SizedBox(height: 24),

                // ── Combat Log ───────────────────────────────────────
                _SectionLabel('COMBAT LOG'),
                const SizedBox(height: 10),
                const CombatLog(shrinkWrap: true),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Weapon Section Widget ────────────────────────────────────────────────────

class _WeaponSection extends StatelessWidget {
  final Player live;
  final PlayerProvider provider;
  const _WeaponSection({required this.live, required this.provider});

  @override
  Widget build(BuildContext context) {
    final weaponInfo = kAllWeapons[live.weapon];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orangeAccent.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            value: live.weapon.isNotEmpty ? live.weapon : null,
            dropdownColor: const Color(0xFF1A0A2E),
            isExpanded: true,
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
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 12,
              ),
            ),
            items: live.inventoryWeapons.map((w) {
              final info = kAllWeapons[w];
              return DropdownMenuItem(
                value: w,
                child: Text(
                  info != null ? '$w  (${info.damage})' : w,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (v) {
              if (v != null) provider.equipWeapon(live.id!, v);
            },
          ),
          if (weaponInfo != null) ...[
            const SizedBox(height: 10),
            _DescriptionBox(
              text: weaponInfo.description,
              color: Colors.orangeAccent,
            ),
          ],
          const SizedBox(height: 12),
          ElevatedButton.icon(
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
              disabledBackgroundColor: Colors.white.withValues(alpha: 0.04),
              disabledForegroundColor: Colors.white24,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Spell Section Widget ─────────────────────────────────────────────────────

class _SpellSection extends StatelessWidget {
  final Player live;
  final PlayerProvider provider;
  final String? selectedSpell;
  final ValueChanged<String?> onSpellSelected;

  const _SpellSection({
    required this.live,
    required this.provider,
    required this.selectedSpell,
    required this.onSpellSelected,
  });

  @override
  Widget build(BuildContext context) {
    final validSpell =
        selectedSpell != null && live.knownSpells.contains(selectedSpell)
        ? selectedSpell
        : null;
    final spellInfo = validSpell != null ? kAllSpells[validSpell] : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurpleAccent.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.deepPurpleAccent.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            value: validSpell,
            dropdownColor: const Color(0xFF1A0A2E),
            isExpanded: true,
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
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 12,
              ),
            ),
            items: live.knownSpells.map((s) {
              final info = kAllSpells[s];
              final suffix = info != null
                  ? (info.healing
                        ? '  💚 heal ${info.damage}'
                        : info.damage != '0'
                        ? '  (${info.damage})'
                        : '  ✦ utility')
                  : '';
              return DropdownMenuItem(
                value: s,
                child: Text('$s$suffix', overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: onSpellSelected,
          ),
          if (spellInfo != null) ...[
            const SizedBox(height: 10),
            _DescriptionBox(
              text: spellInfo.description,
              color: Colors.deepPurpleAccent,
            ),
          ],
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: validSpell != null
                ? () => provider.castSpell(live.id!, validSpell)
                : null,
            icon: const Icon(Icons.auto_fix_high, size: 18),
            label: Text(
              validSpell != null
                  ? '✨  Cast $validSpell'
                  : 'Select a spell first',
              style: GoogleFonts.cinzel(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurpleAccent.withValues(alpha: 0.2),
              foregroundColor: Colors.deepPurpleAccent,
              disabledBackgroundColor: Colors.white.withValues(alpha: 0.04),
              disabledForegroundColor: Colors.white24,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _SubclassCard extends StatelessWidget {
  final String subclass;
  final String description;
  const _SubclassCard({required this.subclass, required this.description});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.withValues(alpha: 0.12),
            Colors.deepOrange.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subclass,
                  style: GoogleFonts.cinzel(
                    color: Colors.amberAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.cinzel(
                    color: Colors.white54,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EquippedWeaponBanner extends StatelessWidget {
  final String weapon;
  const _EquippedWeaponBanner({required this.weapon});

  @override
  Widget build(BuildContext context) {
    final info = kAllWeapons[weapon];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.orangeAccent.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.gavel, color: Colors.orangeAccent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  weapon,
                  style: GoogleFonts.cinzel(
                    color: Colors.orangeAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (info != null)
                  Text(
                    info.description,
                    style: GoogleFonts.cinzel(
                      color: Colors.white38,
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
              ],
            ),
          ),
          if (info != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.orangeAccent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                info.damage,
                style: GoogleFonts.cinzel(
                  color: Colors.orangeAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InventoryChips extends StatelessWidget {
  final List<String> items;
  final String? equippedItem;
  final bool isSpell;
  const _InventoryChips({
    required this.items,
    required this.equippedItem,
    required this.isSpell,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        final isEquipped = !isSpell && item == equippedItem;
        final info = isSpell ? kAllSpells[item] : kAllWeapons[item];
        final isHealing = isSpell && (info as SpellInfo?)?.healing == true;
        final Color chipColor = isEquipped
            ? Colors.orangeAccent
            : isSpell
            ? (isHealing ? Colors.greenAccent : Colors.deepPurpleAccent)
            : Colors.white54;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: chipColor.withValues(alpha: isEquipped ? 0.15 : 0.07),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: chipColor.withValues(alpha: isEquipped ? 0.5 : 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSpell
                    ? (isHealing ? Icons.healing : Icons.auto_fix_high)
                    : Icons.gavel,
                size: 13,
                color: chipColor,
              ),
              const SizedBox(width: 6),
              Text(
                item,
                style: GoogleFonts.cinzel(
                  fontSize: 12,
                  color: isEquipped ? Colors.orangeAccent : Colors.white70,
                  fontWeight: isEquipped ? FontWeight.bold : FontWeight.normal,
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
    );
  }
}

class _XpBar extends StatelessWidget {
  final int xp, level;
  const _XpBar({required this.xp, required this.level});

  @override
  Widget build(BuildContext context) {
    final needed = level * 10;
    final progress = (xp / needed).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EXPERIENCE',
                    style: GoogleFonts.cinzel(
                      color: Colors.white38,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    'Level $level',
                    style: GoogleFonts.cinzel(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.deepPurpleAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.deepPurpleAccent.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  '$xp / $needed XP',
                  style: GoogleFonts.cinzel(
                    color: Colors.deepPurpleAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOutExpo,
                builder: (_, value, __) => FractionallySizedBox(
                  widthFactor: value,
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.deepPurple, Colors.deepPurpleAccent],
                      ),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurpleAccent.withValues(alpha: 0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
  final IconData icon;
  const _VitalCard({
    required this.label,
    required this.current,
    required this.max,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final progress = max > 0 ? (current / max).clamp(0.0, 1.0) : 0.0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.cinzel(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
              Icon(icon, size: 16, color: color.withValues(alpha: 0.5)),
            ],
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$current',
                  style: GoogleFonts.cinzel(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                TextSpan(
                  text: ' / $max',
                  style: GoogleFonts.cinzel(
                    color: Colors.white38,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.4),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _QuickStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.02)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.1),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.cinzel(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.cinzel(
              color: Colors.white38,
              fontSize: 8,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: canIncrease
              ? Colors.blueAccent.withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.08),
          width: canIncrease ? 1.5 : 1,
        ),
        boxShadow: [
          if (canIncrease)
            BoxShadow(
              color: Colors.blueAccent.withValues(alpha: 0.1),
              blurRadius: 8,
              spreadRadius: 1,
            ),
        ],
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
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$value',
                  style: GoogleFonts.cinzel(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color:
                        (_modifier >= 0 ? Colors.greenAccent : Colors.redAccent)
                            .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color:
                          (_modifier >= 0
                                  ? Colors.greenAccent
                                  : Colors.redAccent)
                              .withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    _modifier >= 0 ? '+$_modifier' : '$_modifier',
                    style: GoogleFonts.cinzel(
                      color: _modifier >= 0
                          ? Colors.greenAccent
                          : Colors.redAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
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
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                  child: const Icon(Icons.add, size: 12, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DescriptionBox extends StatelessWidget {
  final String text;
  final Color color;
  const _DescriptionBox({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color.withValues(alpha: 0.8),
          fontSize: 12,
          fontStyle: FontStyle.italic,
          height: 1.5,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color color;
  const _EmptyState({
    required this.icon,
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.05),
            ),
            child: Icon(icon, color: color.withValues(alpha: 0.4), size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.cinzel(
              color: Colors.white30,
              fontSize: 12,
              height: 1.6,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;
  const _SectionLabel(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.cinzel(
          fontSize: 10,
          color: Colors.white24,
          fontWeight: FontWeight.w900,
          letterSpacing: 2.5,
        ),
      ),
    );
  }
}

class _SmallLabel extends StatelessWidget {
  final String text;
  const _SmallLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.cinzel(
        fontSize: 12,
        color: Colors.white54,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.cinzel(
              color: Colors.white38,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.cinzel(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
