import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dnd_app/models/player.dart';
import 'package:dnd_app/providers/player_provider.dart';
import 'package:dnd_app/widgets/dice_roller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dnd_app/widgets/combat_log.dart';
import 'package:dnd_app/data/class_loadouts.dart';

class GameMaster extends StatefulWidget {
  const GameMaster({super.key});

  @override
  State<GameMaster> createState() => _GameMasterState();
}

class _GameMasterState extends State<GameMaster> with TickerProviderStateMixin {
  final Map<String, int> _hpMods = {};
  final Map<String, int> _mpMods = {};
  final Map<String, int> _goldMods = {};
  final Map<String, int> _xpMods = {};
  final Map<String, int> _acMods = {};

  // Rewards tab state
  String? _rewardPlayerId;
  String _rewardType = 'spell'; // 'spell' or 'weapon'
  String? _rewardItem;

  late TabController _tabController;
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _currentTab = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Stat modifier widget (reused per stat row in the player cards) ─────────

  Widget _buildStatModifier({
    required String label,
    required int current,
    required int? max,
    required int val,
    required Function(int) onUpdate,
    required Function(int) onValueChange,
    Color? color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: $current${max != null ? ' / $max' : ''}',
          style: GoogleFonts.cinzel(
            fontWeight: FontWeight.bold,
            color: color ?? Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 38,
                child: TextField(
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.cinzel(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.deepPurpleAccent,
                      ),
                    ),
                  ),
                  onChanged: (v) => onValueChange(int.tryParse(v) ?? 0),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.add_circle,
                color: Colors.greenAccent,
                size: 22,
              ),
              onPressed: () => onUpdate(val),
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              icon: const Icon(
                Icons.remove_circle,
                color: Colors.redAccent,
                size: 22,
              ),
              onPressed: () => onUpdate(-val),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ],
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Game Master Console',
          style: GoogleFonts.cinzel(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: const Color(0xFF0D0D1A),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<PlayerProvider>().loadPlayers(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.deepPurpleAccent,
          labelStyle: GoogleFonts.cinzel(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: GoogleFonts.cinzel(fontSize: 11),
          tabs: const [
            Tab(icon: Icon(Icons.people_alt, size: 18), text: 'Players'),
            Tab(icon: Icon(Icons.card_giftcard, size: 18), text: 'Rewards'),
            Tab(icon: Icon(Icons.casino, size: 18), text: 'Dice & Log'),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D0D1A), Color(0xFF1A0A2E), Color(0xFF0D1A2E)],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildPlayersTab(),
            _buildRewardsTab(),
            _buildDiceAndLogTab(),
          ],
        ),
      ),
      floatingActionButton: _currentTab == 0
          ? FloatingActionButton.extended(
              heroTag: 'gm_npc',
              backgroundColor: Colors.deepPurpleAccent,
              onPressed: () {
                context.read<PlayerProvider>().addPlayer(
                  Player(
                    name: 'Generic Enemy',
                    race: 'Goblin',
                    playerClass: 'Warrior',
                    level: 1,
                    xp: 0,
                    gold: 0,
                    pointsleft: 0,
                    health: 15,
                    maxHealth: 15,
                    mana: 5,
                    maxMana: 5,
                    proficiencyBonus: 2,
                    armorClass: 12,
                    strength: 12,
                    dexterity: 14,
                    constitution: 12,
                    intelligence: 8,
                    wisdom: 10,
                    charisma: 8,
                    availablePoints: 0,
                  ),
                );
              },
              label: Text(
                'Quick-Add NPC',
                style: GoogleFonts.cinzel(fontWeight: FontWeight.bold),
              ),
              icon: const Icon(Icons.add),
            )
          : null,
    );
  }

  // ── Tab 1: Players ────────────────────────────────────────────────────────

  Widget _buildPlayersTab() {
    return Consumer<PlayerProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.players.isEmpty) {
          return const Center(child: Text('No players in the session.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: provider.players.length,
          itemBuilder: (context, index) {
            final player = provider.players[index];
            final id = player.id!;

            return Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: ExpansionTile(
                collapsedIconColor: Colors.white54,
                iconColor: Colors.deepPurpleAccent,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.3),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.deepPurpleAccent.withOpacity(0.5),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${player.level}',
                      style: GoogleFonts.cinzel(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  player.name,
                  style: GoogleFonts.cinzel(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Colors.white,
                  ),
                ),
                subtitle: Text(
                  '${player.race} ${player.playerClass}${player.subclass != 'None' ? ' (${player.subclass})' : ''}',
                  style: GoogleFonts.cinzel(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                ),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      children: [
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 2.2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 20,
                          children: [
                            _buildStatModifier(
                              label: 'HP',
                              current: player.health,
                              max: player.maxHealth,
                              val: _hpMods[id] ?? 0,
                              color: Colors.redAccent.shade100,
                              onValueChange: (v) => _hpMods[id] = v,
                              onUpdate: (v) {
                                int newHealth = player.health + v;
                                if (newHealth < 0) {
                                  newHealth = 0;
                                } else if (newHealth > player.maxHealth) {
                                  newHealth = player.maxHealth;
                                }
                                provider.updatePlayer(
                                  player.copyWith(health: newHealth),
                                );
                              },
                            ),
                            _buildStatModifier(
                              label: 'MP',
                              current: player.mana,
                              max: player.maxMana,
                              val: _mpMods[id] ?? 0,
                              color: Colors.blueAccent.shade100,
                              onValueChange: (v) => _mpMods[id] = v,
                              onUpdate: (v) {
                                int newMana = player.mana + v;
                                if (newMana < 0) {
                                  newMana = 0;
                                } else if (newMana > player.maxMana) {
                                  newMana = player.maxMana;
                                }
                                provider.updatePlayer(
                                  player.copyWith(mana: newMana),
                                );
                              },
                            ),
                            _buildStatModifier(
                              label: 'Gold',
                              current: player.gold,
                              max: null,
                              val: _goldMods[id] ?? 0,
                              color: Colors.amberAccent.shade100,
                              onValueChange: (v) => _goldMods[id] = v,
                              onUpdate: (v) {
                                int newGold = player.gold + v;
                                if (newGold < 0) newGold = 0;
                                provider.updatePlayer(
                                  player.copyWith(gold: newGold),
                                );
                              },
                            ),
                            _buildStatModifier(
                              label: 'XP',
                              current: player.xp,
                              max: player.level * 10,
                              val: _xpMods[id] ?? 0,
                              color: Colors.purpleAccent.shade100,
                              onValueChange: (v) => _xpMods[id] = v,
                              onUpdate: (v) {
                                provider.updatePlayer(
                                  player.copyWith(xp: player.xp + v),
                                );
                              },
                            ),
                            _buildStatModifier(
                              label: 'AC',
                              current: player.armorClass,
                              max: null,
                              val: _acMods[id] ?? 0,
                              color: Colors.tealAccent.shade100,
                              onValueChange: (v) => _acMods[id] = v,
                              onUpdate: (v) {
                                int newAC = player.armorClass + v;
                                if (newAC < 0) newAC = 0;
                                provider.updatePlayer(
                                  player.copyWith(armorClass: newAC),
                                );
                              },
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Divider(color: Colors.white10),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _miniStat('AC', player.armorClass),
                              _miniStat('STR', player.strength),
                              _miniStat('DEX', player.dexterity),
                              _miniStat('CON', player.constitution),
                              _miniStat('INT', player.intelligence),
                              _miniStat('WIS', player.wisdom),
                              _miniStat('CHA', player.charisma),
                            ],
                          ),
                        ),
                        // Loadout summary
                        if (player.weapon.isNotEmpty ||
                            player.knownSpells.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Divider(color: Colors.white10),
                                if (player.weapon.isNotEmpty)
                                  Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.gavel,
                                            size: 14,
                                            color: Colors.orangeAccent),
                                        const SizedBox(width: 6),
                                        Text(
                                          player.weapon,
                                          style: GoogleFonts.cinzel(
                                            fontSize: 12,
                                            color: Colors.orangeAccent,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (player.knownSpells.isNotEmpty)
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: player.knownSpells
                                        .map(
                                          (s) => Chip(
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                            visualDensity:
                                                VisualDensity.compact,
                                            backgroundColor: Colors
                                                .deepPurpleAccent
                                                .withOpacity(0.15),
                                            side: BorderSide(
                                              color: Colors.deepPurpleAccent
                                                  .withOpacity(0.3),
                                            ),
                                            label: Text(
                                              s,
                                              style: GoogleFonts.cinzel(
                                                fontSize: 10,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => provider.deletePlayer(id),
                              icon: const Icon(Icons.delete_outline, size: 16),
                              label: Text(
                                'REMOVE',
                                style: GoogleFonts.cinzel(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.redAccent.withOpacity(
                                  0.8,
                                ),
                                side: BorderSide(
                                  color: Colors.redAccent.withOpacity(0.3),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── Tab 2: Rewards ────────────────────────────────────────────────────────

  Widget _buildRewardsTab() {
    return Consumer<PlayerProvider>(
      builder: (context, provider, child) {
        final players = provider.players;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'Grant Rewards',
                style: GoogleFonts.cinzel(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.amberAccent,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Reward players with weapons and spells',
                style: GoogleFonts.cinzel(
                  fontSize: 12,
                  color: Colors.white38,
                ),
              ),
              const SizedBox(height: 24),

              // Player selector
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.amberAccent.withOpacity(0.15),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SELECT PLAYER',
                      style: GoogleFonts.cinzel(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white38,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _rewardPlayerId,
                      dropdownColor: const Color(0xFF1A0A2E),
                      style:
                          GoogleFonts.cinzel(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person,
                            color: Colors.amberAccent, size: 18),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: players
                          .map(
                            (p) => DropdownMenuItem(
                              value: p.id,
                              child: Text(
                                  '${p.name} (Lv${p.level} ${p.playerClass})'),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() {
                        _rewardPlayerId = v;
                        _rewardItem = null;
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Reward type toggle
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.amberAccent.withOpacity(0.15),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'REWARD TYPE',
                      style: GoogleFonts.cinzel(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white38,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _rewardType = 'spell';
                              _rewardItem = null;
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: _rewardType == 'spell'
                                    ? Colors.deepPurpleAccent
                                        .withOpacity(0.25)
                                    : Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _rewardType == 'spell'
                                      ? Colors.deepPurpleAccent
                                      : Colors.white.withOpacity(0.1),
                                ),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.auto_fix_high,
                                      size: 16,
                                      color: _rewardType == 'spell'
                                          ? Colors.deepPurpleAccent
                                          : Colors.white38,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Spell',
                                      style: GoogleFonts.cinzel(
                                        fontWeight: FontWeight.bold,
                                        color: _rewardType == 'spell'
                                            ? Colors.deepPurpleAccent
                                            : Colors.white38,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _rewardType = 'weapon';
                              _rewardItem = null;
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: _rewardType == 'weapon'
                                    ? Colors.orangeAccent.withOpacity(0.25)
                                    : Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _rewardType == 'weapon'
                                      ? Colors.orangeAccent
                                      : Colors.white.withOpacity(0.1),
                                ),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.gavel,
                                      size: 16,
                                      color: _rewardType == 'weapon'
                                          ? Colors.orangeAccent
                                          : Colors.white38,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Weapon',
                                      style: GoogleFonts.cinzel(
                                        fontWeight: FontWeight.bold,
                                        color: _rewardType == 'weapon'
                                            ? Colors.orangeAccent
                                            : Colors.white38,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Item selector
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.amberAccent.withOpacity(0.15),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _rewardType == 'spell'
                          ? 'SELECT SPELL'
                          : 'SELECT WEAPON',
                      style: GoogleFonts.cinzel(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white38,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _rewardItem,
                      dropdownColor: const Color(0xFF1A0A2E),
                      style:
                          GoogleFonts.cinzel(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          _rewardType == 'spell'
                              ? Icons.auto_fix_high
                              : Icons.gavel,
                          color: _rewardType == 'spell'
                              ? Colors.deepPurpleAccent
                              : Colors.orangeAccent,
                          size: 18,
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: (_rewardType == 'spell'
                              ? kAllSpells.keys.toList()
                              : kAllWeapons.keys.toList())
                          .map((name) {
                        String subtitle = '';
                        if (_rewardType == 'spell') {
                          final info = kAllSpells[name]!;
                          if (info.healing) {
                            subtitle = ' (heal ${info.damage})';
                          } else if (info.damage != '0') {
                            subtitle = ' (${info.damage})';
                          } else {
                            subtitle = ' (utility)';
                          }
                        } else {
                          subtitle = ' (${kAllWeapons[name]!.damage})';
                        }
                        return DropdownMenuItem(
                          value: name,
                          child: Text('$name$subtitle'),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _rewardItem = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Grant button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _rewardPlayerId != null && _rewardItem != null
                      ? () {
                          provider.grantReward(
                            _rewardPlayerId!,
                            _rewardType,
                            _rewardItem!,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                _rewardType == 'spell'
                                    ? '✨ Granted spell: $_rewardItem'
                                    : '⚔️ Granted weapon: $_rewardItem',
                                style: GoogleFonts.cinzel(),
                              ),
                              backgroundColor: Colors.deepPurple,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                          setState(() => _rewardItem = null);
                        }
                      : null,
                  icon: const Icon(Icons.card_giftcard, size: 20),
                  label: Text(
                    'GRANT REWARD',
                    style: GoogleFonts.cinzel(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 1.2,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amberAccent.withOpacity(0.2),
                    foregroundColor: Colors.amberAccent,
                    disabledBackgroundColor: Colors.white.withOpacity(0.05),
                    disabledForegroundColor: Colors.white24,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Preview: selected player's current loadout
              if (_rewardPlayerId != null) ...[
                Text(
                  'CURRENT LOADOUT',
                  style: GoogleFonts.cinzel(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white38,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Builder(
                  builder: (context) {
                    final p = players.firstWhere(
                      (p) => p.id == _rewardPlayerId,
                      orElse: () => players.first,
                    );
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (p.weapon.isNotEmpty)
                            Row(
                              children: [
                                const Icon(Icons.gavel,
                                    size: 14, color: Colors.orangeAccent),
                                const SizedBox(width: 6),
                                Text(
                                  'Equipped: ${p.weapon}',
                                  style: GoogleFonts.cinzel(
                                    fontSize: 12,
                                    color: Colors.orangeAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          if (p.inventoryWeapons.length > 1) ...[
                            const SizedBox(height: 6),
                            Text(
                              'Weapons: ${p.inventoryWeapons.join(", ")}',
                              style: GoogleFonts.cinzel(
                                fontSize: 11,
                                color: Colors.white38,
                              ),
                            ),
                          ],
                          if (p.knownSpells.isNotEmpty) ...[
                            const Divider(color: Colors.white10),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: p.knownSpells
                                  .map(
                                    (s) => Chip(
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: VisualDensity.compact,
                                      backgroundColor: Colors.deepPurpleAccent
                                          .withOpacity(0.15),
                                      side: BorderSide(
                                        color: Colors.deepPurpleAccent
                                            .withOpacity(0.3),
                                      ),
                                      label: Text(
                                        s,
                                        style: GoogleFonts.cinzel(
                                          fontSize: 10,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                          if (p.knownSpells.isEmpty &&
                              p.weapon.isEmpty)
                            Text(
                              'No items yet',
                              style: GoogleFonts.cinzel(
                                fontSize: 12,
                                color: Colors.white24,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // ── Tab 3: Dice & Combat Log ──────────────────────────────────────────────

  Widget _buildDiceAndLogTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // GM dice roller — not tied to any player
          const DiceRoller(playerId: null, displayName: 'Game Master'),
          const Divider(color: Colors.black12, height: 1),
          const CombatLog(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _miniStat(String label, int val) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.cinzel(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white38,
            ),
          ),
          Text(
            '$val',
            style: GoogleFonts.cinzel(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
