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
  final String description;
  const WeaponInfo({
    required this.damage,
    required this.stat,
    required this.description,
  });
}

/// Spell definition with damage dice, governing stat, and whether it heals.
class SpellInfo {
  final String damage;
  final String stat;
  final bool healing;
  final String description;
  const SpellInfo({
    required this.damage,
    required this.stat,
    this.healing = false,
    required this.description,
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
  "Longsword": WeaponInfo(
    damage: "1d8",
    stat: "strength",
    description: "A versatile blade favored by warriors. Damage: 1d8 + STR mod.",
  ),
  "Greatsword": WeaponInfo(
    damage: "2d6",
    stat: "strength",
    description: "A massive blade requiring two hands. Damage: 2d6 + STR mod.",
  ),
  "Dagger": WeaponInfo(
    damage: "1d4",
    stat: "dexterity",
    description: "Small and easily hidden, good for quick stabs. Damage: 1d4 + DEX mod.",
  ),
  "Shortbow": WeaponInfo(
    damage: "1d6",
    stat: "dexterity",
    description: "A small bow for medium range. Damage: 1d6 + DEX mod.",
  ),
  "Longbow": WeaponInfo(
    damage: "1d8",
    stat: "dexterity",
    description: "A powerful bow for long distance. Damage: 1d8 + DEX mod.",
  ),
  "Staff": WeaponInfo(
    damage: "1d6",
    stat: "strength",
    description: "A simple wooden staff, also a focus for magic. Damage: 1d6 + STR mod.",
  ),
  "Mace": WeaponInfo(
    damage: "1d6",
    stat: "strength",
    description: "A heavy blunt weapon for crushing armor. Damage: 1d6 + STR mod.",
  ),
  "Light Hammer": WeaponInfo(
    damage: "1d4",
    stat: "strength",
    description: "A small hammer that can be thrown. Damage: 1d4 + STR mod.",
  ),
  "Warhammer": WeaponInfo(
    damage: "1d8",
    stat: "strength",
    description: "A heavy hammer used for bone-shattering hits. Damage: 1d8 + STR mod.",
  ),
  "Battleaxe": WeaponInfo(
    damage: "1d8",
    stat: "strength",
    description: "A heavy axe for cleaving through foes. Damage: 1d8 + STR mod.",
  ),
  "Handaxe": WeaponInfo(
    damage: "1d6",
    stat: "strength",
    description: "A light axe that is well-balanced for throwing. Damage: 1d6 + STR mod.",
  ),
  "Rapier": WeaponInfo(
    damage: "1d8",
    stat: "dexterity",
    description: "A slender, sharp blade for precise thrusts. Damage: 1d8 + DEX mod.",
  ),
  "Scimitar": WeaponInfo(
    damage: "1d6",
    stat: "dexterity",
    description: "A curved blade used for slashing attacks. Damage: 1d6 + DEX mod.",
  ),
  "Crossbow": WeaponInfo(
    damage: "1d8",
    stat: "dexterity",
    description: "A mechanical bow that shoots bolts with power. Damage: 1d8 + DEX mod.",
  ),
  "Javelin": WeaponInfo(
    damage: "1d6",
    stat: "strength",
    description: "A light spear intended for throwing. Damage: 1d6 + STR mod.",
  ),
  "Trident": WeaponInfo(
    damage: "1d6",
    stat: "strength",
    description: "A three-pronged spear focused on piercing. Damage: 1d6 + STR mod.",
  ),
  "Flail": WeaponInfo(
    damage: "1d8",
    stat: "strength",
    description: "A spiked ball on a chain, difficult to block. Damage: 1d8 + STR mod.",
  ),
  "Morningstar": WeaponInfo(
    damage: "1d8",
    stat: "strength",
    description: "A spiked club used for brutal piercings. Damage: 1d8 + STR mod.",
  ),
  "Halberd": WeaponInfo(
    damage: "1d10",
    stat: "strength",
    description: "A long-reaching polearm with an axe head. Damage: 1d10 + STR mod.",
  ),
  "Glaive": WeaponInfo(
    damage: "1d10",
    stat: "strength",
    description: "A polearm with a large curved blade. Damage: 1d10 + STR mod.",
  ),
  "Maul": WeaponInfo(
    damage: "2d6",
    stat: "strength",
    description: "A massive hammer for maximum impact. Damage: 2d6 + STR mod.",
  ),
};

const Map<String, SpellInfo> kAllSpells = {
  "Magic Missile": SpellInfo(
    damage: "3d4",
    stat: "intelligence",
    description: "Three unerring darts of magical force. Damage: 3d4 + INT mod.",
  ),
  "Firebolt": SpellInfo(
    damage: "1d10",
    stat: "intelligence",
    description: "A mote of fire thrown at the target. Damage: 1d10 + INT mod.",
  ),
  "Fireball": SpellInfo(
    damage: "8d6",
    stat: "intelligence",
    description: "A massive explosion of fire in a 20ft radius. Damage: 8d6 + INT mod.",
  ),
  "Lightning Bolt": SpellInfo(
    damage: "8d6",
    stat: "intelligence",
    description: "A stroke of lightning in a 100ft line. Damage: 8d6 + INT mod.",
  ),
  "Eldritch Blast": SpellInfo(
    damage: "1d10",
    stat: "charisma",
    description: "A beam of crackling energy streaks toward a foe. Damage: 1d10 + CHA mod.",
  ),
  "Cure Wounds": SpellInfo(
    damage: "1d8",
    stat: "wisdom",
    healing: true,
    description: "A touch heals a living creature. Healing: 1d8 + WIS mod.",
  ),
  "Healing Word": SpellInfo(
    damage: "1d4",
    stat: "wisdom",
    healing: true,
    description: "A quick word of prayer heals at a distance. Healing: 1d4 + WIS mod.",
  ),
  "Bless": SpellInfo(
    damage: "0",
    stat: "wisdom",
    description: "Bless up to 3 creatures, adding 1d4 to their rolls.",
  ),
  "Shield": SpellInfo(
    damage: "0",
    stat: "intelligence",
    description: "An invisible barrier protects you, adding +5 to AC.",
  ),
  "Mending": SpellInfo(
    damage: "0",
    stat: "intelligence",
    description: "Repairs a single break or tear in an object.",
  ),
  "Hunter's Mark": SpellInfo(
    damage: "1d6",
    stat: "wisdom",
    description: "You mark a target, dealing extra 1d6 to it. Damage: 1d6 + WIS mod.",
  ),
  "Entangle": SpellInfo(
    damage: "0",
    stat: "wisdom",
    description: "Grasping weeds and vines sprout from the ground.",
  ),
  "Charm Person": SpellInfo(
    damage: "0",
    stat: "charisma",
    description: "You attempt to charm a humanoid you can see.",
  ),
  "Thunderwave": SpellInfo(
    damage: "2d8",
    stat: "intelligence",
    description: "A wave of thunderous force sweeps out. Damage: 2d8 + INT mod.",
  ),
  "Burning Hands": SpellInfo(
    damage: "3d6",
    stat: "intelligence",
    description: "A thin sheet of flames shoots from your fingers. Damage: 3d6 + INT mod.",
  ),
  "Ice Knife": SpellInfo(
    damage: "2d6",
    stat: "intelligence",
    description: "A shard of ice pierces and explodes. Damage: 2d6 + INT mod.",
  ),
  "Guiding Bolt": SpellInfo(
    damage: "4d6",
    stat: "wisdom",
    description: "A flash of light streaks toward a creature. Damage: 4d6 + WIS mod.",
  ),
  "Inflict Wounds": SpellInfo(
    damage: "3d10",
    stat: "wisdom",
    description: "A touch of rot and decay. Damage: 3d10 + WIS mod.",
  ),
  "Sacred Flame": SpellInfo(
    damage: "1d8",
    stat: "wisdom",
    description: "Flame-like radiance descends on a creature. Damage: 1d8 + WIS mod.",
  ),
  "Toll the Dead": SpellInfo(
    damage: "1d8",
    stat: "wisdom",
    description: "The sound of a dolorous bell fills the air. Damage: 1d8 + WIS mod.",
  ),
  "Ray of Frost": SpellInfo(
    damage: "1d8",
    stat: "intelligence",
    description: "A frigid beam of blue-white light. Damage: 1d8 + INT mod.",
  ),
  "Chill Touch": SpellInfo(
    damage: "1d8",
    stat: "intelligence",
    description: "A ghostly, skeletal hand clings to the target. Damage: 1d8 + INT mod.",
  ),
  "Poison Spray": SpellInfo(
    damage: "1d12",
    stat: "intelligence",
    description: "A puff of noxious gas at a creature. Damage: 1d12 + INT mod.",
  ),
  "Hex": SpellInfo(
    damage: "1d6",
    stat: "charisma",
    description: "You place a curse on a creature. Damage: 1d6 + CHA mod.",
  ),
  "Smite": SpellInfo(
    damage: "2d8",
    stat: "charisma",
    description: "Holy energy reinforces your weapon strike. Damage: 2d8 + CHA mod.",
  ),
  "Moonbeam": SpellInfo(
    damage: "2d10",
    stat: "wisdom",
    description: "A silvery beam of pale light shines down. Damage: 2d10 + WIS mod.",
  ),
  "Call Lightning": SpellInfo(
    damage: "3d10",
    stat: "wisdom",
    description: "A bolt of lightning flashes from the sky. Damage: 3d10 + WIS mod.",
  ),
  "Spirit Guardians": SpellInfo(
    damage: "3d8",
    stat: "wisdom",
    description: "Spirits flit around you, protecting you. Damage: 3d8 + WIS mod.",
  ),
  "Mass Cure Wounds": SpellInfo(
    damage: "3d8",
    stat: "wisdom",
    healing: true,
    description: "A wave of healing energy washes out. Healing: 3d8 + WIS mod.",
  ),
  "Revivify": SpellInfo(
    damage: "0",
    stat: "wisdom",
    healing: true,
    description: "You touch a creature that has died in the last minute.",
  ),
  "Counterspell": SpellInfo(
    damage: "0",
    stat: "intelligence",
    description: "You attempt to interrupt a creature casting a spell.",
  ),
  "Dispel Magic": SpellInfo(
    damage: "0",
    stat: "intelligence",
    description: "Choose one creature, object, or magical effect to end.",
  ),
  "Misty Step": SpellInfo(
    damage: "0",
    stat: "intelligence",
    description: "Briefly surrounded by silvery mist, you teleport 30ft.",
  ),
  "Haste": SpellInfo(
    damage: "0",
    stat: "intelligence",
    description: "The target gains incredible speed and an extra action.",
  ),
  "Fly": SpellInfo(
    damage: "0",
    stat: "intelligence",
    description: "The target gains a flying speed of 60 feet.",
  ),
  "Invisibility": SpellInfo(
    damage: "0",
    stat: "intelligence",
    description: "A creature you touch becomes invisible.",
  ),
  "Hold Person": SpellInfo(
    damage: "0",
    stat: "wisdom",
    description: "Choose a humanoid to be paralyzed for the duration.",
  ),
  "Banishment": SpellInfo(
    damage: "0",
    stat: "charisma",
    description: "You attempt to send a creature to another plane.",
  ),
  "Polymorph": SpellInfo(
    damage: "0",
    stat: "intelligence",
    description: "You transform a creature into a new form.",
  ),
};
