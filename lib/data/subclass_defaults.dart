class SubclassInfo {
  final String name;
  final String description;

  const SubclassInfo({required this.name, required this.description});
}

class ClassInfo {
  final String description;
  final String shortDescription;
  final List<SubclassInfo> subclasses;

  const ClassInfo({
    required this.description,
    required this.shortDescription,
    required this.subclasses,
  });
}

const Map<String, ClassInfo> kClassInfo = {
  "Artificer": ClassInfo(
    description:
        "Artificers are powerful magic wielders who are experts at creating and forging magic items and potions to assist their allies or bring doom to their foes.",
    shortDescription: "Experts at forging magic items and inventions.",
    subclasses: [
      SubclassInfo(
        name: "Armorer(TC)",
        description:
            "Fuse powerful magic with your armor to create exoskeleton suits",
      ),
      SubclassInfo(
        name: "Alchemist(TC)",
        description: "A master of potion-making to heal, assist and destroy",
      ),
      SubclassInfo(
        name: "Artillerist(TC)",
        description:
            "Control the battlefield by summoning powerful magic cannons",
      ),
      SubclassInfo(
        name: "Battle Smith(TC)",
        description: "Creating magical machines that fight and protect others.",
      ),
    ],
  ),
  "Barbarian": ClassInfo(
    description:
        "Barbarians are powerful warriors whose strength comes from their rage. Able to use their anger as a weapon.",
    shortDescription: "Primal warriors whose strength is fueled by rage.",
    subclasses: [
      SubclassInfo(
        name: "Berserker(PH)",
        description:
            "Fall into your rage entirely to deliver a tide of powerful blows.",
      ),
      SubclassInfo(
        name: "Totem Warrior(PH)",
        description:
            "Your rage comes from the animal spirits of the world who aid.",
      ),
      SubclassInfo(
        name: "Ancestral Guardian(XG)",
        description: "Your rage is the combination of all your ancestors.",
      ),
      SubclassInfo(
        name: "Storm Herald(XG)",
        description:
            "Your rage is second only to that of mother nature, who joins you.",
      ),
      SubclassInfo(
        name: "Zealot(XG)",
        description:
            "The rage acts as a gift from the gods. You are their champion.",
      ),
      SubclassInfo(
        name: "Beast(TC)",
        description:
            "Gifts from the beasts of this world as you manifest their power.",
      ),
      SubclassInfo(
        name: "Wild Soul(TC)",
        description:
            "Your rage is strong enough to shatter the walls of magic.",
      ),
      SubclassInfo(
        name: "Battlerager(SC)",
        description:
            "Giving yourself over to your rage, make your body a weapon",
      ),
    ],
  ),
  "Bard": ClassInfo(
    description:
        "A poet, a singer, a storyteller. Bards seek to bring wonder to the world, and their magic comes from their emotions.",
    shortDescription: "Storytellers whose magic flows from music and emotion.",
    subclasses: [
      SubclassInfo(
        name: "College of Lore(PH)",
        description:
            "A way to keep the stories of history and civilizations alive",
      ),
      SubclassInfo(
        name: "College of Valor(PH)",
        description: "Those that tell vibrant and powerful war stories.",
      ),
      SubclassInfo(
        name: "College of Creation(TC)",
        description: "Your music and stories shape the very fabric of reality",
      ),
      SubclassInfo(
        name: "College of Glamor(XG)",
        description: "Blessed by the Feywild, your looks are rivaled by none.",
      ),
      SubclassInfo(
        name: "College of Swords(XG)",
        description:
            "Become the best and most elegant sword fighter in the world.",
      ),
      SubclassInfo(
        name: "College of Whispers(XG)",
        description: "The hypnotic power of bards can be used for stealth",
      ),
      SubclassInfo(
        name: "College of Eloquence(TC)",
        description: "Words have power; use them to shape any situation",
      ),
      SubclassInfo(
        name: "College of Spirits(RL)",
        description:
            "The dead tell stories and have experiences that you can draw on.",
      ),
    ],
  ),
  "Cleric": ClassInfo(
    description:
        "Ideas are immortal things that can topple empires. Clerics are champions of these ideas, usually following a deity.",
    shortDescription: "Divine champions serving a higher power or ideal.",
    subclasses: [
      SubclassInfo(
        name: "Knowledge Domain(PH)",
        description:
            "Serve the idea that knowledge is power, and it must endure",
      ),
      SubclassInfo(
        name: "Life Domain(PH)",
        description:
            "Serve the idea of life; every life and living thing is a wonder",
      ),
      SubclassInfo(
        name: "Light Domain(PH)",
        description:
            "Serve the idea of light; it will burn back the forces of shadow",
      ),
      SubclassInfo(
        name: "Nature Domain(PH)",
        description:
            "Serve the idea of nature; the natural world can’t ever fall.",
      ),
      SubclassInfo(
        name: "Tempest Domain(PH)",
        description:
            "Serve the idea of change, storms are powerful and resistant",
      ),
      SubclassInfo(
        name: "Trickery Domain(PH)",
        description:
            "Serve the idea of deception, pranks, or more keeps the world moving",
      ),
      SubclassInfo(
        name: "War Domain(PH)",
        description:
            "Serve the idea of war, whether it’s war for honor or power.",
      ),
      SubclassInfo(
        name: "Death Domain(DM)",
        description: "Serve the idea of death; everything must eventually end.",
      ),
      SubclassInfo(
        name: "Twilight Domain(TC)",
        description:
            "Serve the idea of balance; those that attempt to disrupt it must be stopped",
      ),
      SubclassInfo(
        name: "Order Domain(TC)",
        description:
            "Serve the idea of order and law; you are the voice of justice.",
      ),
      SubclassInfo(
        name: "Forge Domain(XG)",
        description:
            "Serve the idea of creation; the forges you touch will never fail",
      ),
      SubclassInfo(
        name: "Grave Domain(XG)",
        description:
            "Serve the idea of life and death; the balance must be maintained",
      ),
      SubclassInfo(
        name: "Peace Domain(TC)",
        description:
            "Serve the idea of peace; violence is almost never the answer.",
      ),
      SubclassInfo(
        name: "Arcane Domain(SC)",
        description: "Serve the idea of magic; magic is a power and a wonder",
      ),
    ],
  ),
  "Druid": ClassInfo(
    description:
        "Druids are protectors of nature, embodying its wrath and beauty. They can shapeshift and draw power from nature.",
    shortDescription: "Protectors of nature who can assume animal forms.",
    subclasses: [
      SubclassInfo(
        name: "Circle of the Land(PH)",
        description:
            "Grown within a certain biome, your power comes from there.",
      ),
      SubclassInfo(
        name: "Circle of the Moon(PH)",
        description: "Like a werewolf, your power is based on changing forms.",
      ),
      SubclassInfo(
        name: "Circle of Dreams(XG)",
        description:
            "The Feywild’s nature has blessed you with the power to heal.",
      ),
      SubclassInfo(
        name: "Circle of the Shepherd(XG)",
        description: "Like a shepherd, you protect the animals of the world.",
      ),
      SubclassInfo(
        name: "Circle of Spores(TC)",
        description:
            "Mycelium has many uses and abilities, including raising the dead",
      ),
      SubclassInfo(
        name: "Circle of Stars(TC)",
        description: "The answer and guidance can always be found in the stars",
      ),
      SubclassInfo(
        name: "Circle of Wildfire(TC)",
        description: "Wildfires bring about change, ecosystems always revive.",
      ),
    ],
  ),
  "Fighter": ClassInfo(
    description:
        "Warriors who hone their combative ability to a deadly skill that rivals none.",
    shortDescription: "Masters of martial combat and diverse weaponry.",
    subclasses: [
      SubclassInfo(
        name: "Champion(PH)",
        description:
            "Hone your martial ability into an incredibly deadly skill with constant crits",
      ),
      SubclassInfo(
        name: "Battle Master(PH)",
        description:
            "Use the art of war and tactics to gain advantages and command to victory",
      ),
      SubclassInfo(
        name: "Eldritch Knight(PH)",
        description:
            "Learning wizard-like spells to gain the upperhand in any fight.",
      ),
      SubclassInfo(
        name: "Arcane Archer(XG)",
        description:
            "Mix magic with your arrows to rain literal fire down upon your foes",
      ),
      SubclassInfo(
        name: "Cavalier(XG)",
        description:
            "You will never break; your skill, while mounted or not, can not be beaten.",
      ),
      SubclassInfo(
        name: "Samurai(XG)",
        description:
            "Your fighting spirit will allow you to rain a hurricane of deadly blows.",
      ),
      SubclassInfo(
        name: "Psi Warrior(TC)",
        description:
            "Blessed with psychic energy, your mind is sharpened just like your weapon.",
      ),
      SubclassInfo(
        name: "Rune Knight(TC)",
        description:
            "Learn the ancient power of Giants and their powerful magic runes.",
      ),
      SubclassInfo(
        name: "Echo Fighter(WM)",
        description:
            "Using magical energy, create an “echo” to fight with you.",
      ),
      SubclassInfo(
        name: "Purple Dragon Knight(SC)",
        description: "A warrior that braves any battle through inspiration",
      ),
    ],
  ),
  "Monk": ClassInfo(
    description:
        "Monks train in spirit, ki, and martial arts to deliver a storm of powerful melee attacks.",
    shortDescription: "Martial artists who harness the power of Ki.",
    subclasses: [
      SubclassInfo(
        name: "Way of the Open Hand(PH)",
        description: "Use your fists and palms to annihilate your foe.",
      ),
      SubclassInfo(
        name: "Way of the Shadow(PH)",
        description: "Their fists strike from the shadow, like ninjas.",
      ),
      SubclassInfo(
        name: "Way of the Four Elements(PH)",
        description: "Control all 4 elements in your ways.",
      ),
      SubclassInfo(
        name: "Way of Mercy(TC)",
        description:
            "Your ki and spirit is meant to heal wounds, not create them.",
      ),
      SubclassInfo(
        name: "Way of the Astral Self(TC)",
        description: "Your spirit becomes an entity around you to help you.",
      ),
      SubclassInfo(
        name: "Way of the Drunken Master(XG)",
        description: "Confuse your foes with unpredictable attacks.",
      ),
      SubclassInfo(
        name: "Way of the Kensei(XG)",
        description: "Your weapons become an extension of yourself.",
      ),
      SubclassInfo(
        name: "Way of the Sun Soul(XG)",
        description:
            "Your soul and will is so powerful that it can ignite in fire.",
      ),
      SubclassInfo(
        name: "Way of Long Death(SC)",
        description: "Your soul and fists become the tools of death",
      ),
      SubclassInfo(
        name: "Way of the Ascendant Dragon (FD)",
        description: "Your spirit manifests the power of dragons",
      ),
    ],
  ),
  "Paladin": ClassInfo(
    description:
        "Paladins serve sacred oaths and ideals of joy, light, or conquest.",
    shortDescription: "Holy warriors bound by a sacred oath.",
    subclasses: [
      SubclassInfo(
        name: "Oath of Devotion(PH)",
        description: "Light, Lawful, Honesty, the pure holy warrior",
      ),
      SubclassInfo(
        name: "Oath of the Ancients(PH)",
        description:
            "Joy and love, the ancients blessed this warrior with nature",
      ),
      SubclassInfo(
        name: "Oath of Vengeance(PH)",
        description: "Anger and vengeance drive this warrior.",
      ),
      SubclassInfo(
        name: "Oathbreaker(DM)",
        description: "They broke an oath long ago and are cursed for it",
      ),
      SubclassInfo(
        name: "Oath of Conquest(XG)",
        description: "Destruction and Victory, nothing will stop this warrior.",
      ),
      SubclassInfo(
        name: "Oath of Redemption(XG)",
        description: "A warrior that uses words instead of the sword",
      ),
      SubclassInfo(
        name: "Oath of Glory(TC)",
        description: "A warrior that is destined for glory.",
      ),
      SubclassInfo(
        name: "Oath of the Watchers(TC)",
        description: "A warrior sworn to fight anything supernatural.",
      ),
      SubclassInfo(
        name: "Oath of the Crown(SC)",
        description: "A warrior that serves a crown or kingdom",
      ),
    ],
  ),
  "Ranger": ClassInfo(
    description:
        "Rangers are survivalists who live in the wild, hunting specific types of monsters.",
    shortDescription: "Survivalists and hunters of the wild.",
    subclasses: [
      SubclassInfo(
        name: "Fey Wanderer(TC)",
        description: "With the power of fey, these rangers charm their foes",
      ),
      SubclassInfo(
        name: "Swarmkeeper(TC)",
        description: "These rangers take care of swarms of creatures.",
      ),
      SubclassInfo(
        name: "Gloom Stalker(XG)",
        description: "Hunters who wander in the shadows.",
      ),
      SubclassInfo(
        name: "Horizon Walker(XG)",
        description: "Hunters who seek out creatures from other worlds.",
      ),
      SubclassInfo(
        name: "Monster Slayer(XG)",
        description: "Warriors who hunt down powerful monsters",
      ),
      SubclassInfo(
        name: "Hunter(PH)",
        description: "Hones their fighting style to hunt.",
      ),
      SubclassInfo(
        name: "Beast Master(PH)",
        description: "Gained the assistance of a spiritual beast.",
      ),
      SubclassInfo(
        name: "Drakewarden (FD)",
        description: "Gained the assistance of a powerful drake.",
      ),
    ],
  ),
  "Rogue": ClassInfo(
    description: "Experts in skills, thievery, and precise, deadly strikes.",
    shortDescription: "Specialists in stealth, skill, and precise strikes.",
    subclasses: [
      SubclassInfo(
        name: "Thief(PH)",
        description: "Experts at breaking into things and stealing",
      ),
      SubclassInfo(
        name: "Assassin(PH)",
        description: "Masters at killing while unseen",
      ),
      SubclassInfo(
        name: "Arcane Trickster(PH)",
        description: "Mix magic into their skills, enhancing them",
      ),
      SubclassInfo(
        name: "Inquisitive(XG)",
        description: "Watch targets and use their patterns like a detective",
      ),
      SubclassInfo(
        name: "Mastermind(XG)",
        description: "Deadly smart, using intelligence to fight",
      ),
      SubclassInfo(
        name: "Scout(XG)",
        description: "Ambushing and stealthing with speed.",
      ),
      SubclassInfo(
        name: "Swashbuckler(XG)",
        description: "Fast and light on their feet, impossible to pin",
      ),
      SubclassInfo(
        name: "Phantom(TC)",
        description: "Shadow magic within the heart, stealing souls.",
      ),
      SubclassInfo(
        name: "Soulknife(TC)",
        description: "Psychic mind enhances roguish skills.",
      ),
    ],
  ),
  "Sorcerer": ClassInfo(
    description:
        "Born with magical energy in their blood, linked to emotions and mind.",
    shortDescription: "Innate magic wielders with power in their blood.",
    subclasses: [
      SubclassInfo(
        name: "Aberrant Mind(TC)",
        description: "Powerful psychic mind magic.",
      ),
      SubclassInfo(
        name: "Clockwork Soul(TC)",
        description: "The balance of the universe flows through their veins",
      ),
      SubclassInfo(
        name: "Divine Soul(XG)",
        description: "With blood from something Divine.",
      ),
      SubclassInfo(
        name: "Shadow Magic(XG)",
        description: "Manipulates shadows with cursed magic.",
      ),
      SubclassInfo(
        name: "Storm Sorcery(XG)",
        description: "With the blood of a powerful hurricane.",
      ),
      SubclassInfo(
        name: "Draconic Bloodline(PH)",
        description: "Dragon ancestors manifest in their nature.",
      ),
      SubclassInfo(
        name: "Wild Magic(PH)",
        description: "The chaos of the universe flows through their veins.",
      ),
    ],
  ),
  "Warlock": ClassInfo(
    description:
        "Mortals who have signed a magical contract with immortal entities for power.",
    shortDescription:
        "Seekers of knowledge who strike pacts with powerful entities.",
    subclasses: [
      SubclassInfo(
        name: "The Archfey(PH)",
        description: "A magical pact with an Archfey of the feywild",
      ),
      SubclassInfo(
        name: "The Fiend(PH)",
        description: "A magical pact with a demonic or devilish entity",
      ),
      SubclassInfo(
        name: "The Great Old One(PH)",
        description:
            "An ancient and powerful unknown entity from worlds beyond",
      ),
      SubclassInfo(
        name: "The Celestial(XG)",
        description: "A magical pact with an entity of good, law, and order.",
      ),
      SubclassInfo(
        name: "Undying(SC)",
        description: "A magical pact with an entity that represents the dead.",
      ),
      SubclassInfo(
        name: "The Hexblade(XG)",
        description:
            "A magical pact with an entity related to a powerful weapon.",
      ),
      SubclassInfo(
        name: "The Fathomless(TC)",
        description:
            "A magical pact with a creature of the world's deep oceans.",
      ),
      SubclassInfo(
        name: "The Genie(TC)",
        description: "A magical pact with a powerful elemental.",
      ),
      SubclassInfo(
        name: "The Undead(RL)",
        description: "A magical pact with a powerful deathless being.",
      ),
    ],
  ),
  "Wizard": ClassInfo(
    description:
        "The apex of the arcane, mastering magic through massive knowledge and study.",
    shortDescription:
        "Scholarly magic users who master the arcane through study.",
    subclasses: [
      SubclassInfo(
        name: "School of Abjuration(PH)",
        description: "Study the defensive powers of magic",
      ),
      SubclassInfo(
        name: "School of Conjuration(PH)",
        description: "Study the ways to control the creatures you summon",
      ),
      SubclassInfo(
        name: "School of Divination(PH)",
        description: "Study the ways magic can show you the future and past",
      ),
      SubclassInfo(
        name: "School of Enchantment(PH)",
        description: "Study the ways that magic can bend the minds of others",
      ),
      SubclassInfo(
        name: "School of Evocation(PH)",
        description: "Study the ways that magic can destroy and offense",
      ),
      SubclassInfo(
        name: "School of Illusion(PH)",
        description:
            "Study the ways that magic can make the eyes of others lie",
      ),
      SubclassInfo(
        name: "School of Necromancy(PH)",
        description: "Study the forces of life and death",
      ),
      SubclassInfo(
        name: "School of Transmutation(PH)",
        description: "Study the ways magic can shift reality",
      ),
      SubclassInfo(
        name: "School of Graviturgy(WM)",
        description: "Study the ways magic can shift and manipulate gravity",
      ),
      SubclassInfo(
        name: "School of Chronurgy(WM)",
        description: "Study the ways magic can shift and bend time itself",
      ),
      SubclassInfo(
        name: "War Magic(XG)",
        description: "Study the ways magic can be used in combat",
      ),
      SubclassInfo(
        name: "Bladesinging(TC)",
        description: "Wizardry that incorporates swordplay and dance.",
      ),
      SubclassInfo(
        name: "Order of Scribes(TC)",
        description: "Magic enhanced through books of power",
      ),
    ],
  ),
};
