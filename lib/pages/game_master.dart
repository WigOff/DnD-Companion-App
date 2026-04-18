import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dnd_app/models/player.dart';
import 'package:dnd_app/providers/player_provider.dart';
import 'package:dnd_app/widgets/dice_roller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dnd_app/widgets/combat_log.dart';

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

  late TabController _tabController;
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
            fontSize: 13,
          ),
          unselectedLabelStyle: GoogleFonts.cinzel(fontSize: 12),
          tabs: const [
            Tab(icon: Icon(Icons.people_alt), text: 'Players'),
            Tab(icon: Icon(Icons.casino), text: 'Dice & Log'),
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
          children: [_buildPlayersTab(), _buildDiceAndLogTab()],
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
                  '${player.race} ${player.playerClass}',
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
                                } else if (newHealth > player.maxHealth)
                                  newHealth = player.maxHealth;
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
                                } else if (newMana > player.maxMana)
                                  newMana = player.maxMana;
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

  // ── Tab 2: Dice & Combat Log ──────────────────────────────────────────────

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
