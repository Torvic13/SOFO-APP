import 'dotenv/config';

import { createServer } from 'node:http';
import { Server } from 'socket.io';

import { createApp } from './app.js';
import { createRepository } from './config/repository.js';
import { configureSockets } from './sockets.js';

const port = Number(process.env.PORT ?? 3000);
const repository = createRepository();
const httpServer = createServer();
const io = new Server(httpServer, {
  cors: { origin: process.env.CLIENT_ORIGIN ?? '*' },
});

httpServer.on('request', createApp(repository, io));
configureSockets(io, repository);

httpServer.listen(port, () => {
  console.info(`SOFO Driver API disponible en http://localhost:${port}`);
});
