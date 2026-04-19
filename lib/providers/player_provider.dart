import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:dnd_app/models/player.dart';
import 'package:dnd_app/services/websocket_client.dart'; // Global ws instance
import 'package:dnd_app/db/database_helper.dart';

class PlayerProvider with ChangeNotifier {
  List<Player> _players = [];
  bool _isLoading = false;
  List<Map<String, dynamic>> _log = [];

  final StreamController<Map<String, dynamic>> _rollStreamController =
      StreamController<Map<String, dynamic>>.broadcast();

  List<Player> get players => _players;
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get log => _log;
  Stream<Map<String, dynamic>> get rollStream => _rollStreamController.stream;

  PlayerProvider() {
    loadPlayers(); // Load existing data from DB first
    _initWebSocket();
  }

  void _initWebSocket() {
    ws.stream.listen((message) async {
      try {
        final data = jsonDecode(message);
        if (data['type'] == 'game_state') {
          _players = (data['players'] as List)
              .map((p) => Player.fromJson(p))
              .toList();

          // Persist the state to the local database
          await DatabaseHelper.instance.clearAll();
          for (var player in _players) {
            await DatabaseHelper.instance.create(player);
          }

          // Process log — emit only new entries to listeners (for animations/fx)
          final incoming = List<Map<String, dynamic>>.from(
            (data['log'] as List? ?? []).map(
              (e) => Map<String, dynamic>.from(e),
            ),
          );
          for (int i = _log.length; i < incoming.length; i++) {
            final entry = incoming[i];
            if (entry['category'] == 'dice') {
              _rollStreamController.add(entry);
            }
          }
          _log = incoming;

          _isLoading = false;
          notifyListeners();
        }
      } catch (e) {
        print("Error parsing WebSocket message: $e");
      }
    });

    // Listener is now active — request the current state from the server
    ws.send({'type': 'get_state'});
  }

  Future<void> loadPlayers() async {
    _isLoading = true;
    notifyListeners();
    _players = await DatabaseHelper.instance.readAllPlayers();
    _isLoading = false;
    notifyListeners();
  }

  Future<Player?> getPlayerById(String id) async {
    try {
      return _players.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Sends a roll_dice event to the server.
  /// [playerId] is null for GM rolls.
  void rollDice(String? playerId) {
    ws.send({'type': 'roll_dice', 'playerid': playerId ?? 'gm'});
  }

  void levelUp(String playerId) {
    ws.send({'type': 'level_up', 'playerid': playerId});
  }

  void allocateStat(String playerId, String statKey) {
    ws.send({'type': 'allocate_stat', 'playerid': playerId, 'stat': statKey});
  }

  void grantReward(String playerId, String rewardType, String name) {
    ws.send({
      'type': 'grant_reward',
      'playerid': playerId,
      'reward_type': rewardType,
      'name': name,
    });
  }

  void equipWeapon(String playerId, String weapon) {
    ws.send({'type': 'equip_weapon', 'playerid': playerId, 'weapon': weapon});
  }

  void attack(String playerId) {
    ws.send({'type': 'attack', 'playerid': playerId});
  }

  void castSpell(String playerId, String spellName) {
    ws.send({'type': 'cast_spell', 'playerid': playerId, 'spell': spellName});
  }

  Future<void> addPlayer(Player player) async {
    ws.send({'type': 'addnew', 'player': player.toJson()});
  }

  Future<void> updatePlayer(Player player) async {
    ws.send({'type': 'update', 'player': player.toJson()});
  }

  Future<void> deletePlayer(String id) async {
    ws.send({'type': 'delete', 'id': id});
  }

  @override
  void dispose() {
    _rollStreamController.close();
    super.dispose();
  }
}
