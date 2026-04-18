import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dnd_app/models/player.dart';
import 'package:dnd_app/providers/player_provider.dart';
import 'package:dnd_app/pages/player_dashboard.dart';
import 'package:dnd_app/data/class_defaults.dart';

/// Standalone new-player creation form.
/// After successful creation, navigates to the player's own dashboard.
class NewPlayerForm extends StatefulWidget {
  const NewPlayerForm({super.key});

  @override
  State<NewPlayerForm> createState() => _NewPlayerFormState();
}

class _NewPlayerFormState extends State<NewPlayerForm> {
  String name = '';
  String race = kAvailableRaces.first;
  String playerClass = kAvailableClasses.first;

  int str = 14, dex = 10, con = 14, intl = 6, wis = 8, cha = 8;

  int get pointsAllocated => str + dex + con + intl + wis + cha;
  int get pointsLeft => 60 - pointsAllocated;

  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (name.trim().isEmpty) {
      _snack('Please enter a player name.', Colors.orange);
      return;
    }
    setState(() => _isSubmitting = true);

    final provider = context.read<PlayerProvider>();

    final newPlayer = Player(
      name: name.trim(),
      race: race.isEmpty ? 'Unknown' : race.trim(),
      playerClass: playerClass.isEmpty ? 'Unknown' : playerClass.trim(),
      level: 1,
      xp: 0,
      gold: 0,
      pointsleft: pointsLeft,
      health: 10 + con,
      maxHealth: 10 + con,
      mana: 10 + intl,
      maxMana: 10 + intl,
      armorClass: 10 + dex,
      strength: str,
      dexterity: dex,
      constitution: con,
      intelligence: intl,
      wisdom: wis,
      charisma: cha,
      availablePoints: 0,
      proficiencyBonus: 2,
    );

    try {
      await provider.addPlayer(newPlayer);

      // Wait briefly for the server to broadcast back the created player
      await Future.delayed(const Duration(milliseconds: 600));

      // Find the newly created player by name (latest match)
      final created = provider.players.lastWhere(
        (p) => p.name == newPlayer.name,
        orElse: () => newPlayer,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => PlayerDashboard(player: created)),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      _snack('Failed to create player: $e', Colors.red);
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  Widget _buildStatRow(String label, int value, Function(int) onChanged) {
    // Stats are locked for non-custom classes
    final isCustom = playerClass == 'Custom';
    final canIncrease = isCustom && pointsLeft > 0;
    final canDecrease = isCustom && value > 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.cinzel(fontSize: 15, color: Colors.white70),
            ),
          ),
          if (isCustom) ...[
            IconButton(
              icon: Icon(
                Icons.remove_circle_outline,
                color: canDecrease ? Colors.redAccent : Colors.white12,
              ),
              onPressed: canDecrease
                  ? () => setState(() => onChanged(value - 1))
                  : null,
            ),
            SizedBox(
              width: 32,
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
              icon: Icon(
                Icons.add_circle_outline,
                color: canIncrease ? Colors.greenAccent : Colors.white12,
              ),
              onPressed: canIncrease
                  ? () => setState(() => onChanged(value + 1))
                  : null,
            ),
          ] else ...[
            Text(
              '$value',
              style: GoogleFonts.cinzel(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 12),
          ],
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Create Character',
          style: GoogleFonts.cinzel(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Identity ──────────────────────────────────────────
            _sectionHeader('Identity', Icons.badge_outlined),
            const SizedBox(height: 12),
            TextField(
              style: GoogleFonts.cinzel(color: Colors.white, fontSize: 13),
              decoration: _inputDeco('Player Name', Icons.person_outline),
              onChanged: (v) => name = v,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: race,
              dropdownColor: const Color(0xFF1A0A2E),
              style: GoogleFonts.cinzel(color: Colors.white, fontSize: 13),
              decoration: _inputDeco('Race', Icons.face),
              items: kAvailableRaces
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (v) => setState(() => race = v!),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: playerClass,
              dropdownColor: const Color(0xFF1A0A2E),
              style: GoogleFonts.cinzel(color: Colors.white, fontSize: 13),
              decoration: _inputDeco('Class', Icons.star_outline),
              items: kAvailableClasses
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) {
                setState(() {
                  playerClass = v!;
                  final defaults = kClassDefaults[v]!;
                  str = defaults['strength']!;
                  dex = defaults['dexterity']!;
                  con = defaults['constitution']!;
                  intl = defaults['intelligence']!;
                  wis = defaults['wisdom']!;
                  cha = defaults['charisma']!;
                });
              },
            ),

            const SizedBox(height: 28),

            // ── Stats ─────────────────────────────────────────────
            Row(
              children: [
                _sectionHeader('Stats', Icons.bar_chart),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: pointsLeft > 0
                        ? Colors.deepPurpleAccent.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: pointsLeft > 0
                          ? Colors.deepPurpleAccent.withOpacity(0.5)
                          : Colors.redAccent.withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    '$pointsLeft pts left',
                    style: GoogleFonts.cinzel(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: pointsLeft > 0
                          ? Colors.deepPurpleAccent
                          : Colors.redAccent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildStatRow('Strength', str, (v) => str = v),
            _buildStatRow('Dexterity', dex, (v) => dex = v),
            _buildStatRow('Constitution', con, (v) => con = v),
            _buildStatRow('Intelligence', intl, (v) => intl = v),
            _buildStatRow('Wisdom', wis, (v) => wis = v),
            _buildStatRow('Charisma', cha, (v) => cha = v),

            const SizedBox(height: 32),

            // ── Submit ────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                ),
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Enter the Realm',
                        style: GoogleFonts.cinzel(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
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
        Icon(icon, color: Colors.deepPurpleAccent, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.cinzel(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
