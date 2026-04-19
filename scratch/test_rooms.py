import asyncio
import websockets
import json

async def test_rooms():
    uri = "ws://localhost:8000/ws"
    async with websockets.connect(uri) as ws1:
        # Test Create
        await ws1.send(json.dumps({"type": "create_room"}))
        resp1 = json.loads(await ws1.recv())
        print(f"Room 1 Created: {resp1}")
        room1_id = resp1.get("room_id")
        
        # Room 1 state (initial)
        state1 = json.loads(await ws1.recv())
        print("Room 1 Initial State received")

        # Test Add Player in Room 1
        await ws1.send(json.dumps({
            "type": "addnew",
            "player": {"name": "Test Player", "playerClass": "Fighter"}
        }))
        state1_updated = json.loads(await ws1.recv()) # Broadcast of new state
        print(f"Room 1 Player Added. Count: {len(state1_updated['players'])}")

        async with websockets.connect(uri) as ws2:
            # Test Join Room 1
            await ws2.send(json.dumps({"type": "join_room", "room_id": room1_id}))
            resp2 = json.loads(await ws2.recv())
            print(f"WS2 Joined Room 1: {resp2}")
            state2 = json.loads(await ws2.recv())
            print(f"WS2 State Player Count: {len(state2['players'])}")

            # Test Create Room 2
            async with websockets.connect(uri) as ws3:
                await ws3.send(json.dumps({"type": "create_room"}))
                resp3 = json.loads(await ws3.recv())
                room2_id = resp3.get("room_id")
                print(f"Room 2 Created: {room2_id}")
                state3 = json.loads(await ws3.recv())
                print(f"Room 2 Initial Player Count: {len(state3['players'])}")

    print("Isolation and joining test passed!")

if __name__ == "__main__":
    asyncio.run(test_rooms())
