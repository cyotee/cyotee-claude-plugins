---
description: Use boardgame.io framework events to control game flow. Use when ending turns, ending phases, triggering game over, or implementing undo/redo functionality.
---

# boardgame.io Events

Events are framework-provided functions that control game flow and manage `ctx`.

## Event Types

### endTurn

End the current player's turn:

```javascript
moves: {
  finishMove: ({ G, events }) => {
    // Do something
    events.endTurn();
  },

  // Pass turn to specific player
  selectNextPlayer: ({ events }, nextPlayerID) => {
    events.endTurn({ next: nextPlayerID });
  },
}
```

### endPhase

Transition to the next phase:

```javascript
moves: {
  completeBidding: ({ G, events }) => {
    if (allPlayersBid(G)) {
      events.endPhase();
    }
  },

  // Move to specific phase
  skipToPlay: ({ events }) => {
    events.setPhase('play');
  },
}
```

### endGame

End the game with a result:

```javascript
moves: {
  resign: ({ ctx, events }) => {
    // Current player resigns, other player wins
    const winner = ctx.currentPlayer === '0' ? '1' : '0';
    events.endGame({ winner });
  },

  declareDraw: ({ events }) => {
    events.endGame({ draw: true });
  },
}
```

### setStage

Move players between stages:

```javascript
moves: {
  startCombat: ({ events }) => {
    events.setStage('combat');
  },

  // Move other player to stage
  attack: ({ events }, targetPlayer) => {
    events.setStage('respond');
    events.setActivePlayers({
      value: {
        [targetPlayer]: 'defend',
      },
    });
  },
}
```

### endStage

Exit the current stage:

```javascript
moves: {
  finishSelection: ({ events }) => {
    events.endStage();
  },
}
```

### setActivePlayers

Configure which players can act:

```javascript
moves: {
  callVote: ({ events }) => {
    events.setActivePlayers({
      all: 'voting',
      minMoves: 1,
      maxMoves: 1,
    });
  },

  // Custom active players
  selectDefenders: ({ events }, playerIDs) => {
    const value = {};
    playerIDs.forEach(id => {
      value[id] = 'defend';
    });
    events.setActivePlayers({ value });
  },
}
```

## Accessing Events

Events are accessible from the move context:

```javascript
moves: {
  myMove: ({ G, ctx, events, playerID }) => {
    // events contains all event functions
    events.endTurn();
    events.endPhase();
    events.endGame({ winner: playerID });
  },
}
```

## Automatic Turn Ending

Configure turns to end automatically:

```javascript
turn: {
  minMoves: 1,
  maxMoves: 1, // Auto-ends after 1 move
}
```

```javascript
turn: {
  // End turn after specific move
  endIf: ({ G, ctx }) => {
    return G.actionTaken;
  },
}
```

## Undo/Redo

boardgame.io supports undo/redo by default.

### Client-Side Undo

```javascript
const client = Client({ game: MyGame });
client.start();

client.moves.clickCell(0);
client.undo(); // Reverts the move
client.redo(); // Re-applies the move
```

### Disable Undo for Specific Moves

```javascript
moves: {
  // Can be undone
  placePiece: ({ G }, position) => {
    G.board[position] = 'X';
  },

  // Cannot be undone
  revealCard: {
    move: ({ G }) => {
      G.revealed = true;
    },
    undoable: false,
  },
}
```

### Disable All Undo

```javascript
export const MyGame = {
  disableUndo: true,
  // ...
};
```

### Undo in Multiplayer

By default, undo only works in single-player or local multiplayer:

```javascript
export const MyGame = {
  // Allow undo in online multiplayer
  undoOnMultiplayer: true,
};
```

## Event Hooks

React to events in your game:

```javascript
export const MyGame = {
  turn: {
    onBegin: ({ G, ctx, events }) => {
      // Called at the start of each turn
      G.turnStartTime = Date.now();
    },
    onEnd: ({ G, ctx }) => {
      // Called at the end of each turn
      G.lastTurnDuration = Date.now() - G.turnStartTime;
    },
  },

  phases: {
    combat: {
      onBegin: ({ G }) => {
        G.combatRound = 1;
      },
      onEnd: ({ G }) => {
        G.combatComplete = true;
      },
    },
  },
};
```

## Event Order

Events are processed in order:

1. Move executes and modifies G
2. Move validation runs
3. Turn-level endIf checks
4. Phase-level endIf checks
5. Game-level endIf checks
6. Hooks fire (onEnd, onBegin)

## Complete Example

```javascript
export const CardGame = {
  phases: {
    draw: {
      start: true,
      turn: {
        onBegin: ({ G, ctx }) => {
          // Draw a card at turn start
          const card = G.deck.pop();
          G.hands[ctx.currentPlayer].push(card);
        },
      },
      moves: {
        endDrawPhase: ({ events }) => {
          events.endPhase();
        },
      },
      next: 'play',
    },

    play: {
      moves: {
        playCard: ({ G, ctx, events }, cardIndex) => {
          const hand = G.hands[ctx.currentPlayer];
          const card = hand.splice(cardIndex, 1)[0];
          G.played.push(card);

          // Check win condition
          if (G.played.length >= 5) {
            events.endGame({ winner: ctx.currentPlayer });
          } else {
            events.endTurn();
          }
        },

        pass: ({ events }) => {
          events.endTurn();
        },
      },
    },
  },
};
```

## Documentation Reference

- [Events](https://boardgame.io/documentation/#/events) - Event guide
- [Undo/Redo](https://boardgame.io/documentation/#/undo) - Undo guide
- [Phases](https://boardgame.io/documentation/#/phases) - Phase transitions
