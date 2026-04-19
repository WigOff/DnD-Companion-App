import 'dart:convert';

class Player {
  final String? id;
  final String name;
  final String race;
  final String playerClass;
  final int level;
  final int xp;
  final int gold;
  final int pointsleft;
  final int availablePoints;
  final int health;
  final int maxHealth;
  final int mana;
  final int maxMana;
  final int proficiencyBonus;
  final int armorClass;
  final int strength;
  final int dexterity;
  final int constitution;
  final int intelligence;
  final int wisdom;
  final int charisma;
  final String subclass;
  final String subclassDescription;
  final String weapon;
  final List<String> spells;
  final List<String> inventoryWeapons;
  final List<String> knownSpells;

  Player({
    this.id,
    required this.name,
    required this.race,
    required this.playerClass,
    required this.level,
    required this.xp,
    required this.gold,
    required this.pointsleft,
    this.availablePoints = 0,
    required this.health,
    required this.maxHealth,
    required this.mana,
    required this.maxMana,
    required this.proficiencyBonus,
    required this.armorClass,
    required this.strength,
    required this.dexterity,
    required this.constitution,
    required this.intelligence,
    required this.wisdom,
    required this.charisma,
    this.subclass = 'None',
    this.subclassDescription = '',
    this.weapon = '',
    this.spells = const [],
    this.inventoryWeapons = const [],
    this.knownSpells = const [],
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      name: json['name'],
      race: json['race'],
      playerClass: json['playerClass'],
      level: json['level'],
      xp: json['xp'],
      gold: json['gold'],
      pointsleft: json['pointsleft'],
      availablePoints: json['availablePoints'] ?? 0,
      health: json['health'],
      maxHealth: json['maxHealth'],
      mana: json['mana'],
      maxMana: json['maxMana'],
      proficiencyBonus: json['proficiencyBonus'],
      armorClass: json['armorClass'],
      strength: json['strength'],
      dexterity: json['dexterity'],
      constitution: json['constitution'],
      intelligence: json['intelligence'],
      wisdom: json['wisdom'],
      charisma: json['charisma'],
      subclass: json['subclass'] ?? 'None',
      subclassDescription: json['subclassDescription'] ?? '',
      weapon: json['weapon'] ?? '',
      spells: List<String>.from(json['spells'] ?? []),
      inventoryWeapons: List<String>.from(json['inventoryWeapons'] ?? []),
      knownSpells: List<String>.from(json['knownSpells'] ?? []),
    );
  }

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id'],
      name: map['name'],
      race: map['race'],
      playerClass: map['playerClass'],
      level: map['level'],
      xp: map['xp'],
      gold: map['gold'],
      pointsleft: map['pointsleft'],
      availablePoints: map['availablePoints'] ?? 0,
      health: map['health'],
      maxHealth: map['maxHealth'],
      mana: map['mana'],
      maxMana: map['maxMana'],
      proficiencyBonus: map['proficiencyBonus'],
      armorClass: map['armorClass'],
      strength: map['strength'],
      dexterity: map['dexterity'],
      constitution: map['constitution'],
      intelligence: map['intelligence'],
      wisdom: map['wisdom'],
      charisma: map['charisma'],
      subclass: map['subclass'] ?? 'None',
      subclassDescription: map['subclassDescription'] ?? '',
      weapon: map['weapon'] ?? '',
      spells: _decodeList(map['spells']),
      inventoryWeapons: _decodeList(map['inventoryWeapons']),
      knownSpells: _decodeList(map['knownSpells']),
    );
  }

  /// Decode a list that may be stored as a JSON string (SQLite) or native list.
  static List<String> _decodeList(dynamic value) {
    if (value == null) return [];
    if (value is List) return List<String>.from(value);
    if (value is String) {
      try {
        return List<String>.from(jsonDecode(value));
      } catch (_) {
        return [];
      }
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'race': race,
      'playerClass': playerClass,
      'level': level,
      'xp': xp,
      'gold': gold,
      'pointsleft': pointsleft,
      'availablePoints': availablePoints,
      'health': health,
      'maxHealth': maxHealth,
      'mana': mana,
      'maxMana': maxMana,
      'proficiencyBonus': proficiencyBonus,
      'armorClass': armorClass,
      'strength': strength,
      'dexterity': dexterity,
      'constitution': constitution,
      'intelligence': intelligence,
      'wisdom': wisdom,
      'charisma': charisma,
      'subclass': subclass,
      'subclassDescription': subclassDescription,
      'weapon': weapon,
      'spells': spells,
      'inventoryWeapons': inventoryWeapons,
      'knownSpells': knownSpells,
    };
  }

  /// For SQLite — lists are stored as JSON-encoded strings.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'race': race,
      'playerClass': playerClass,
      'level': level,
      'xp': xp,
      'gold': gold,
      'pointsleft': pointsleft,
      'availablePoints': availablePoints,
      'health': health,
      'maxHealth': maxHealth,
      'mana': mana,
      'maxMana': maxMana,
      'proficiencyBonus': proficiencyBonus,
      'armorClass': armorClass,
      'strength': strength,
      'dexterity': dexterity,
      'constitution': constitution,
      'intelligence': intelligence,
      'wisdom': wisdom,
      'charisma': charisma,
      'subclass': subclass,
      'subclassDescription': subclassDescription,
      'weapon': weapon,
      'spells': jsonEncode(spells),
      'inventoryWeapons': jsonEncode(inventoryWeapons),
      'knownSpells': jsonEncode(knownSpells),
    };
  }

  /// Calculates the proficiency bonus based on level (1-4: +2, 5-8: +3, etc.)
  int get calculatedProficiencyBonus => 2 + ((level - 1) ~/ 4);

  Player copyWith({
    String? id,
    String? name,
    String? race,
    String? playerClass,
    int? level,
    int? xp,
    int? gold,
    int? pointsleft,
    int? availablePoints,
    int? health,
    int? maxHealth,
    int? mana,
    int? maxMana,
    int? proficiencyBonus,
    int? armorClass,
    int? strength,
    int? dexterity,
    int? constitution,
    int? intelligence,
    int? wisdom,
    int? charisma,
    String? subclass,
    String? subclassDescription,
    String? weapon,
    List<String>? spells,
    List<String>? inventoryWeapons,
    List<String>? knownSpells,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      race: race ?? this.race,
      playerClass: playerClass ?? this.playerClass,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      gold: gold ?? this.gold,
      pointsleft: pointsleft ?? this.pointsleft,
      availablePoints: availablePoints ?? this.availablePoints,
      health: health ?? this.health,
      maxHealth: maxHealth ?? this.maxHealth,
      mana: mana ?? this.mana,
      maxMana: maxMana ?? this.maxMana,
      proficiencyBonus: proficiencyBonus ?? this.proficiencyBonus,
      armorClass: armorClass ?? this.armorClass,
      strength: strength ?? this.strength,
      dexterity: dexterity ?? this.dexterity,
      constitution: constitution ?? this.constitution,
      intelligence: intelligence ?? this.intelligence,
      wisdom: wisdom ?? this.wisdom,
      charisma: charisma ?? this.charisma,
      subclass: subclass ?? this.subclass,
      subclassDescription: subclassDescription ?? this.subclassDescription,
      weapon: weapon ?? this.weapon,
      spells: spells ?? this.spells,
      inventoryWeapons: inventoryWeapons ?? this.inventoryWeapons,
      knownSpells: knownSpells ?? this.knownSpells,
    );
  }
}
