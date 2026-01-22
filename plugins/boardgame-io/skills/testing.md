---
description: Test boardgame.io games with unit and integration tests. Use when writing tests for game logic, testing move validation, verifying win conditions, or testing multiplayer scenarios.
---

# boardgame.io Testing

Test your game logic without UI or networking complications.

## Basic Test Setup

Use the framework's test utilities to create isolated test clients:

```javascript
import { Client } from 'boardgame.io/client';
import { MyGame } from './Game';

describe('MyGame', () => {
  let client;

  beforeEach(() => {
    client = Client({ game: MyGame });
    client.start();
  });

  test('initial state', () => {
    const { G, ctx } = client.getState();
    expect(G.cells).toHaveLength(9);
    expect(ctx.currentPlayer).toBe('0');
  });
});
```

## Testing Moves

### Valid Moves

```javascript
test('clicking a cell fills it', () => {
  const client = Client({ game: TicTacToe });
  client.start();

  // Make a move
  client.moves.clickCell(0);

  const { G, ctx } = client.getState();
  expect(G.cells[0]).toBe('0');
  expect(ctx.currentPlayer).toBe('1'); // Turn changed
});
```

### Invalid Moves

```javascript
test('clicking filled cell is rejected', () => {
  const client = Client({ game: TicTacToe });
  client.start();

  // Fill cell 0
  client.moves.clickCell(0);
  const stateAfterFirst = client.getState();

  // Player 1 tries to click same cell
  client.moves.clickCell(0);
  const stateAfterSecond = client.getState();

  // State should not have changed
  expect(stateAfterSecond.G.cells[0]).toBe('0');
  expect(stateAfterSecond.ctx.currentPlayer).toBe('1');
});
```

## Testing with Multiple Players

```javascript
import { Local } from 'boardgame.io/multiplayer';

test('two players can play', () => {
  const spec = {
    game: TicTacToe,
    multiplayer: Local(),
  };

  const player0 = Client({ ...spec, playerID: '0' });
  const player1 = Client({ ...spec, playerID: '1' });

  player0.start();
  player1.start();

  // Player 0 moves
  player0.moves.clickCell(0);

  // Check both clients see the move
  expect(player0.getState().G.cells[0]).toBe('0');
  expect(player1.getState().G.cells[0]).toBe('0');

  // Player 1 moves
  player1.moves.clickCell(4);

  expect(player0.getState().G.cells[4]).toBe('1');
  expect(player1.getState().G.cells[4]).toBe('1');
});
```

## Testing Win Conditions

```javascript
test('detects winner', () => {
  const client = Client({ game: TicTacToe });
  client.start();

  // Player 0: 0, 1, 2 (top row)
  // Player 1: 3, 4
  client.moves.clickCell(0); // P0
  client.moves.clickCell(3); // P1
  client.moves.clickCell(1); // P0
  client.moves.clickCell(4); // P1
  client.moves.clickCell(2); // P0 wins

  const { ctx } = client.getState();
  expect(ctx.gameover).toEqual({ winner: '0' });
});

test('detects draw', () => {
  const client = Client({ game: TicTacToe });
  client.start();

  // Play to a draw
  // X O X
  // X O O
  // O X X
  [0, 1, 2, 4, 3, 5, 7, 6, 8].forEach((cell, i) => {
    client.moves.clickCell(cell);
  });

  const { ctx } = client.getState();
  expect(ctx.gameover).toEqual({ draw: true });
});
```

## Testing Phases

```javascript
test('phase transitions correctly', () => {
  const client = Client({ game: CardGame });
  client.start();

  const { ctx: initialCtx } = client.getState();
  expect(initialCtx.phase).toBe('deal');

  // Deal phase should auto-end and transition to bid
  // (assuming deal phase has endIf: () => true)
  const { ctx: afterDeal } = client.getState();
  expect(afterDeal.phase).toBe('bid');
});

test('manual phase transition', () => {
  const client = Client({ game: MyGame });
  client.start();

  client.moves.completeBidding();

  const { ctx } = client.getState();
  expect(ctx.phase).toBe('play');
});
```

## Testing Stages

```javascript
test('player enters correct stage', () => {
  const client = Client({ game: CombatGame });
  client.start();

  client.moves.startCombat();

  const { ctx } = client.getState();
  expect(ctx.activePlayers).toEqual({ '0': 'combat' });
});

test('simultaneous stage for all players', () => {
  const spec = {
    game: VotingGame,
    multiplayer: Local(),
  };

  const p0 = Client({ ...spec, playerID: '0' });
  const p1 = Client({ ...spec, playerID: '1' });
  p0.start();
  p1.start();

  // Both should be in voting stage
  expect(p0.getState().ctx.activePlayers).toEqual({
    '0': 'vote',
    '1': 'vote',
  });

  // Both vote
  p0.moves.castVote('yes');
  p1.moves.castVote('no');

  // Voting complete
  expect(p0.getState().G.votes).toEqual({ '0': 'yes', '1': 'no' });
});
```

## Testing AI

```javascript
import { MCTSBot, Step } from 'boardgame.io/ai';

test('AI makes valid moves', () => {
  const client = Client({
    game: TicTacToe,
    ai: MCTSBot,
  });
  client.start();

  // Let AI make a move
  Step(client);

  const { G } = client.getState();
  const filledCells = G.cells.filter(c => c !== null);
  expect(filledCells.length).toBe(1);
});

test('AI vs AI game completes', () => {
  const client = Client({
    game: TicTacToe,
    ai: MCTSBot,
  });
  client.start();

  // Run until game ends
  while (!client.getState().ctx.gameover) {
    Step(client);
  }

  expect(client.getState().ctx.gameover).toBeDefined();
});
```

## Testing Randomness

Use seeded random for deterministic tests:

```javascript
test('random card draw is deterministic with seed', () => {
  // Create client with specific seed
  const client = Client({
    game: CardGame,
    seed: 'test-seed-123',
  });
  client.start();

  client.moves.drawCard();

  const { G } = client.getState();
  // Should always draw the same card with this seed
  expect(G.hand[0]).toEqual({ suit: 'hearts', value: 7 });
});
```

## Testing Events

```javascript
test('endTurn event works', () => {
  const client = Client({ game: TicTacToe });
  client.start();

  expect(client.getState().ctx.currentPlayer).toBe('0');

  client.moves.clickCell(0);

  expect(client.getState().ctx.currentPlayer).toBe('1');
  expect(client.getState().ctx.turn).toBe(2);
});
```

## Test Utilities

### Custom Initial State

```javascript
test('with custom initial state', () => {
  const client = Client({
    game: TicTacToe,
    initialState: {
      G: { cells: ['0', null, '0', null, '1', null, null, '1', null] },
      ctx: { currentPlayer: '0', turn: 5 },
    },
  });
  client.start();

  // Test mid-game scenario
  client.moves.clickCell(1);
  expect(client.getState().ctx.gameover).toEqual({ winner: '0' });
});
```

### Overriding Player Count

```javascript
test('works with 4 players', () => {
  const client = Client({
    game: MyGame,
    numPlayers: 4,
  });
  client.start();

  const { ctx } = client.getState();
  expect(ctx.numPlayers).toBe(4);
  expect(ctx.playOrder).toEqual(['0', '1', '2', '3']);
});
```

## Documentation Reference

- [Testing](https://boardgame.io/documentation/#/testing) - Full testing guide
- [Debugging](https://boardgame.io/documentation/#/debugging) - Debug tools
- [Randomness](https://boardgame.io/documentation/#/random) - Seeded random
