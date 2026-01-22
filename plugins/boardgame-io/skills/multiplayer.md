---
description: Set up multiplayer games with boardgame.io. Use when adding online multiplayer, configuring a game server, setting up player matching, or implementing local pass-and-play.
---

# boardgame.io Multiplayer

Transform single-player games into multiplayer using boardgame.io's networking layer.

## Architecture Overview

boardgame.io uses a **master-client model**:

- Clients emit moves to the game master
- Master computes new state and broadcasts to all clients
- Clients use "optimistic updates" for lag-free play
- Master is the authoritative state source

## Local Multiplayer (Pass-and-Play)

For local testing or pass-and-play on the same device:

```javascript
import { Client } from 'boardgame.io/client';
import { Local } from 'boardgame.io/multiplayer';
import { MyGame } from './Game';

// Create two local clients
const client0 = Client({
  game: MyGame,
  multiplayer: Local(),
  playerID: '0',
});

const client1 = Client({
  game: MyGame,
  multiplayer: Local(),
  playerID: '1',
});

client0.start();
client1.start();
```

### With State Persistence

Persist local game state in browser storage:

```javascript
const client = Client({
  game: MyGame,
  multiplayer: Local({ persist: true }),
  playerID: '0',
});
```

## Remote Multiplayer (Server)

### Step 1: Set Up the Server

Create `server.js`:

```javascript
import { Server, Origins } from 'boardgame.io/server';
import { MyGame } from './Game';

const server = Server({
  games: [MyGame],
  origins: [Origins.LOCALHOST],
});

server.run(8000);
```

### Step 2: Connect Clients

```javascript
import { Client } from 'boardgame.io/client';
import { SocketIO } from 'boardgame.io/multiplayer';
import { MyGame } from './Game';

const client = Client({
  game: MyGame,
  multiplayer: SocketIO({ server: 'localhost:8000' }),
  playerID: '0',
  matchID: 'game-room-1',
});

client.start();
```

### React Client

```jsx
import { Client } from 'boardgame.io/react';
import { SocketIO } from 'boardgame.io/multiplayer';
import { MyGame } from './Game';
import { Board } from './Board';

const App = Client({
  game: MyGame,
  board: Board,
  multiplayer: SocketIO({ server: 'localhost:8000' }),
});

// In your component:
<App playerID="0" matchID="game-room-1" />
```

## Player IDs and Match IDs

### Player IDs

- Each client needs a `playerID` to make moves
- Without `playerID`, client becomes a spectator
- Players are strings: `'0'`, `'1'`, etc.

```javascript
// Player 0's client
const player0 = Client({
  game: MyGame,
  multiplayer: SocketIO({ server: 'localhost:8000' }),
  playerID: '0',
  matchID: 'my-match',
});

// Spectator (no playerID)
const spectator = Client({
  game: MyGame,
  multiplayer: SocketIO({ server: 'localhost:8000' }),
  matchID: 'my-match',
});
```

### Match IDs

Group players into specific game instances:

```javascript
// Both players join the same match
const player0 = Client({
  game: MyGame,
  multiplayer: SocketIO({ server: 'localhost:8000' }),
  playerID: '0',
  matchID: 'room-abc123',
});

const player1 = Client({
  game: MyGame,
  multiplayer: SocketIO({ server: 'localhost:8000' }),
  playerID: '1',
  matchID: 'room-abc123',
});
```

## Server Configuration

### CORS and Origins

```javascript
import { Server, Origins } from 'boardgame.io/server';

const server = Server({
  games: [MyGame],
  origins: [
    Origins.LOCALHOST,           // localhost development
    'https://mygame.example.com', // production domain
  ],
});
```

### Custom Port

```javascript
server.run({ port: 8000 });
```

### With Express Integration

```javascript
import express from 'express';
import { Server } from 'boardgame.io/server';

const app = express();
const server = Server({ games: [MyGame] });

// Add custom routes
app.get('/health', (req, res) => res.send('OK'));

// Integrate boardgame.io
server.run({ port: 8000, callback: () => {
  console.log('Server running at http://localhost:8000');
}});
```

## Lobby System

Use the built-in lobby for match management:

### Server with Lobby

```javascript
import { Server, Origins } from 'boardgame.io/server';
import { MyGame } from './Game';

const server = Server({
  games: [MyGame],
  origins: [Origins.LOCALHOST],
});

server.run(8000);
// Lobby API available at http://localhost:8000/games
```

### Lobby API Endpoints

```javascript
// Create a new match
POST /games/{gameName}/create
Body: { numPlayers: 2 }
Response: { matchID: 'abc123' }

// Join a match
POST /games/{gameName}/{matchID}/join
Body: { playerID: '0', playerName: 'Alice' }
Response: { playerCredentials: 'secret-token' }

// List matches
GET /games/{gameName}
Response: { matches: [...] }

// Leave a match
POST /games/{gameName}/{matchID}/leave
Body: { playerID: '0', credentials: 'secret-token' }
```

### Client with Credentials

```javascript
const client = Client({
  game: MyGame,
  multiplayer: SocketIO({ server: 'localhost:8000' }),
  playerID: '0',
  matchID: 'abc123',
  credentials: 'secret-token', // From join response
});
```

## Documentation Reference

- [Multiplayer](https://boardgame.io/documentation/#/multiplayer) - Full multiplayer guide
- [Server API](https://boardgame.io/documentation/#/api/Server) - Server configuration
- [Lobby API](https://boardgame.io/documentation/#/api/Lobby) - Lobby endpoints
