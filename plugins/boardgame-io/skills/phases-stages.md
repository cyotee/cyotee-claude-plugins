---
description: Implement complex game flow with phases and stages in boardgame.io. Use when creating multi-phase games, bidding rounds, draft phases, simultaneous actions, or games where different players have different available moves.
---

# boardgame.io Phases and Stages

Control complex game flow using the framework's hierarchical structure:

- **Phases** - Override game configuration for specific game periods
- **Turns** - Player-centric segments with one or more moves
- **Stages** - Subdivide turns for individual player states

## Phases

Phases define different periods of the game with unique configurations.

### Basic Phase Definition

```javascript
export const MyGame = {
  setup: () => ({
    deck: [],
    hands: {},
    board: [],
  }),

  phases: {
    draw: {
      start: true, // This phase starts the game
      moves: {
        drawCard: ({ G, ctx }) => {
          const card = G.deck.pop();
          G.hands[ctx.currentPlayer].push(card);
        },
      },
      endIf: ({ G }) => G.deck.length === 0,
      next: 'play',
    },

    play: {
      moves: {
        playCard: ({ G, ctx }, cardIndex) => {
          const card = G.hands[ctx.currentPlayer].splice(cardIndex, 1)[0];
          G.board.push(card);
        },
      },
      endIf: ({ G }) => G.hands.every(hand => hand.length === 0),
    },
  },
};
```

### Phase Transitions

```javascript
phases: {
  setup: {
    start: true,
    next: 'bidding',
    onEnd: ({ G }) => {
      // Clean up setup phase
      G.setupComplete = true;
    },
  },

  bidding: {
    onBegin: ({ G }) => {
      G.currentBid = 0;
    },
    next: 'playing',
  },

  playing: {
    // Final phase, no 'next'
  },
}
```

### Event-Triggered Transitions

```javascript
moves: {
  passBid: ({ G, ctx, events }) => {
    G.passed[ctx.currentPlayer] = true;

    // Check if bidding should end
    if (allPlayersPassed(G)) {
      events.endPhase();
    }
  },
}
```

### Phase Hooks

```javascript
phases: {
  draft: {
    onBegin: ({ G, ctx }) => {
      // Called when phase begins
      G.draftRound = 1;
    },
    onEnd: ({ G }) => {
      // Called when phase ends
      G.draftComplete = true;
    },
  },
}
```

## Stages

Stages allow different players to be in different states within the same turn.

### Basic Stage Definition

```javascript
export const MyGame = {
  turn: {
    stages: {
      selectAction: {
        moves: {
          chooseAttack: ({ G, events }) => {
            G.action = 'attack';
            events.endStage();
          },
          chooseDefend: ({ G, events }) => {
            G.action = 'defend';
            events.endStage();
          },
        },
      },
      executeAction: {
        moves: {
          performAction: ({ G, events }) => {
            // Execute the chosen action
            events.endTurn();
          },
        },
      },
    },
  },
};
```

### Activating Stages

```javascript
moves: {
  startCombat: ({ events }) => {
    // Move current player to a stage
    events.setStage('combat');
  },

  attackPlayer: ({ events }, targetPlayerID) => {
    // Move another player to a stage
    events.setStage({
      stage: 'defend',
      moveLimit: 1,
    });
  },
}
```

### Active Players Configuration

Control which players can act:

```javascript
turn: {
  activePlayers: {
    currentPlayer: 'selectCard',
    others: 'wait',
  },

  stages: {
    selectCard: {
      moves: {
        pickCard: ({ G, ctx, events }, cardId) => {
          G.selections[ctx.currentPlayer] = cardId;
          events.endStage();
        },
      },
    },
    wait: {
      moves: {}, // No moves available
    },
  },
}
```

### Simultaneous Action (All Players)

```javascript
turn: {
  activePlayers: {
    all: 'vote',
    minMoves: 1,
    maxMoves: 1,
  },

  stages: {
    vote: {
      moves: {
        castVote: ({ G, playerID, events }, choice) => {
          G.votes[playerID] = choice;
          events.endStage();
        },
      },
    },
  },

  endIf: ({ ctx }) => {
    // End turn when all players have voted
    return ctx.activePlayers === null;
  },
}
```

## Turn Order

Customize how turns progress through players.

### Built-in Turn Orders

```javascript
import { TurnOrder } from 'boardgame.io/core';

turn: {
  order: TurnOrder.DEFAULT,      // Sequential: 0, 1, 2, ...
  // or
  order: TurnOrder.RESET,        // Restart from first player each round
  // or
  order: TurnOrder.CONTINUE,     // Remember last player across phases
  // or
  order: TurnOrder.ONCE,         // Each player acts exactly once
}
```

### Custom Turn Order

```javascript
turn: {
  order: {
    first: ({ G }) => G.firstPlayer,
    next: ({ G, ctx }) => {
      // Skip players who have folded
      let next = (ctx.playOrderPos + 1) % ctx.numPlayers;
      while (G.folded[ctx.playOrder[next]]) {
        next = (next + 1) % ctx.numPlayers;
        if (next === ctx.playOrderPos) return undefined; // No valid players
      }
      return next;
    },
  },
}
```

### Move Limits

```javascript
turn: {
  minMoves: 1,      // Must make at least 1 move
  maxMoves: 3,      // Turn auto-ends after 3 moves
}
```

## Complete Example: Card Game with Phases and Stages

```javascript
export const CardGame = {
  setup: ({ ctx }) => ({
    deck: createDeck(),
    hands: Array(ctx.numPlayers).fill([]),
    played: [],
    bids: {},
    currentBid: 0,
  }),

  phases: {
    deal: {
      start: true,
      onBegin: ({ G, ctx }) => {
        // Deal cards to all players
        for (let i = 0; i < 5; i++) {
          for (let p = 0; p < ctx.numPlayers; p++) {
            G.hands[p].push(G.deck.pop());
          }
        }
      },
      endIf: () => true, // Immediately end after dealing
      next: 'bid',
    },

    bid: {
      turn: {
        activePlayers: {
          all: 'bidding',
        },
        stages: {
          bidding: {
            moves: {
              placeBid: ({ G, playerID, events }, amount) => {
                if (amount > G.currentBid) {
                  G.bids[playerID] = amount;
                  G.currentBid = amount;
                }
                events.endStage();
              },
              pass: ({ G, playerID, events }) => {
                G.bids[playerID] = -1; // Passed
                events.endStage();
              },
            },
          },
        },
        endIf: ({ ctx }) => ctx.activePlayers === null,
      },
      endIf: ({ G, ctx }) => {
        // End bidding when only one player remains
        const activeBidders = Object.entries(G.bids)
          .filter(([_, bid]) => bid !== -1).length;
        return activeBidders <= 1;
      },
      next: 'play',
    },

    play: {
      moves: {
        playCard: ({ G, ctx, events }, cardIndex) => {
          const card = G.hands[ctx.currentPlayer].splice(cardIndex, 1)[0];
          G.played.push({ player: ctx.currentPlayer, card });
          events.endTurn();
        },
      },
      endIf: ({ G }) => G.hands.every(h => h.length === 0),
    },
  },
};
```

## Documentation Reference

- [Phases](https://boardgame.io/documentation/#/phases) - Phase guide
- [Stages](https://boardgame.io/documentation/#/stages) - Stage guide
- [Turn Order](https://boardgame.io/documentation/#/turn-order) - Turn customization
- [Events](https://boardgame.io/documentation/#/events) - Framework events
