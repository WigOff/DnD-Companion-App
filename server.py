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

def save_state():
    with open(STATE_FILE, "w") as f:
        json.dump(game_state, f)

def load_state():
    if os.path.exists(STATE_FILE):
        with open(STATE_FILE, "r") as f:
            state = json.load(f)
            state.setdefault("roll_log", [])  # Ensure roll_log exists
            return state
    return {"players": {}, "roll_log": []}

game_state = load_state()

def get_game_state():
    return {
        "type": "game_state",
        "players": list(game_state["players"].values()),
        "roll_log": game_state.get("roll_log", []),
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

            elif event["type"] == "addnew":
                player_data = event["player"]
                player_id = str(uuid.uuid4())
                player_data["id"] = player_id # Override with server-side ID
                game_state["players"][player_id] = player_data
                save_state()
                print(f"Added player: {player_data.get('name', 'Unknown')}")
                
            elif event["type"] == "update":
                player_data = event["player"]
                pid = str(player_data.get("id"))
                if pid in game_state["players"]:
                    game_state["players"][pid] = player_data
                    save_state()
                    print(f"Updated player: {player_data.get('name', 'Unknown')}")

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
                    "playerid": pid,
                    "playername": player_name,
                    "result": result,
                    "message": f"{player_name} rolled D20: {result}{suffix}",
                    "is_critical_success": result == 20,
                    "is_critical_failure": result == 1,
                }

                game_state.setdefault("roll_log", []).append(log_entry)
                game_state["roll_log"] = game_state["roll_log"][-50:]  # Keep last 50
                save_state()
                print(f"🎲 {player_name} rolled D20: {result}{suffix}")
            
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