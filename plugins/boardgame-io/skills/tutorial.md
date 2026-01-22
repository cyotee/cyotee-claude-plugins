---
description: Create a complete boardgame.io game from scratch. Use when starting a new project, learning the framework, or building a tic-tac-toe style game.
---

# boardgame.io Tutorial - Building Tic-Tac-Toe

Complete walkthrough for creating a boardgame.io game with React or plain JavaScript.

## Project Setup

### Plain JavaScript

```bash
mkdir my-game && cd my-game
npm init -y
npm install boardgame.io parcel-bundler
```

### React

```bash
npx create-react-app my-game
cd my-game
npm install boardgame.io
```

## Project Structure

```
my-game/
├── index.html
├── src/
│   ├── Game.js      # Game logic
│   └── App.js       # Client/UI
└── package.json
```

## Step 1: Define the Game

Create `src/Game.js`:

```javascript
import { INVALID_MOVE } from 'boardgame.io/core';

export const TicTacToe = {
  name: 'tic-tac-toe',

  setup: () => ({ cells: Array(9).fill(null) }),

  moves: {
    clickCell: ({ G, ctx }, id) => {
      if (G.cells[id] !== null) {
        return INVALID_MOVE;
      }
      G.cells[id] = ctx.currentPlayer;
    },
  },

  turn: {
    minMoves: 1,
    maxMoves: 1,
  },

  endIf: ({ G, ctx }) => {
    if (IsVictory(G.cells)) {
      return { winner: ctx.currentPlayer };
    }
    if (G.cells.every(cell => cell !== null)) {
      return { draw: true };
    }
  },
};

// Helper function to check for victory
function IsVictory(cells) {
  const lines = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8], // rows
    [0, 3, 6], [1, 4, 7], [2, 5, 8], // columns
    [0, 4, 8], [2, 4, 6],            // diagonals
  ];

  for (const [a, b, c] of lines) {
    if (cells[a] && cells[a] === cells[b] && cells[a] === cells[c]) {
      return true;
    }
  }
  return false;
}
```

## Step 2: Create the Client

### Plain JavaScript Client

Create `src/App.js`:

```javascript
import { Client } from 'boardgame.io/client';
import { TicTacToe } from './Game';

class TicTacToeClient {
  constructor(rootElement) {
    this.client = Client({ game: TicTacToe });
    this.client.start();
    this.rootElement = rootElement;
    this.createBoard();
    this.attachListeners();
    this.client.subscribe(state => this.update(state));
  }

  createBoard() {
    const rows = [];
    for (let i = 0; i < 3; i++) {
      const cells = [];
      for (let j = 0; j < 3; j++) {
        const id = 3 * i + j;
        cells.push(`<td class="cell" data-id="${id}"></td>`);
      }
      rows.push(`<tr>${cells.join('')}</tr>`);
    }

    this.rootElement.innerHTML = `
      <table>${rows.join('')}</table>
      <p class="winner"></p>
    `;
  }

  attachListeners() {
    const handleClick = event => {
      const id = parseInt(event.target.dataset.id);
      this.client.moves.clickCell(id);
    };

    const cells = this.rootElement.querySelectorAll('.cell');
    cells.forEach(cell => cell.addEventListener('click', handleClick));
  }

  update(state) {
    if (!state) return;

    const cells = this.rootElement.querySelectorAll('.cell');
    cells.forEach(cell => {
      const id = parseInt(cell.dataset.id);
      const value = state.G.cells[id];
      cell.textContent = value === '0' ? 'X' : value === '1' ? 'O' : '';
    });

    const winner = this.rootElement.querySelector('.winner');
    if (state.ctx.gameover) {
      winner.textContent = state.ctx.gameover.winner
        ? `Winner: Player ${state.ctx.gameover.winner}`
        : 'Draw!';
    }
  }
}

const appElement = document.getElementById('app');
new TicTacToeClient(appElement);
```

### React Client

Create `src/App.js`:

```jsx
import React from 'react';
import { Client } from 'boardgame.io/react';
import { TicTacToe } from './Game';

function TicTacToeBoard({ ctx, G, moves }) {
  const onClick = (id) => moves.clickCell(id);

  let winner = '';
  if (ctx.gameover) {
    winner = ctx.gameover.winner
      ? `Winner: Player ${ctx.gameover.winner}`
      : 'Draw!';
  }

  const cellStyle = {
    width: '50px',
    height: '50px',
    border: '1px solid #555',
    lineHeight: '50px',
    textAlign: 'center',
    cursor: 'pointer',
    fontSize: '24px',
  };

  return (
    <div>
      <table>
        <tbody>
          {[0, 1, 2].map(row => (
            <tr key={row}>
              {[0, 1, 2].map(col => {
                const id = 3 * row + col;
                return (
                  <td key={id} style={cellStyle} onClick={() => onClick(id)}>
                    {G.cells[id] === '0' ? 'X' : G.cells[id] === '1' ? 'O' : ''}
                  </td>
                );
              })}
            </tr>
          ))}
        </tbody>
      </table>
      <p>{winner}</p>
      <p>Current Player: {ctx.currentPlayer}</p>
    </div>
  );
}

const App = Client({
  game: TicTacToe,
  board: TicTacToeBoard,
});

export default App;
```

## Step 3: Create HTML Entry Point

Create `index.html`:

```html
<!DOCTYPE html>
<html>
<head>
  <title>Tic-Tac-Toe</title>
  <style>
    .cell {
      width: 50px;
      height: 50px;
      border: 1px solid #555;
      text-align: center;
      font-size: 24px;
      cursor: pointer;
    }
  </style>
</head>
<body>
  <div id="app"></div>
  <script src="src/App.js" type="module"></script>
</body>
</html>
```

## Step 4: Run the Game

### Plain JavaScript

```bash
npx parcel index.html
```

### React

```bash
npm start
```

## Adding AI

Add AI enumeration to enable computer opponents:

```javascript
export const TicTacToe = {
  // ... existing code ...

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
};
```

Use with AI stepping:

```javascript
import { Client } from 'boardgame.io/client';
import { MCTSBot } from 'boardgame.io/ai';

const client = Client({
  game: TicTacToe,
  ai: MCTSBot,
});
```

## Documentation Reference

- [Tutorial](https://boardgame.io/documentation/#/tutorial) - Full tutorial
- [Concepts](https://boardgame.io/documentation/#/concepts) - Core concepts
