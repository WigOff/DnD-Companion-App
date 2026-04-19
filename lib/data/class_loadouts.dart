/// Starter loadouts for each class.
class LoadoutInfo {
  final String weapon;
  final List<String> spells;
  const LoadoutInfo({required this.weapon, required this.spells});
}

/// Weapon definition with damage dice and governing stat.
class WeaponInfo {
  final String damage;
  final String stat;
  const WeaponInfo({required this.damage, required this.stat});
}

/// Spell definition with damage dice, governing stat, and whether it heals.
class SpellInfo {
  final String damage;
  final String stat;
  final bool healing;
  const SpellInfo({
    required this.damage,
    required this.stat,
    this.healing = false,
  });
}

const Map<String, LoadoutInfo> kClassLoadouts = {
  "Fighter": LoadoutInfo(weapon: "Longsword", spells: []),
  "Artificer": LoadoutInfo(
    weapon: "Light Hammer",
    spells: ["Mending", "Cure Wounds"],
  ),
  "Barbarian": LoadoutInfo(weapon: "Greatsword", spells: []),
  "Paladin": LoadoutInfo(weapon: "Longsword", spells: ["Cure Wounds", "Bless"]),
  "Ranger": LoadoutInfo(weapon: "Shortbow", spells: ["Hunter's Mark"]),
  "Rogue": LoadoutInfo(weapon: "Dagger", spells: []),
  "Monk": LoadoutInfo(weapon: "Staff", spells: []),
  "Cleric": LoadoutInfo(weapon: "Mace", spells: ["Cure Wounds", "Bless"]),
  "Druid": LoadoutInfo(
    weapon: "Staff",
    spells: ["Entangle", "Cure Wounds"],
  ),
  "Bard": LoadoutInfo(
    weapon: "Dagger",
    spells: ["Charm Person", "Healing Word"],
  ),
  "Wizard": LoadoutInfo(
    weapon: "Staff",
    spells: ["Magic Missile", "Shield"],
  ),
  "Sorcerer": LoadoutInfo(
    weapon: "Dagger",
    spells: ["Firebolt", "Magic Missile"],
  ),
  "Warlock": LoadoutInfo(weapon: "Dagger", spells: ["Eldritch Blast"]),
};

const Map<String, WeaponInfo> kAllWeapons = {
  "Longsword": WeaponInfo(damage: "1d8", stat: "strength"),
  "Greatsword": WeaponInfo(damage: "2d6", stat: "strength"),
  "Dagger": WeaponInfo(damage: "1d4", stat: "dexterity"),
  "Shortbow": WeaponInfo(damage: "1d6", stat: "dexterity"),
  "Longbow": WeaponInfo(damage: "1d8", stat: "dexterity"),
  "Staff": WeaponInfo(damage: "1d6", stat: "strength"),
  "Mace": WeaponInfo(damage: "1d6", stat: "strength"),
  "Light Hammer": WeaponInfo(damage: "1d4", stat: "strength"),
  "Warhammer": WeaponInfo(damage: "1d8", stat: "strength"),
  "Battleaxe": WeaponInfo(damage: "1d8", stat: "strength"),
  "Handaxe": WeaponInfo(damage: "1d6", stat: "strength"),
  "Rapier": WeaponInfo(damage: "1d8", stat: "dexterity"),
  "Scimitar": WeaponInfo(damage: "1d6", stat: "dexterity"),
  "Crossbow": WeaponInfo(damage: "1d8", stat: "dexterity"),
  "Javelin": WeaponInfo(damage: "1d6", stat: "strength"),
  "Trident": WeaponInfo(damage: "1d6", stat: "strength"),
  "Flail": WeaponInfo(damage: "1d8", stat: "strength"),
  "Morningstar": WeaponInfo(damage: "1d8", stat: "strength"),
  "Halberd": WeaponInfo(damage: "1d10", stat: "strength"),
  "Glaive": WeaponInfo(damage: "1d10", stat: "strength"),
  "Maul": WeaponInfo(damage: "2d6", stat: "strength"),
};

const Map<String, SpellInfo> kAllSpells = {
  "Magic Missile": SpellInfo(damage: "3d4", stat: "intelligence"),
  "Firebolt": SpellInfo(damage: "1d10", stat: "intelligence"),
  "Fireball": SpellInfo(damage: "8d6", stat: "intelligence"),
  "Lightning Bolt": SpellInfo(damage: "8d6", stat: "intelligence"),
  "Eldritch Blast": SpellInfo(damage: "1d10", stat: "charisma"),
  "Cure Wounds": SpellInfo(damage: "1d8", stat: "wisdom", healing: true),
  "Healing Word": SpellInfo(damage: "1d4", stat: "wisdom", healing: true),
  "Bless": SpellInfo(damage: "0", stat: "wisdom"),
  "Shield": SpellInfo(damage: "0", stat: "intelligence"),
  "Mending": SpellInfo(damage: "0", stat: "intelligence"),
  "Hunter's Mark": SpellInfo(damage: "1d6", stat: "wisdom"),
  "Entangle": SpellInfo(damage: "0", stat: "wisdom"),
  "Charm Person": SpellInfo(damage: "0", stat: "charisma"),
  "Thunderwave": SpellInfo(damage: "2d8", stat: "intelligence"),
  "Burning Hands": SpellInfo(damage: "3d6", stat: "intelligence"),
  "Ice Knife": SpellInfo(damage: "2d6", stat: "intelligence"),
  "Guiding Bolt": SpellInfo(damage: "4d6", stat: "wisdom"),
  "Inflict Wounds": SpellInfo(damage: "3d10", stat: "wisdom"),
  "Sacred Flame": SpellInfo(damage: "1d8", stat: "wisdom"),
  "Toll the Dead": SpellInfo(damage: "1d8", stat: "wisdom"),
  "Ray of Frost": SpellInfo(damage: "1d8", stat: "intelligence"),
  "Chill Touch": SpellInfo(damage: "1d8", stat: "intelligence"),
  "Poison Spray": SpellInfo(damage: "1d12", stat: "intelligence"),
  "Hex": SpellInfo(damage: "1d6", stat: "charisma"),
  "Smite": SpellInfo(damage: "2d8", stat: "charisma"),
  "Moonbeam": SpellInfo(damage: "2d10", stat: "wisdom"),
  "Call Lightning": SpellInfo(damage: "3d10", stat: "wisdom"),
  "Spirit Guardians": SpellInfo(damage: "3d8", stat: "wisdom"),
  "Mass Cure Wounds": SpellInfo(
    damage: "3d8",
    stat: "wisdom",
    healing: true,
  ),
  "Revivify": SpellInfo(damage: "0", stat: "wisdom", healing: true),
  "Counterspell": SpellInfo(damage: "0", stat: "intelligence"),
  "Dispel Magic": SpellInfo(damage: "0", stat: "intelligence"),
  "Misty Step": SpellInfo(damage: "0", stat: "intelligence"),
  "Haste": SpellInfo(damage: "0", stat: "intelligence"),
  "Fly": SpellInfo(damage: "0", stat: "intelligence"),
  "Invisibility": SpellInfo(damage: "0", stat: "intelligence"),
  "Hold Person": SpellInfo(damage: "0", stat: "wisdom"),
  "Banishment": SpellInfo(damage: "0", stat: "charisma"),
  "Polymorph": SpellInfo(damage: "0", stat: "intelligence"),
};
