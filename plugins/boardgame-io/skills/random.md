---
description: Implement randomness in boardgame.io games. Use when shuffling decks, rolling dice, drawing random cards, or implementing any random game mechanics.
---

# boardgame.io Randomness

boardgame.io provides built-in random functions that work seamlessly across clients in multiplayer.

## Why Use Framework Random

- **Deterministic**: Same seed produces same results across all clients
- **Synchronized**: All clients see the same random values
- **Testable**: Can seed for reproducible tests

## Basic Random Functions

### Random Number

```javascript
moves: {
  rollDice: ({ G, random }) => {
    // Random integer from 1-6
    G.diceValue = random.D6();

    // Random integer in range [1, n]
    G.d20 = random.Die(20);

    // Random float [0, 1)
    G.chance = random.Number();
  },
}
```

### Dice Functions

```javascript
moves: {
  rollDice: ({ G, random }) => {
    G.d4 = random.D4();   // 1-4
    G.d6 = random.D6();   // 1-6
    G.d8 = random.D8();   // 1-8
    G.d10 = random.D10(); // 1-10
    G.d12 = random.D12(); // 1-12
    G.d20 = random.D20(); // 1-20

    // Custom die
    G.d100 = random.Die(100); // 1-100

    // Multiple dice
    G.twoD6 = random.D6() + random.D6();
  },
}
```

### Shuffle

```javascript
moves: {
  shuffleDeck: ({ G, random }) => {
    G.deck = random.Shuffle(G.deck);
  },

  shuffleHand: ({ G, ctx, random }) => {
    G.hands[ctx.currentPlayer] = random.Shuffle(
      G.hands[ctx.currentPlayer]
    );
  },
}
```

### Random Selection

```javascript
moves: {
  drawRandomCard: ({ G, random }) => {
    // Draw random card without removing
    const randomCard = random.Shuffle(G.deck)[0];
    G.revealed = randomCard;
  },

  selectRandomPlayer: ({ ctx, random }) => {
    const players = [...ctx.playOrder];
    const shuffled = random.Shuffle(players);
    return shuffled[0];
  },
}
```

## Using Random in Setup

```javascript
export const CardGame = {
  setup: ({ random }) => {
    const deck = createDeck(); // [card1, card2, ...]
    return {
      deck: random.Shuffle(deck),
      hands: {},
      discard: [],
    };
  },
};

function createDeck() {
  const suits = ['hearts', 'diamonds', 'clubs', 'spades'];
  const values = ['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K'];
  const deck = [];

  for (const suit of suits) {
    for (const value of values) {
      deck.push({ suit, value });
    }
  }

  return deck;
}
```

## Seeded Random for Testing

```javascript
import { Client } from 'boardgame.io/client';

// Deterministic random for tests
const client = Client({
  game: MyGame,
  seed: 'my-test-seed',
});
client.start();

// Same seed = same random values
```

## Random Events

Use random to determine outcomes:

```javascript
moves: {
  attack: ({ G, ctx, random }) => {
    const roll = random.D20();
    const attackBonus = G.characters[ctx.currentPlayer].attack;

    if (roll + attackBonus >= G.enemy.defense) {
      // Hit!
      const damage = random.Die(8) + 2;
      G.enemy.hp -= damage;
      G.lastAttack = { hit: true, roll, damage };
    } else {
      // Miss
      G.lastAttack = { hit: false, roll };
    }
  },
}
```

## Weighted Random

Implement weighted random selection:

```javascript
moves: {
  drawLootCard: ({ G, random }) => {
    const lootTable = [
      { item: 'gold', weight: 50 },
      { item: 'gem', weight: 30 },
      { item: 'artifact', weight: 15 },
      { item: 'legendary', weight: 5 },
    ];

    // Calculate total weight
    const totalWeight = lootTable.reduce((sum, item) => sum + item.weight, 0);

    // Random value in range
    const roll = random.Number() * totalWeight;

    // Find item
    let cumulative = 0;
    for (const entry of lootTable) {
      cumulative += entry.weight;
      if (roll < cumulative) {
        G.drawnLoot = entry.item;
        break;
      }
    }
  },
}
```

## Random in Phases

```javascript
phases: {
  setup: {
    start: true,
    onBegin: ({ G, random }) => {
      // Shuffle and deal at phase start
      G.deck = random.Shuffle(G.deck);
    },
    next: 'play',
  },
}
```

## Complete Deck Game Example

```javascript
export const DeckGame = {
  setup: ({ ctx, random }) => {
    const deck = random.Shuffle(createDeck());
    const hands = {};

    // Deal 5 cards to each player
    for (let p = 0; p < ctx.numPlayers; p++) {
      hands[p] = [];
      for (let i = 0; i < 5; i++) {
        hands[p].push(deck.pop());
      }
    }

    return {
      deck,
      hands,
      discard: [],
      currentCard: null,
    };
  },

  moves: {
    drawCard: ({ G, ctx, random }) => {
      if (G.deck.length === 0) {
        // Reshuffle discard pile
        G.deck = random.Shuffle([...G.discard]);
        G.discard = [];
      }

      const card = G.deck.pop();
      G.hands[ctx.currentPlayer].push(card);
    },

    playCard: ({ G, ctx }, cardIndex) => {
      const hand = G.hands[ctx.currentPlayer];
      const card = hand.splice(cardIndex, 1)[0];
      G.currentCard = card;
    },

    discardCard: ({ G, ctx }, cardIndex) => {
      const hand = G.hands[ctx.currentPlayer];
      const card = hand.splice(cardIndex, 1)[0];
      G.discard.push(card);
    },
  },

  turn: {
    onBegin: ({ G, ctx, random }) => {
      // Draw a card at turn start
      if (G.deck.length > 0) {
        const card = G.deck.pop();
        G.hands[ctx.currentPlayer].push(card);
      }
    },
  },
};
```

## Documentation Reference

- [Randomness](https://boardgame.io/documentation/#/random) - Random guide
- [Testing](https://boardgame.io/documentation/#/testing) - Seeded testing
