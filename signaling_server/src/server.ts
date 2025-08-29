import { WebSocketServer, WebSocket } from 'ws';
import { v4 as uuidv4 } from 'uuid';

const server = new WebSocketServer({ port: 8080 });

interface Room {
  id: string;
  clients: Set<WebSocket>;
}

const rooms = new Map<string, Room>();

server.on('connection', ws => {
  console.log('Client connected');

  ws.on('message', message => {
    const data = JSON.parse(message.toString());
    const { type, payload } = data;

    switch (type) {
      case 'create_room':
        handleCreateRoom(ws);
        break;
      case 'join_room':
        handleJoinRoom(ws, payload.roomId);
        break;
      case 'offer':
        handleOffer(ws, payload.roomId, payload.offer);
        break;
      case 'answer':
        handleAnswer(ws, payload.roomId, payload.answer);
        break;
      case 'candidate':
        handleCandidate(ws, payload.roomId, payload.candidate);
        break;
      default:
        console.log('Unknown message type:', type);
    }
  });

  ws.on('close', () => {
    console.log('Client disconnected');
    // Handle client disconnection
  });
});

function handleCreateRoom(ws: WebSocket) {
  const roomId = uuidv4();
  const room: Room = {
    id: roomId,
    clients: new Set(),
  };
  room.clients.add(ws);
  rooms.set(roomId, room);
  ws.send(JSON.stringify({ type: 'room_created', payload: { roomId } }));
  console.log('Room created:', roomId);
}

function handleJoinRoom(ws: WebSocket, roomId: string) {
  const room = rooms.get(roomId);
  if (room) {
    room.clients.add(ws);
    ws.send(JSON.stringify({ type: 'room_joined', payload: { roomId } }));
    console.log('Client joined room:', roomId);
    // Notify other client in the room
    const otherClient = Array.from(room.clients).find(client => client !== ws);
    if (otherClient) {
      otherClient.send(JSON.stringify({ type: 'peer_joined' }));
    }
  } else {
    ws.send(JSON.stringify({ type: 'error', payload: { message: 'Room not found' } }));
  }
}

function handleOffer(ws: WebSocket, roomId: string, offer: any) {
  const room = rooms.get(roomId);
  if (room) {
    const otherClient = Array.from(room.clients).find(client => client !== ws);
    if (otherClient) {
      otherClient.send(JSON.stringify({ type: 'offer', payload: { offer } }));
    }
  }
}

function handleAnswer(ws: WebSocket, roomId: string, answer: any) {
  const room = rooms.get(roomId);
  if (room) {
    const otherClient = Array.from(room.clients).find(client => client !== ws);
    if (otherClient) {
      otherClient.send(JSON.stringify({ type: 'answer', payload: { answer } }));
    }
  }
}

function handleCandidate(ws: WebSocket, roomId: string, candidate: any) {
  const room = rooms.get(roomId);
  if (room) {
    const otherClient = Array.from(room.clients).find(client => client !== ws);
    if (otherClient) {
      otherClient.send(JSON.stringify({ type: 'candidate', payload: { candidate } }));
    }
  }
}

console.log('Signaling server started on ws://localhost:8080');
