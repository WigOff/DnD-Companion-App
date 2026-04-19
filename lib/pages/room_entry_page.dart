import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dnd_app/providers/player_provider.dart';
import 'package:dnd_app/pages/game_master.dart';
import 'package:dnd_app/pages/join_game.dart';

class RoomEntryPage extends StatefulWidget {
  final bool isHost; // true if resuming as host, false if joining as player

  const RoomEntryPage({super.key, required this.isHost});

  @override
  State<RoomEntryPage> createState() => _RoomEntryPageState();
}

class _RoomEntryPageState extends State<RoomEntryPage> {
  final TextEditingController _controller = TextEditingController();
  bool _isJoining = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleJoin() async {
    final code = _controller.text.trim().toUpperCase();
    if (code.length != 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Room code must be 5 characters.')),
      );
      return;
    }

    setState(() => _isJoining = true);
    final provider = context.read<PlayerProvider>();
    provider.joinRoom(code);

    // We wait for either currentRoomId to be set or an error to appear
    // Normally we'd use a listener or a future, but here we'll use a simple loop/listener approach
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlayerProvider>();

    // Navigation logic based on provider state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (provider.currentRoomId != null && _isJoining) {
        setState(() => _isJoining = false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                widget.isHost ? const GameMaster() : const JoinGame(),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              widget.isHost ? 'Resume Session' : 'Join Session',
              style: GoogleFonts.cinzel(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter the 5-character room code provided by the host.',
              style: GoogleFonts.cinzel(
                fontSize: 15,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 48),
            TextField(
              controller: _controller,
              autofocus: true,
              maxLength: 5,
              textCapitalization: TextCapitalization.characters,
              style: GoogleFonts.cinzel(
                color: Colors.white,
                fontSize: 24,
                letterSpacing: 8,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                counterText: '',
                hintText: 'ABCDE',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.1)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.deepPurpleAccent),
                ),
              ),
              onSubmitted: (_) => _handleJoin(),
            ),
            if (provider.connectionError != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        provider.connectionError!,
                        style: GoogleFonts.cinzel(
                          color: Colors.redAccent,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: (provider.isLoading || _isJoining)
                    ? null
                    : _handleJoin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                  shadowColor: Colors.deepPurpleAccent.withOpacity(0.5),
                ),
                child: (provider.isLoading || _isJoining)
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'CONTINUE',
                        style: GoogleFonts.cinzel(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 2,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
