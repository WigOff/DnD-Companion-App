import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dnd_app/models/player.dart';
import 'package:dnd_app/providers/player_provider.dart';
import 'package:dnd_app/data/class_defaults.dart';
import 'package:dnd_app/data/class_loadouts.dart';

class NewEnemyForm extends StatefulWidget {
  const NewEnemyForm({super.key});

  @override
  State<NewEnemyForm> createState() => _NewEnemyFormState();
}

class _NewEnemyFormState extends State<NewEnemyForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _healthController = TextEditingController();
  final TextEditingController _levelController = TextEditingController();

  String race = "Monster";
  String enemyClass = "Fighter";

  int str = 10, dex = 10, con = 10, intl = 10, wis = 10, cha = 10;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _healthController.dispose();
    _levelController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty) {
      _snack('Please enter an enemy name.', Colors.orange);
      return;
    }

    setState(() => _isSubmitting = true);
    final provider = context.read<PlayerProvider>();

    final hp = int.tryParse(_healthController.text) ?? 20;
    final lvl = int.tryParse(_levelController.text) ?? 1;

    final loadout = kClassLoadouts[enemyClass.trim()];
    final starterWeapon = loadout?.weapon ?? 'Dagger';
    final starterSpells = loadout?.spells ?? [];

    final newEnemy = Player(
      name: _nameController.text.trim(),
      race: race,
      playerClass: enemyClass,
      level: lvl,
      xp: 0,
      gold: 0,
      pointsleft: 0,
      health: hp,
      maxHealth: hp,
      mana: 10 + intl,
      maxMana: 10 + intl,
      armorClass: 10 + ((dex - 10) / 2).floor(),
      strength: str,
      dexterity: dex,
      constitution: con,
      intelligence: intl,
      wisdom: wis,
      charisma: cha,
      subclass: "None",
      subclassDescription: "",
      availablePoints: 0,
      proficiencyBonus: 2 + ((lvl - 1) ~/ 4),
      weapon: starterWeapon,
      spells: List<String>.from(starterSpells),
      inventoryWeapons: [starterWeapon],
      knownSpells: List<String>.from(starterSpells),
    );

    try {
      await provider.addPlayer(newEnemy);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _isSubmitting = false);
      _snack('Failed to summon enemy: $e', Colors.red);
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  Widget _buildStatField(String label, int value, Function(int) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.cinzel(fontSize: 16, color: Colors.white70),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.remove_circle_outline,
              color: Colors.redAccent,
            ),
            onPressed: () => setState(() => onChanged(value - 1)),
          ),
          SizedBox(
            width: 40,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: GoogleFonts.cinzel(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.add_circle_outline,
              color: Colors.tealAccent,
            ),
            onPressed: () => setState(() => onChanged(value + 1)),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDeco(String label, IconData icon) => InputDecoration(
    labelText: label,
    labelStyle: GoogleFonts.cinzel(color: Colors.white.withOpacity(0.5)),
    prefixIcon: Icon(icon, color: Colors.white30, size: 20),
    filled: true,
    fillColor: Colors.white.withOpacity(0.06),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Colors.deepPurpleAccent, width: 1.5),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'SUMMON ENEMY',
          style: GoogleFonts.cinzel(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              style: GoogleFonts.cinzel(color: Colors.white),
              decoration: _inputDeco('Enemy Name', Icons.person_add),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _healthController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.cinzel(color: Colors.white),
                    decoration: _inputDeco('HP', Icons.favorite),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _levelController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.cinzel(color: Colors.white),
                    decoration: _inputDeco('Level', Icons.trending_up),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: enemyClass,
              dropdownColor: const Color(0xFF1A0A2E),
              style: GoogleFonts.cinzel(color: Colors.white),
              decoration: _inputDeco('Class/Type', Icons.category),
              items: kAvailableClasses
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => enemyClass = v!),
            ),
            const SizedBox(height: 32),
            _sectionHeader('Core Attributes', Icons.analytics),
            const SizedBox(height: 12),
            _buildStatField('STRENGTH', str, (v) => str = v),
            _buildStatField('DEXTERITY', dex, (v) => dex = v),
            _buildStatField('CONSTITUTION', con, (v) => con = v),
            _buildStatField('INTELLIGENCE', intl, (v) => intl = v),
            _buildStatField('WISDOM', wis, (v) => wis = v),
            _buildStatField('CHARISMA', cha, (v) => cha = v),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                ),
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'SUMMON TO REALM',
                        style: GoogleFonts.cinzel(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.amberAccent, size: 20),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: GoogleFonts.cinzel(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.amberAccent,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
