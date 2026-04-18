import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dnd_app/models/player.dart';
import 'package:dnd_app/providers/player_provider.dart';
import 'package:dnd_app/pages/new_player_form.dart';
import 'package:dnd_app/pages/player_dashboard.dart';

class JoinGame extends StatefulWidget {
  const JoinGame({super.key});

  @override
  State<JoinGame> createState() => _JoinGameState();
}

class _JoinGameState extends State<JoinGame> {
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
          'Join Game',
          style: GoogleFonts.cinzel(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'Who are you?',
              style: GoogleFonts.cinzel(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose how you want to enter the session.',
              style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.5)),
            ),
            const SizedBox(height: 48),

            // New Player Card
            _JoinOptionCard(
              icon: Icons.person_add_alt_1,
              title: 'New Player',
              subtitle: 'Create a fresh character and join the session',
              color: const Color(0xFF6B21A8),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NewPlayerForm()),
              ),
            ),
            const SizedBox(height: 20),

            // Existing Player Card
            _JoinOptionCard(
              icon: Icons.manage_search,
              title: 'Existing Player',
              subtitle: 'Find your character from the current session',
              color: const Color(0xFF0E7490),
              onTap: () => _showExistingPlayerSheet(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showExistingPlayerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ExistingPlayerSheet(),
    );
  }
}

// ─── Join Option Card ────────────────────────────────────────────────────────

class _JoinOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _JoinOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.25),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cinzel(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.55)),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color, size: 22),
          ],
        ),
      ),
    );
  }
}

// ─── Existing Player Bottom Sheet ────────────────────────────────────────────

class _ExistingPlayerSheet extends StatefulWidget {
  const _ExistingPlayerSheet();

  @override
  State<_ExistingPlayerSheet> createState() => _ExistingPlayerSheetState();
}

class _ExistingPlayerSheetState extends State<_ExistingPlayerSheet> {
  final TextEditingController _controller = TextEditingController();
  List<Player> _suggestions = [];

  void _onSearchChanged(String query, List<Player> allPlayers) {
    setState(() {
      if (query.isEmpty) {
        _suggestions = allPlayers;
      } else {
        _suggestions = allPlayers
            .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final allPlayers = context.watch<PlayerProvider>().players;

    // Populate suggestions on first build
    if (_suggestions.isEmpty && _controller.text.isEmpty) {
      _suggestions = allPlayers;
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF12122A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Find Your Character',
                      style: GoogleFonts.cinzel(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Search by name to find your character.',
                      style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.45)),
                    ),
                    const SizedBox(height: 16),
                    // Search bar
                    TextField(
                      controller: _controller,
                      autofocus: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search players...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.35)),
                        prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.5)),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.07),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (q) => _onSearchChanged(q, allPlayers),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Divider(color: Colors.white10, height: 1),
              // Results
              Expanded(
                child: _suggestions.isEmpty
                    ? Center(
                        child: Text(
                          allPlayers.isEmpty
                              ? 'No players in session yet.'
                              : 'No players match your search.',
                          style: TextStyle(color: Colors.white.withOpacity(0.4)),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: _suggestions.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemBuilder: (_, i) {
                          final player = _suggestions[i];
                          return _PlayerSearchTile(
                            player: player,
                            onTap: () {
                              Navigator.pop(context); // close sheet
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PlayerDashboard(player: player),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PlayerSearchTile extends StatelessWidget {
  final Player player;
  final VoidCallback onTap;

  const _PlayerSearchTile({required this.player, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.deepPurple.withOpacity(0.4),
              child: Text(
                player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.name,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  Text(
                    '${player.race} · ${player.playerClass} · Lvl ${player.level}',
                    style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.login, color: Colors.tealAccent.withOpacity(0.7), size: 20),
          ],
        ),
      ),
    );
  }
}
