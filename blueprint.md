# Project Blueprint

## Overview

This project consists of two main components:

1.  A Node.js signaling server for WebRTC.
2.  A Flutter application that uses WebRTC to make and receive calls.

## Signaling Server

*   **Technology:** Node.js with Express and Socket.IO
*   **Purpose:**
    *   Manages a list of connected clients (Flutter apps).
    *   Broadcasts the list of clients to all connected clients.
    *   Relays WebRTC signaling messages (offers, answers, and ICE candidates) between clients.

## Flutter App

*   **Technology:** Flutter
*   **Features:**
    *   Displays a list of available clients to call.
    *   Can initiate a call to another client.
    *   Can receive and answer incoming calls.