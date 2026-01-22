---
description: Define a boardgame.io game with setup, moves, and victory conditions. Use when creating a new game, setting up initial state, defining player moves, or adding win conditions.
---

# boardgame.io Game Definition

Define games using the core boardgame.io Game object pattern.

## Core State Concepts

boardgame.io maintains two state objects:

- **`G`** - Your game state (JSON-serializable object you manage)
- **`ctx`** - Read-only metadata managed by the framework (turn info, player data)

## Basic Game Structure

```javascript
import { INVALID_MOVE } from 'boardgame.io/core';

export const MyGame = {
  name: 'my-game',

  // Initialize game state
  setup: () => ({
    cells: Array(9).fill(null),
    score: { 0: 0, 1: 0 },
  }),

  // Define player moves
  moves: {
    clickCell: ({ G, ctx }, id) => {
      if (G.cells[id] !== null) {
        return INVALID_MOVE;
      }
      G.cells[id] = ctx.currentPlayer;
    },

    incrementScore: ({ G, ctx }) => {
      G.score[ctx.currentPlayer]++;
    },
  },

  // Victory conditions
  endIf: ({ G, ctx }) => {
    if (IsVictory(G.cells)) {
      return { winner: ctx.currentPlayer };
    }
    if (IsDraw(G.cells)) {
      return { draw: true };
    }
  },

  // Turn configuration
  turn: {
    minMoves: 1,
    maxMoves: 1,
  },
};
```

## Move Parameters

Moves receive a context object and optional arguments:

```javascript
moves: {
  movePiece: ({ G, ctx, playerID, events }, from, to) => {
    // G - game state (mutable)
    // ctx - framework metadata (read-only)
    // playerID - ID of player making the move
    // events - trigger events like endTurn(), endPhase()

    G.board[to] = G.board[from];
    G.board[from] = null;
  },
}
```

## Invalid Moves

Return `INVALID_MOVE` to reject illegal actions:

```javascript
import { INVALID_MOVE } from 'boardgame.io/core';

moves: {
  playCard: ({ G, ctx }, cardIndex) => {
    const hand = G.hands[ctx.currentPlayer];

    if (cardIndex < 0 || cardIndex >= hand.length) {
      return INVALID_MOVE;
    }

    const card = hand.splice(cardIndex, 1)[0];
    G.played.push(card);
  },
}
```

## Setup with Player Count

Access player count during setup:

```javascript
setup: ({ ctx }) => ({
  hands: Array(ctx.numPlayers).fill(null).map(() => []),
  deck: shuffleDeck(createDeck()),
  currentCard: null,
}),
```

## End Conditions

Define when the game ends:

```javascript
endIf: ({ G, ctx }) => {
  // Check for winner
  for (let player of ctx.playOrder) {
    if (G.score[player] >= 10) {
      return { winner: player };
    }
  }

  // Check for draw
  if (G.deck.length === 0 && G.hands.every(h => h.length === 0)) {
    return { draw: true };
  }

  // Return undefined to continue playing
},
```

## AI Integration

Enable AI players with move enumeration:

```javascript
ai: {
  enumerate: (G, ctx) => {
    const moves = [];

    G.cells.forEach((cell, idx) => {
      if (cell === null) {
        moves.push({ move: 'clickCell', args: [idx] });
      }
    });

    return moves;
  },
},
```

## Documentation Reference

- [Concepts](https://boardgame.io/documentation/#/concepts) - Core framework concepts
- [Tutorial](https://boardgame.io/documentation/#/tutorial) - Step-by-step game creation
- [Game API](https://boardgame.io/documentation/#/api/Game) - Complete Game object reference
