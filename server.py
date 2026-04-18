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
    "Custom":    {"strength":10,"dexterity":10,"constitution":10,"intelligence":10,"wisdom":10,"charisma":10}
}

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
                
                # Ensure every player has availablePoints
                for p in state.get("players", {}).values():
                    p.setdefault("availablePoints", 0)
                    
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
                p_class = player_data.get("playerClass", "Custom")
                if p_class in CLASS_DEFAULTS:
                    template = CLASS_DEFAULTS[p_class]
                    for stat, val in template.items():
                        player_data.setdefault(stat, val)

                game_state["players"][player_id] = player_data
                save_state()
                print(f"Added player: {player_data.get('name', 'Unknown')}")
                
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
                            lvl += 1
                            new_data["level"] = lvl
                            new_data["availablePoints"] += 2
                            game_state["log"].append({
                                "id": str(uuid.uuid4()),
                                "category": "level_up",
                                "message": f"⬆️ {p_name} reached Level {lvl} and gained 2 stat points!",
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
                    p["level"] = p.get("level", 1) + 1
                    p["availablePoints"] = p.get("availablePoints", 0) + 2
                    p_name = p.get("name", "Unknown")
                    
                    game_state["log"].append({
                        "id": str(uuid.uuid4()),
                        "category": "level_up",
                        "message": f"⬆️ {p_name} reached Level {p['level']} and gained 2 stat points",
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