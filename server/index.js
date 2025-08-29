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
  clients.push(socket);

  socket.on('disconnect', () => {
    console.log('user disconnected:', socket.id);
    clients = clients.filter(client => client.id !== socket.id);
    io.emit('clients', clients.map(client => client.id));
  });

  socket.on('register', (id) => {
    console.log(`Registering client with id: ${id}`);
    socket.id = id;
    io.emit('clients', clients.map(client => client.id));
  });

  socket.on('offer', (data) => {
    const targetSocket = clients.find(client => client.id === data.target);
    if (targetSocket) {
      targetSocket.emit('offer', { from: socket.id, offer: data.offer });
    }
  });

  socket.on('answer', (data) => {
    const targetSocket = clients.find(client => client.id === data.target);
    if (targetSocket) {
      targetSocket.emit('answer', { from: socket.id, answer: data.answer });
    }
  });

  socket.on('candidate', (data) => {
    const targetSocket = clients.find(client => client.id === data.target);
    if (targetSocket) {
      targetSocket.emit('candidate', { from: socket.id, candidate: data.candidate });
    }
  });

  io.emit('clients', clients.map(client => client.id));
});

const port = process.env.PORT || 3000;

server.listen(port, () => {
  console.log(`Signaling server listening on port ${port}`);
});