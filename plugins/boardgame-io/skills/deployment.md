---
description: Deploy boardgame.io games to production. Use when deploying game servers, configuring database storage, setting up production hosting, or optimizing for production.
---

# boardgame.io Deployment

Deploy your game server and client to production.

## Server Deployment

### Basic Production Server

```javascript
// server.js
import { Server, Origins } from 'boardgame.io/server';
import { MyGame } from './Game';

const server = Server({
  games: [MyGame],
  origins: [
    'https://mygame.example.com', // Your production domain
  ],
});

const PORT = process.env.PORT || 8000;
server.run(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

### Environment-Based Configuration

```javascript
import { Server, Origins } from 'boardgame.io/server';

const origins = process.env.NODE_ENV === 'production'
  ? ['https://mygame.example.com']
  : [Origins.LOCALHOST];

const server = Server({
  games: [MyGame],
  origins,
});

server.run(process.env.PORT || 8000);
```

## Database Storage

By default, boardgame.io uses in-memory storage. For production, use a persistent database.

### MongoDB (via FlatFile or custom adapter)

```javascript
import { Server } from 'boardgame.io/server';
import { FlatFile } from 'boardgame.io/server';
import path from 'path';

const server = Server({
  games: [MyGame],
  db: new FlatFile({
    dir: path.join(__dirname, 'data'),
    logging: process.env.NODE_ENV !== 'production',
  }),
});
```

### PostgreSQL Adapter

```javascript
import { Server } from 'boardgame.io/server';
import { PostgresStore } from 'bgio-postgres';

const db = new PostgresStore(process.env.DATABASE_URL);

const server = Server({
  games: [MyGame],
  db,
});
```

### Redis Adapter

```javascript
import { Server } from 'boardgame.io/server';
import { RedisStore } from 'bgio-redis';

const db = new RedisStore({
  url: process.env.REDIS_URL,
});

const server = Server({
  games: [MyGame],
  db,
});
```

## Client Configuration

### Production Client Setup

```javascript
import { Client } from 'boardgame.io/client';
import { SocketIO } from 'boardgame.io/multiplayer';
import { MyGame } from './Game';

const SERVER_URL = process.env.NODE_ENV === 'production'
  ? 'https://api.mygame.example.com'
  : 'http://localhost:8000';

const client = Client({
  game: MyGame,
  multiplayer: SocketIO({ server: SERVER_URL }),
  playerID: '0',
  matchID: 'my-match',
});
```

### React Client

```jsx
import { Client } from 'boardgame.io/react';
import { SocketIO } from 'boardgame.io/multiplayer';

const SERVER_URL = process.env.REACT_APP_SERVER_URL || 'http://localhost:8000';

const App = Client({
  game: MyGame,
  board: Board,
  multiplayer: SocketIO({ server: SERVER_URL }),
});
```

## Hosting Platforms

### Heroku

1. Create `Procfile`:
```
web: node server.js
```

2. Configure for WebSocket support:
```javascript
// server.js
import { Server } from 'boardgame.io/server';

const server = Server({
  games: [MyGame],
  origins: ['https://your-app.herokuapp.com'],
});

// Heroku provides PORT environment variable
server.run(process.env.PORT || 8000);
```

3. Deploy:
```bash
heroku create my-game-server
git push heroku main
```

### Railway/Render

Similar to Heroku, just push your code and set environment variables.

### Docker

```dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .

ENV NODE_ENV=production
ENV PORT=8000

EXPOSE 8000

CMD ["node", "server.js"]
```

### Kubernetes

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: game-server
spec:
  replicas: 3
  selector:
    matchLabels:
      app: game-server
  template:
    metadata:
      labels:
        app: game-server
    spec:
      containers:
      - name: server
        image: your-registry/game-server:latest
        ports:
        - containerPort: 8000
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: db-secrets
              key: url
---
apiVersion: v1
kind: Service
metadata:
  name: game-server
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 8000
  selector:
    app: game-server
```

## Static File Hosting

For the client, use any static hosting (Vercel, Netlify, CloudFlare Pages):

### Vercel

```json
// vercel.json
{
  "rewrites": [
    { "source": "/(.*)", "destination": "/index.html" }
  ]
}
```

### Netlify

```toml
# netlify.toml
[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
```

## Security Considerations

### Credential Authentication

```javascript
import { Server } from 'boardgame.io/server';

const server = Server({
  games: [MyGame],
  generateCredentials: () => {
    // Generate secure random credentials
    return crypto.randomUUID();
  },
  authenticateCredentials: (credentials, playerMetadata) => {
    // Verify credentials match
    return credentials === playerMetadata.credentials;
  },
});
```

### Rate Limiting

```javascript
import rateLimit from 'express-rate-limit';

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
});

// Apply to lobby endpoints
app.use('/games', limiter);
```

### HTTPS

Always use HTTPS in production:

```javascript
import https from 'https';
import fs from 'fs';
import { Server } from 'boardgame.io/server';

const server = Server({ games: [MyGame] });

const httpsServer = https.createServer({
  key: fs.readFileSync('privkey.pem'),
  cert: fs.readFileSync('cert.pem'),
}, server.app);

server.run({ server: httpsServer, port: 443 });
```

## Monitoring

### Health Check Endpoint

```javascript
import { Server } from 'boardgame.io/server';

const server = Server({ games: [MyGame] });

// Add health check
server.app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});
```

### Logging

```javascript
import pino from 'pino';

const logger = pino({
  level: process.env.LOG_LEVEL || 'info',
});

const server = Server({
  games: [MyGame],
});

// Log connections
server.app.use((req, res, next) => {
  logger.info({ method: req.method, url: req.url });
  next();
});
```

## Documentation Reference

- [Deployment](https://boardgame.io/documentation/#/deployment) - Deployment guide
- [Storage](https://boardgame.io/documentation/#/storage) - Database adapters
- [Server API](https://boardgame.io/documentation/#/api/Server) - Server configuration
