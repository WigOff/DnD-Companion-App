import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dnd_app/models/player.dart';
import 'package:dnd_app/providers/player_provider.dart';
import 'package:dnd_app/widgets/dice_roller.dart';
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
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 35,
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => onValueChange(int.tryParse(v) ?? 0),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.green),
              onPressed: () => onUpdate(val),
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              icon: const Icon(Icons.remove_circle, color: Colors.red),
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
      appBar: AppBar(
        title: const Text('Game Master Console'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<PlayerProvider>().loadPlayers(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.people_alt), text: 'Players'),
            Tab(icon: Icon(Icons.casino), text: 'Dice & Log'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPlayersTab(),
          _buildDiceAndLogTab(),
        ],
      ),
      floatingActionButton: _currentTab == 0
          ? FloatingActionButton.extended(
              heroTag: 'gm_npc',
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
                  ),
                );
              },
              label: const Text('Quick-Add NPC'),
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

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.deepPurple,
                  child: Text('${player.level}', style: const TextStyle(color: Colors.white)),
                ),
                title: Text(
                  player.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: Text('${player.race} ${player.playerClass}'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 2.5,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 20,
                          children: [
                            _buildStatModifier(
                              label: 'HP',
                              current: player.health,
                              max: player.maxHealth,
                              val: _hpMods[id] ?? 0,
                              color: Colors.red.shade700,
                              onValueChange: (v) => _hpMods[id] = v,
                              onUpdate: (v) {
                                int newHealth = player.health + v;
                                if (newHealth < 0) {
                                  newHealth = 0;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('HP cannot go below 0!')),
                                  );
                                } else if (newHealth > player.maxHealth) {
                                  newHealth = player.maxHealth;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('HP cannot exceed Max HP (${player.maxHealth})!')),
                                  );
                                }
                                provider.updatePlayer(player.copyWith(health: newHealth));
                              },
                            ),
                            _buildStatModifier(
                              label: 'MP',
                              current: player.mana,
                              max: player.maxMana,
                              val: _mpMods[id] ?? 0,
                              color: Colors.blue.shade700,
                              onValueChange: (v) => _mpMods[id] = v,
                              onUpdate: (v) {
                                int newMana = player.mana + v;
                                if (newMana < 0) {
                                  newMana = 0;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('MP cannot go below 0!')),
                                  );
                                } else if (newMana > player.maxMana) {
                                  newMana = player.maxMana;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('MP cannot exceed Max MP (${player.maxMana})!')),
                                  );
                                }
                                provider.updatePlayer(player.copyWith(mana: newMana));
                              },
                            ),
                            _buildStatModifier(
                              label: 'Gold',
                              current: player.gold,
                              max: null,
                              val: _goldMods[id] ?? 0,
                              color: Colors.orange.shade800,
                              onValueChange: (v) => _goldMods[id] = v,
                              onUpdate: (v) {
                                int newGold = player.gold + v;
                                if (newGold < 0) {
                                  newGold = 0;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Gold cannot go below 0!')),
                                  );
                                }
                                provider.updatePlayer(player.copyWith(gold: newGold));
                              },
                            ),
                            _buildStatModifier(
                              label: 'XP',
                              current: player.xp,
                              max: player.level * 10,
                              val: _xpMods[id] ?? 0,
                              color: Colors.purple.shade700,
                              onValueChange: (v) => _xpMods[id] = v,
                              onUpdate: (v) {
                                int newXp = player.xp + v;
                                int newLevel = player.level;
                                while (newLevel > 0 && newXp >= newLevel * 10) {
                                  newXp -= newLevel * 10;
                                  newLevel++;
                                }
                                while (newXp < 0 && newLevel > 1) {
                                  newLevel--;
                                  newXp += newLevel * 10;
                                }
                                if (newLevel == 1 && newXp < 0) newXp = 0;
                                provider.updatePlayer(player.copyWith(xp: newXp, level: newLevel));
                              },
                            ),
                          ],
                        ),
                        const Divider(),
                        Wrap(
                          spacing: 12,
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
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () => provider.deletePlayer(id),
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            label: const Text('Remove from Session', style: TextStyle(color: Colors.red)),
                          ),
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
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        Text('$val', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
