from fastapi import FastAPI, WebSocket
from fastapi.middleware.cors import CORSMiddleware
import json
import uuid
import random

app = FastAPI()
connections = []

origins = [
    "*",  # allow all (good for dev)
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


import os

STATE_FILE = "game_state.json"

CLASS_DEFAULTS = {
    "Fighter":   {"strength":14,"dexterity":10,"constitution":14,"intelligence":6,"wisdom":8,"charisma":8},
    "Artificer": {"strength":8, "dexterity":10,"constitution":12,"intelligence":15,"wisdom":10,"charisma":8},
    "Barbarian": {"strength":15,"dexterity":10,"constitution":15,"intelligence":5,"wisdom":7,"charisma":8},
    "Paladin":   {"strength":13,"dexterity":8,"constitution":13,"intelligence":6,"wisdom":8,"charisma":12},
    "Ranger":    {"strength":10,"dexterity":14,"constitution":10,"intelligence":8,"wisdom":12,"charisma":6},
    "Rogue":     {"strength":8,"dexterity":15,"constitution":10,"intelligence":12,"wisdom":7,"charisma":8},
    "Monk":      {"strength":10,"dexterity":14,"constitution":10,"intelligence":8,"wisdom":12,"charisma":6},
    "Cleric":    {"strength":10,"dexterity":8,"constitution":12,"intelligence":8,"wisdom":15,"charisma":7},
    "Druid":     {"strength":8,"dexterity":10,"constitution":12,"intelligence":10,"wisdom":15,"charisma":5},
    "Bard":      {"strength":8,"dexterity":12,"constitution":10,"intelligence":10,"wisdom":8,"charisma":12},
    "Wizard":    {"strength":6,"dexterity":10,"constitution":10,"intelligence":15,"wisdom":10,"charisma":9},
    "Sorcerer":  {"strength":6,"dexterity":12,"constitution":10,"intelligence":10,"wisdom":8,"charisma":14},
    "Warlock":   {"strength":8,"dexterity":10,"constitution":12,"intelligence":8,"wisdom":8,"charisma":14},
}

CLASS_LOADOUTS = {
    "Fighter":   {"weapon": "Longsword",     "spells": []},
    "Artificer": {"weapon": "Light Hammer",  "spells": ["Mending", "Cure Wounds"]},
    "Barbarian": {"weapon": "Greatsword",    "spells": []},
    "Paladin":   {"weapon": "Longsword",     "spells": ["Cure Wounds", "Bless"]},
    "Ranger":    {"weapon": "Shortbow",      "spells": ["Hunter's Mark"]},
    "Rogue":     {"weapon": "Dagger",        "spells": []},
    "Monk":      {"weapon": "Staff",         "spells": []},
    "Cleric":    {"weapon": "Mace",          "spells": ["Cure Wounds", "Bless"]},
    "Druid":     {"weapon": "Staff",         "spells": ["Entangle", "Cure Wounds"]},
    "Bard":      {"weapon": "Dagger",        "spells": ["Charm Person", "Healing Word"]},
    "Wizard":    {"weapon": "Staff",         "spells": ["Magic Missile", "Shield"]},
    "Sorcerer":  {"weapon": "Dagger",        "spells": ["Firebolt", "Magic Missile"]},
    "Warlock":   {"weapon": "Dagger",        "spells": ["Eldritch Blast"]},
}

ALL_WEAPONS = {
    "Longsword":    {"damage": "1d8",  "stat": "strength",     "description": "A versatile blade favored by warriors. Damage: 1d8 + STR mod."},
    "Greatsword":   {"damage": "2d6",  "stat": "strength",     "description": "A massive blade requiring two hands. Damage: 2d6 + STR mod."},
    "Dagger":       {"damage": "1d4",  "stat": "dexterity",    "description": "Small and easily hidden, good for quick stabs. Damage: 1d4 + DEX mod."},
    "Shortbow":     {"damage": "1d6",  "stat": "dexterity",    "description": "A small bow for medium range. Damage: 1d6 + DEX mod."},
    "Longbow":      {"damage": "1d8",  "stat": "dexterity",    "description": "A powerful bow for long distance. Damage: 1d8 + DEX mod."},
    "Staff":        {"damage": "1d6",  "stat": "strength",     "description": "A simple wooden staff, also a focus for magic. Damage: 1d6 + STR mod."},
    "Mace":         {"damage": "1d6",  "stat": "strength",     "description": "A heavy blunt weapon for crushing armor. Damage: 1d6 + STR mod."},
    "Light Hammer": {"damage": "1d4",  "stat": "strength",     "description": "A small hammer that can be thrown. Damage: 1d4 + STR mod."},
    "Warhammer":    {"damage": "1d8",  "stat": "strength",     "description": "A heavy hammer used for bone-shattering hits. Damage: 1d8 + STR mod."},
    "Battleaxe":    {"damage": "1d8",  "stat": "strength",     "description": "A heavy axe for cleaving through foes. Damage: 1d8 + STR mod."},
    "Handaxe":      {"damage": "1d6",  "stat": "strength",     "description": "A light axe that is well-balanced for throwing. Damage: 1d6 + STR mod."},
    "Rapier":       {"damage": "1d8",  "stat": "dexterity",    "description": "A slender, sharp blade for precise thrusts. Damage: 1d8 + DEX mod."},
    "Scimitar":     {"damage": "1d6",  "stat": "dexterity",    "description": "A curved blade used for slashing attacks. Damage: 1d6 + DEX mod."},
    "Crossbow":     {"damage": "1d8",  "stat": "dexterity",    "description": "A mechanical bow that shoots bolts with power. Damage: 1d8 + DEX mod."},
    "Javelin":      {"damage": "1d6",  "stat": "strength",     "description": "A light spear intended for throwing. Damage: 1d6 + STR mod."},
    "Trident":      {"damage": "1d6",  "stat": "strength",     "description": "A three-pronged spear focused on piercing. Damage: 1d6 + STR mod."},
    "Flail":        {"damage": "1d8",  "stat": "strength",     "description": "A spiked ball on a chain, difficult to block. Damage: 1d8 + STR mod."},
    "Morningstar":  {"damage": "1d8",  "stat": "strength",     "description": "A spiked club used for brutal piercings. Damage: 1d8 + STR mod."},
    "Halberd":      {"damage": "1d10", "stat": "strength",     "description": "A long-reaching polearm with an axe head. Damage: 1d10 + STR mod."},
    "Glaive":       {"damage": "1d10", "stat": "strength",     "description": "A polearm with a large curved blade. Damage: 1d10 + STR mod."},
    "Maul":         {"damage": "2d6",  "stat": "strength",     "description": "A massive hammer for maximum impact. Damage: 2d6 + STR mod."},
}

ALL_SPELLS = {
    "Magic Missile":    {"damage": "3d4",  "stat": "intelligence", "description": "Three unerring darts of magical force. Damage: 3d4 + INT mod."},
    "Firebolt":         {"damage": "1d10", "stat": "intelligence", "description": "A mote of fire thrown at the target. Damage: 1d10 + INT mod."},
    "Fireball":         {"damage": "8d6",  "stat": "intelligence", "description": "A massive explosion of fire in a 20ft radius. Damage: 8d6 + INT mod."},
    "Lightning Bolt":   {"damage": "8d6",  "stat": "intelligence", "description": "A stroke of lightning in a 100ft line. Damage: 8d6 + INT mod."},
    "Eldritch Blast":   {"damage": "1d10", "stat": "charisma",     "description": "A beam of crackling energy streaks toward a foe. Damage: 1d10 + CHA mod."},
    "Cure Wounds":      {"damage": "1d8",  "stat": "wisdom",       "healing": True,  "description": "A touch heals a living creature. Healing: 1d8 + WIS mod."},
    "Healing Word":     {"damage": "1d4",  "stat": "wisdom",       "healing": True,  "description": "A quick word of prayer heals at a distance. Healing: 1d4 + WIS mod."},
    "Bless":            {"damage": "0",    "stat": "wisdom",       "description": "Bless up to 3 creatures, adding 1d4 to their rolls."},
    "Shield":           {"damage": "0",    "stat": "intelligence", "description": "An invisible barrier protects you, adding +5 to AC."},
    "Mending":          {"damage": "0",    "stat": "intelligence", "description": "Repairs a single break or tear in an object."},
    "Hunter's Mark":    {"damage": "1d6",  "stat": "wisdom",       "description": "You mark a target, dealing extra 1d6 to it. Damage: 1d6 + WIS mod."},
    "Entangle":         {"damage": "0",    "stat": "wisdom",       "description": "Grasping weeds and vines sprout from the ground."},
    "Charm Person":     {"damage": "0",    "stat": "charisma",     "description": "You attempt to charm a humanoid you can see."},
    "Thunderwave":      {"damage": "2d8",  "stat": "intelligence", "description": "A wave of thunderous force sweeps out. Damage: 2d8 + INT mod."},
    "Burning Hands":    {"damage": "3d6",  "stat": "intelligence", "description": "A thin sheet of flames shoots from your fingers. Damage: 3d6 + INT mod."},
    "Ice Knife":        {"damage": "2d6",  "stat": "intelligence", "description": "A shard of ice pierces and explodes. Damage: 2d6 + INT mod."},
    "Guiding Bolt":     {"damage": "4d6",  "stat": "wisdom",       "description": "A flash of light streaks toward a creature. Damage: 4d6 + WIS mod."},
    "Inflict Wounds":   {"damage": "3d10", "stat": "wisdom",       "description": "A touch of rot and decay. Damage: 3d10 + WIS mod."},
    "Sacred Flame":     {"damage": "1d8",  "stat": "wisdom",       "description": "Flame-like radiance descends on a creature. Damage: 1d8 + WIS mod."},
    "Toll the Dead":    {"damage": "1d8",  "stat": "wisdom",       "description": "The sound of a dolorous bell fills the air. Damage: 1d8 + WIS mod."},
    "Ray of Frost":     {"damage": "1d8",  "stat": "intelligence", "description": "A frigid beam of blue-white light. Damage: 1d8 + INT mod."},
    "Chill Touch":      {"damage": "1d8",  "stat": "intelligence", "description": "A ghostly, skeletal hand clings to the target. Damage: 1d8 + INT mod."},
    "Poison Spray":     {"damage": "1d12", "stat": "intelligence", "description": "A puff of noxious gas at a creature. Damage: 1d12 + INT mod."},
    "Hex":              {"damage": "1d6",  "stat": "charisma",     "description": "You place a curse on a creature. Damage: 1d6 + CHA mod."},
    "Smite":            {"damage": "2d8",  "stat": "charisma",     "description": "Holy energy reinforces your weapon strike. Damage: 2d8 + CHA mod."},
    "Moonbeam":         {"damage": "2d10", "stat": "wisdom",       "description": "A silvery beam of pale light shines down. Damage: 2d10 + WIS mod."},
    "Call Lightning":   {"damage": "3d10", "stat": "wisdom",       "description": "A bolt of lightning flashes from the sky. Damage: 3d10 + WIS mod."},
    "Spirit Guardians": {"damage": "3d8",  "stat": "wisdom",       "description": "Spirits flit around you, protecting you. Damage: 3d8 + WIS mod."},
    "Mass Cure Wounds": {"damage": "3d8",  "stat": "wisdom",       "healing": True,  "description": "A wave of healing energy washes out. Healing: 3d8 + WIS mod."},
    "Revivify":         {"damage": "0",    "stat": "wisdom",       "healing": True,  "description": "You touch a creature that has died in the last minute."},
    "Counterspell":     {"damage": "0",    "stat": "intelligence", "description": "You attempt to interrupt a creature casting a spell."},
    "Dispel Magic":     {"damage": "0",    "stat": "intelligence", "description": "Choose one creature, object, or magical effect to end."},
    "Misty Step":       {"damage": "0",    "stat": "intelligence", "description": "Briefly surrounded by silvery mist, you teleport 30ft."},
    "Haste":            {"damage": "0",    "stat": "intelligence", "description": "The target gains incredible speed and an extra action."},
    "Fly":              {"damage": "0",    "stat": "intelligence", "description": "The target gains a flying speed of 60 feet."},
    "Invisibility":     {"damage": "0",    "stat": "intelligence", "description": "A creature you touch becomes invisible."},
    "Hold Person":      {"damage": "0",    "stat": "wisdom",       "description": "Choose a humanoid to be paralyzed for the duration."},
    "Banishment":       {"damage": "0",    "stat": "charisma",     "description": "You attempt to send a creature to another plane."},
    "Polymorph":        {"damage": "0",    "stat": "intelligence", "description": "You transform a creature into a new form."},
}

def roll_dice_notation(notation):
    """Roll dice from notation like '2d6', returns (total, individual_rolls)."""
    if notation == "0":
        return 0, []
    parts = notation.lower().split("d")
    count = int(parts[0])
    sides = int(parts[1])
    rolls = [random.randint(1, sides) for _ in range(count)]
    return sum(rolls), rolls

def get_stat_modifier(stat_value):
    """Calculate ability modifier: (stat - 10) // 2"""
    return (stat_value - 10) // 2

def save_state():
    with open(STATE_FILE, "w") as f:
        json.dump(game_state, f)

def load_state():
    if os.path.exists(STATE_FILE):
        try:
            with open(STATE_FILE, "r") as f:
                state = json.load(f)
                # Migration: rename roll_log to log
                if "roll_log" in state:
                    state["log"] = state.pop("roll_log")
                if "log" not in state:
                    state["log"] = []
                
                # Ensure every player has required fields
                for p in state.get("players", {}).values():
                    p.setdefault("availablePoints", 0)
                    p.setdefault("weapon", "")
                    p.setdefault("spells", [])
                    p.setdefault("inventoryWeapons", [])
                    p.setdefault("knownSpells", [])
                    
                return state
        except Exception as e:
            print(f"Error loading state: {e}")
    
    return {
        "players": {}, 
        "log": [{"id": str(uuid.uuid4()), "category": "system", "message": "Session initialized ⚔️"}]
    }

game_state = load_state()

def get_game_state():
    return {
        "type": "game_state",
        "players": list(game_state["players"].values()),
        "log": game_state.get("log", []),
    }

@app.websocket('/ws')
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    connections.append(websocket)
    
    await websocket.send_text(json.dumps(get_game_state()))
    
        
    try:
        while True:
            data = await websocket.receive_text()
            event = json.loads(data)
            
            if event["type"] == "get_state":
                await websocket.send_text(json.dumps(get_game_state()))
                continue

            elif event["type"] == "ping":
                # Heartbeat to keep connection alive on Render/Heroku
                continue

            elif event["type"] == "addnew":
                player_data = event["player"]
                player_id = str(uuid.uuid4())
                player_data["id"] = player_id
                
                # Ensure availablePoints exists and auto-set stats from template if missing
                player_data.setdefault("availablePoints", 0)
                p_class = player_data.get("playerClass", "Fighter")
                if p_class in CLASS_DEFAULTS:
                    template = CLASS_DEFAULTS[p_class]
                    for stat, val in template.items():
                        player_data.setdefault(stat, val)

                # Assign starter loadout
                loadout = CLASS_LOADOUTS.get(p_class, {"weapon": "Dagger", "spells": []})
                player_data.setdefault("weapon", loadout["weapon"])
                player_data.setdefault("spells", list(loadout["spells"]))
                player_data.setdefault("inventoryWeapons", [loadout["weapon"]])
                player_data.setdefault("knownSpells", list(loadout["spells"]))

                game_state["players"][player_id] = player_data
                p_name = player_data.get('name', 'Unknown')
                game_state.setdefault("log", []).append({
                    "id": str(uuid.uuid4()),
                    "category": "system",
                    "message": f"🎭 {p_name} joined as {p_class} with {loadout['weapon']}",
                    "playerid": player_id
                })
                save_state()
                print(f"Added player: {p_name} ({p_class})")
                
            elif event["type"] == "update":
                new_data = event["player"]
                pid = str(new_data.get("id"))
                if pid in game_state["players"]:
                    old_data = game_state["players"][pid]
                    p_name = old_data.get("name", "Unknown")
                    
                    # Protect level and availablePoints from being overwritten by general update
                    # (Unless it's our internal calculation below)
                    new_data["level"] = old_data.get("level", 1)
                    new_data["availablePoints"] = old_data.get("availablePoints", 0)

                    # Log significant changes
                    game_state.setdefault("log", [])
                    for key, cat in [("health", "hp_change"), ("mana", "mp_change"), ("gold", "gold_change")]:
                        if new_data.get(key) != old_data.get(key):
                            diff = new_data[key] - old_data[key]
                            sign = "+" if diff > 0 else ""
                            game_state["log"].append({
                                "id": str(uuid.uuid4()),
                                "category": cat,
                                "message": f"{p_name} {key} changed: {old_data[key]} -> {new_data[key]} ({sign}{diff})",
                                "playerid": pid
                            })

                    # Handle Automatic Leveling
                    try:
                        # Ensure we have integer values
                        xp = int(new_data.get("xp", 0))
                        lvl = int(old_data.get("level", 1))
                        
                        # Set current level/points from server truth
                        new_data["level"] = lvl
                        new_data["availablePoints"] = int(old_data.get("availablePoints", 0))

                        threshold = lvl * 10
                        while xp >= threshold:
                            if lvl >= 20:
                                break
                            lvl += 1
                            new_data["level"] = lvl
                            new_data["availablePoints"] += 1
                            new_data["proficiencyBonus"] = 2 + ((lvl - 1) // 4)
                            game_state["log"].append({
                                "id": str(uuid.uuid4()),
                                "category": "level_up",
                                "message": f"⬆️ {p_name} reached Level {lvl} and gained 1 stat point!",
                                "playerid": pid
                            })
                            print(f">>> AUTO LEVEL UP: {p_name} to Level {lvl}")
                            threshold = lvl * 10
                        
                        # Update XP in new_data
                        new_data["xp"] = xp
                        
                    except (ValueError, TypeError) as e:
                        print(f"Logging error during level calc: {e}")

                    game_state["players"][pid] = new_data
                    save_state()
                    print(f"Updated player: {p_name} (Level: {new_data['level']}, XP: {new_data['xp']})")

            elif event["type"] == "delete":
                pid = str(event.get("id"))
                if pid in game_state["players"]:
                    deleted = game_state["players"].pop(pid)
                    save_state()
                    print(f"Deleted player: {deleted.get('name', 'Unknown')}")

            elif event["type"] == "roll_dice":
                pid = str(event.get("playerid", "gm"))
                result = random.randint(1, 20)

                if pid == "gm":
                    player_name = "Game Master"
                else:
                    player_name = game_state["players"].get(pid, {}).get("name", "Unknown")

                suffix = ""
                if result == 20:
                    suffix = " 🎯 CRITICAL SUCCESS!"
                elif result == 1:
                    suffix = " 💀 CRITICAL FAILURE!"

                log_entry = {
                    "id": str(uuid.uuid4()),
                    "category": "dice",
                    "playerid": pid,
                    "playername": player_name,
                    "result": result,
                    "message": f"{player_name} rolled D20: {result}{suffix}",
                    "is_critical_success": result == 20,
                    "is_critical_failure": result == 1,
                }

                game_state.setdefault("log", []).append(log_entry)
                game_state["log"] = game_state["log"][-100:]  # Keep last 100
                save_state()
                print(f"🎲 {player_name} rolled D20: {result}{suffix}")

            elif event["type"] == "level_up":
                pid = str(event.get("playerid"))
                if pid in game_state["players"]:
                    p = game_state["players"][pid]
                    if p.get("level", 1) < 20:
                        p["level"] = p.get("level", 1) + 1
                        p["availablePoints"] = p.get("availablePoints", 0) + 1
                        p["proficiencyBonus"] = 2 + ((p["level"] - 1) // 4)
                        p_name = p.get("name", "Unknown")
                        
                        game_state["log"].append({
                            "id": str(uuid.uuid4()),
                            "category": "level_up",
                            "message": f"⬆️ {p_name} reached Level {p['level']} and gained 1 stat point",
                            "playerid": pid
                        })
                        save_state()
                        print(f"Level Up: {p_name} to {p['level']}")

            elif event["type"] == "allocate_stat":
                pid = str(event.get("playerid"))
                stat = str(event.get("stat", "")).lower()
                if pid in game_state["players"]:
                    p = game_state["players"][pid]
                    if p.get("availablePoints", 0) > 0 and stat in ["strength", "dexterity", "constitution", "intelligence", "wisdom", "charisma"]:
                        p[stat] = p.get(stat, 10) + 1
                        p["availablePoints"] -= 1
                        p_name = p.get("name", "Unknown")
                        abbr = stat[:3].upper()
                        
                        game_state["log"].append({
                            "id": str(uuid.uuid4()),
                            "category": "stat_alloc",
                            "message": f"📊 {p_name} increased {abbr} to {p[stat]}",
                            "playerid": pid
                        })
                        save_state()
                        print(f"Stat Allocated: {p_name} {abbr} (+1)")

            elif event["type"] == "grant_reward":
                pid = str(event.get("playerid"))
                reward_type = event.get("reward_type", "")
                item_name = event.get("name", "")
                if pid in game_state["players"] and item_name:
                    p = game_state["players"][pid]
                    p_name = p.get("name", "Unknown")
                    game_state.setdefault("log", [])

                    if reward_type == "spell":
                        spells = p.get("knownSpells", [])
                        if item_name not in spells:
                            spells.append(item_name)
                            p["knownSpells"] = spells
                            game_state["log"].append({
                                "id": str(uuid.uuid4()),
                                "category": "reward",
                                "message": f"⭐ {p_name} learned {item_name}",
                                "playerid": pid
                            })
                            print(f"Granted spell: {p_name} <- {item_name}")
                    elif reward_type == "weapon":
                        weapons = p.get("inventoryWeapons", [])
                        if item_name not in weapons:
                            weapons.append(item_name)
                            p["inventoryWeapons"] = weapons
                            game_state["log"].append({
                                "id": str(uuid.uuid4()),
                                "category": "reward",
                                "message": f"⚔️ {p_name} obtained {item_name}",
                                "playerid": pid
                            })
                            print(f"Granted weapon: {p_name} <- {item_name}")
                    save_state()

            elif event["type"] == "equip_weapon":
                pid = str(event.get("playerid"))
                weapon = event.get("weapon", "")
                if pid in game_state["players"]:
                    p = game_state["players"][pid]
                    if weapon in p.get("inventoryWeapons", []):
                        p["weapon"] = weapon
                        p_name = p.get("name", "Unknown")
                        game_state.setdefault("log", []).append({
                            "id": str(uuid.uuid4()),
                            "category": "equip",
                            "message": f"🛡️ {p_name} equipped {weapon}",
                            "playerid": pid
                        })
                        save_state()
                        print(f"Equipped: {p_name} -> {weapon}")

            elif event["type"] == "attack":
                pid = str(event.get("playerid"))
                if pid in game_state["players"]:
                    p = game_state["players"][pid]
                    p_name = p.get("name", "Unknown")
                    weapon_name = p.get("weapon", "Fists")
                    weapon_info = ALL_WEAPONS.get(weapon_name, {"damage": "1d4", "stat": "strength"})
                    
                    # Roll damage
                    total_roll, rolls = roll_dice_notation(weapon_info["damage"])
                    stat_val = p.get(weapon_info["stat"], 10)
                    modifier = get_stat_modifier(stat_val)
                    total_damage = max(0, total_roll + modifier)
                    stat_abbr = weapon_info["stat"][:3].upper()

                    game_state.setdefault("log", []).append({
                        "id": str(uuid.uuid4()),
                        "category": "attack",
                        "message": f"⚔️ {p_name} attacks with {weapon_name} → {total_damage} damage ({weapon_info['damage']}={total_roll} + {stat_abbr} {modifier:+d})",
                        "playerid": pid,
                        "damage": total_damage
                    })
                    save_state()
                    print(f"Attack: {p_name} with {weapon_name} -> {total_damage} damage")

            elif event["type"] == "cast_spell":
                pid = str(event.get("playerid"))
                spell_name = event.get("spell", "")
                if pid in game_state["players"] and spell_name:
                    p = game_state["players"][pid]
                    p_name = p.get("name", "Unknown")
                    spell_info = ALL_SPELLS.get(spell_name, {"damage": "0", "stat": "intelligence"})
                    is_healing = spell_info.get("healing", False)
                    damage_notation = spell_info["damage"]

                    if damage_notation == "0":
                        # Utility spell — no damage/healing roll
                        emoji = "✨"
                        game_state.setdefault("log", []).append({
                            "id": str(uuid.uuid4()),
                            "category": "spell",
                            "message": f"{emoji} {p_name} casts {spell_name}",
                            "playerid": pid,
                            "damage": 0
                        })
                    else:
                        total_roll, rolls = roll_dice_notation(damage_notation)
                        stat_val = p.get(spell_info["stat"], 10)
                        modifier = get_stat_modifier(stat_val)
                        total = max(0, total_roll + modifier)
                        stat_abbr = spell_info["stat"][:3].upper()

                        if is_healing:
                            emoji = "💚"
                            action = f"heals for {total}"
                            category = "heal"
                        else:
                            emoji = "✨"
                            action = f"{total} damage"
                            category = "spell"

                        game_state.setdefault("log", []).append({
                            "id": str(uuid.uuid4()),
                            "category": category,
                            "message": f"{emoji} {p_name} casts {spell_name} → {action} ({damage_notation}={total_roll} + {stat_abbr} {modifier:+d})",
                            "playerid": pid,
                            "damage": total
                        })
                    save_state()
                    print(f"Spell: {p_name} casts {spell_name}")

            elif event["type"] == "get_lists":
                await websocket.send_text(json.dumps({
                    "type": "item_lists",
                    "weapons": list(ALL_WEAPONS.keys()),
                    "spells": list(ALL_SPELLS.keys()),
                }))
                continue
            
            finaldata = json.dumps(get_game_state())
            
            for conn in connections:
                try:
                    await conn.send_text(finaldata)
                except Exception:
                    if conn in connections:
                        connections.remove(conn)
    except Exception as e:
        print("Error : ", e)
    finally:
        if websocket in connections:
            connections.remove(websocket)