import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:dnd_app/models/player.dart';
import 'package:dnd_app/providers/player_provider.dart';

class PlayerView extends StatefulWidget {
  const PlayerView({super.key});

  @override
  State<PlayerView> createState() => _PlayerViewState();
}

class _PlayerViewState extends State<PlayerView> {
  String? searchId;
  Player? loadedPlayer;
  String? fetchError;
  bool isCreating = false;

  // New Player Form State
  String name = '';
  String race = 'Human';
  String playerClass = 'Fighter';
  String subclass = 'None';
  String subclassDescription = '';

  int str = 0;
  int dex = 0;
  int con = 0;
  int intl = 0;
  int wis = 0;
  int cha = 0;

  int get pointsAllocated => str + dex + con + intl + wis + cha;
  int get pointsLeft => 60 - pointsAllocated;

  Future<void> _fetchPlayer(String id) async {
    final provider = context.read<PlayerProvider>();
    try {
      final player = await provider.getPlayerById(id);
      setState(() {
        loadedPlayer = player;
        fetchError = null;
      });
    } catch (e) {
      setState(() {
        loadedPlayer = null;
        fetchError = 'Could not find player with ID $id';
      });
    }
  }

  Future<void> _createNewPlayer() async {
    final provider = context.read<PlayerProvider>();
    final newPlayer = Player(
      name: name.isEmpty ? 'Unknown' : name,
      race: race.isEmpty ? 'Unknown' : race,
      playerClass: playerClass.isEmpty ? 'Unknown' : playerClass,
      level: 1,
      xp: 0,
      gold: 0,
      pointsleft: pointsLeft,
      health: 10 + con,
      maxHealth: 10 + con,
      mana: 10 + intl,
      maxMana: 10 + intl,
      armorClass: 10 + ((dex - 10) / 2).floor(),
      strength: str,
      dexterity: dex,
      constitution: con,
      intelligence: intl,
      wisdom: wis,
      charisma: cha,
      subclass: subclass,
      subclassDescription: subclassDescription,
      proficiencyBonus: 2,
    );
    await provider.addPlayer(newPlayer);
  }

  Widget _buildStatRow(String label, int value, Function(int) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.cinzel(fontSize: 16)),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: value > 0 ? () => onChanged(value - 1) : null,
              ),
              SizedBox(
                width: 30,
                child: Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cinzel(fontSize: 18),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: pointsLeft > 0 ? () => onChanged(value + 1) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isCreating) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Create New Player'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              setState(() {
                isCreating = false;
              });
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Player Name'),
                onChanged: (val) => name = val,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Race'),
                onChanged: (val) => race = val,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Class'),
                onChanged: (val) => playerClass = val,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Subclass'),
                onChanged: (val) => subclass = val,
              ),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Subclass Description',
                ),
                onChanged: (val) => subclassDescription = val,
              ),
              const SizedBox(height: 24),
              Text(
                'Assign Stats (Points Left: $pointsLeft)',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 16),
              _buildStatRow(
                'Strength',
                str,
                (val) => setState(() => str = val),
              ),
              _buildStatRow(
                'Dexterity',
                dex,
                (val) => setState(() => dex = val),
              ),
              _buildStatRow(
                'Constitution',
                con,
                (val) => setState(() => con = val),
              ),
              _buildStatRow(
                'Intelligence',
                intl,
                (val) => setState(() => intl = val),
              ),
              _buildStatRow('Wisdom', wis, (val) => setState(() => wis = val)),
              _buildStatRow(
                'Charisma',
                cha,
                (val) => setState(() => cha = val),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  onPressed: () async {
                    try {
                      await _createNewPlayer();
                      if (mounted) {
                        setState(() {
                          isCreating = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Player created securely in the realm!',
                              style: GoogleFonts.cinzel(color: Colors.white),
                            ),
                            backgroundColor: Colors.green.withValues(
                              alpha: 0.8,
                            ),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Failed to create player: $e',
                              style: GoogleFonts.cinzel(),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text(
                    'Complete Character Creation',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Load Player Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Enter Player ID',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    keyboardType: TextInputType.text,
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        _fetchPlayer(value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.person_add),
                  onPressed: () {
                    setState(() {
                      isCreating = true;
                      name = '';
                      race = '';
                      playerClass = '';
                      str = 0;
                      dex = 0;
                      con = 0;
                      intl = 0;
                      wis = 0;
                      cha = 0;
                      loadedPlayer = null;
                      fetchError = null;
                    });
                  },
                  label: const Text('New Player'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (fetchError != null)
              Text(
                fetchError!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            if (loadedPlayer != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            loadedPlayer!.name,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          Text(
                            'Player ID: #${loadedPlayer!.id}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const Divider(height: 32, thickness: 1),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Class: ${loadedPlayer!.playerClass}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (loadedPlayer!.subclass != 'None')
                                    Text(
                                      'Subclass: ${loadedPlayer!.subclass}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.deepPurple.shade300,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: Image.asset(
                                      'assets/images/races/${loadedPlayer!.race.toLowerCase().replaceAll(' ', '_').replaceAll('-', '_')}_${loadedPlayer!.gender}.png',
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Image.asset(
                                          'assets/images/races/${loadedPlayer!.race.toLowerCase().replaceAll(' ', '_').replaceAll('-', '_')}.png',
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(
                                                    Icons.person,
                                                    color: Colors.grey,
                                                    size: 30,
                                                  ),
                                        );
                                      },
                                    ),
                                  ),
                                  Text(
                                    'Race: ${loadedPlayer!.race}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (loadedPlayer!.subclassDescription.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                loadedPlayer!.subclassDescription,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Level: ${loadedPlayer!.level}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              Text(
                                'XP: ${loadedPlayer!.xp} / ${loadedPlayer!.level * 10}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'HP: ${loadedPlayer!.health} / ${loadedPlayer!.maxHealth}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'MP: ${loadedPlayer!.mana} / ${loadedPlayer!.maxMana}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Gold: ${loadedPlayer!.gold}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.amber,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Armor Class: ${loadedPlayer!.armorClass}',
                            style: const TextStyle(fontSize: 16),
                          ),

                          const Divider(height: 32, thickness: 1),
                          const Text(
                            'Base Stats',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Strength: ${loadedPlayer!.strength}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Dexterity: ${loadedPlayer!.dexterity}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Constitution: ${loadedPlayer!.constitution}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Intelligence: ${loadedPlayer!.intelligence}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Wisdom: ${loadedPlayer!.wisdom}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Charisma: ${loadedPlayer!.charisma}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const Divider(height: 32, thickness: 1),
                          Text(
                            'Proficiency Bonus: +${loadedPlayer!.proficiencyBonus}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
      ),
    );
  }
}
