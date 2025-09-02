const express = require('express');
const http = require('http');
const { Server } = require("socket.io");

const app = express();
const server = http.createServer(app);
const io = new Server(server);

let clients = [];

app.get('/clients', (req, res) => {
  res.json(clients.map(client => client.id));
});

io.on('connection', (socket) => {
  console.log('a user connected:', socket.id);

  // Emit the current list of clients to the new user
  socket.emit('clients', clients.map(client => client.id));

  // Add the new client to the list
  clients.push(socket);

  // Broadcast the updated list to all clients
  io.emit('clients', clients.map(client => client.id));

  socket.on('disconnect', () => {
    console.log('user disconnected:', socket.id);
    clients = clients.filter(client => client.id !== socket.id);
    io.emit('clients', clients.map(client => client.id));
  });

  socket.on('register', (id) => {
    console.log(`Registering client with id: ${id}`);
    const clientIndex = clients.findIndex(client => client.id === socket.id);
    if (clientIndex !== -1) {
      clients[clientIndex].id = id;
    }
    io.emit('clients', clients.map(client => client.id));
  });

  socket.on('offer', (data) => {
    const targetSocket = clients.find(client => client.id === data.target);
    if (targetSocket) {
      targetSocket.emit('offer', { from: data.from || socket.id, offer: data.offer });
    }
  });

  socket.on('answer', (data) => {
    const targetSocket = clients.find(client => client.id === data.target);
    if (targetSocket) {
      targetSocket.emit('answer', { from: data.from || socket.id, answer: data.answer });
    }
  });

  socket.on('candidate', (data) => {
    const targetSocket = clients.find(client => client.id === data.target);
    console.log("targetSocket: ${targetSocket}")
    if (targetSocket) {
      targetSocket.emit('candidate', { from: data.from || socket.id, candidate: data.candidate });
    }
  });
});

const port = process.env.PORT || 3000;

server.listen(port, "192.168.1.142", () => {
  console.log(`Signaling server listening on port ${port}`);
});