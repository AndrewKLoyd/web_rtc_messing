
# WebRTC Flutter App Blueprint

## Overview

This document outlines the architecture and implementation plan for a Flutter application that uses WebRTC for video conferencing. The application will feature a main screen listing available rooms, the ability to create new rooms, and the functionality to join existing rooms for video calls.

## Architecture

The application will follow a clean architecture pattern, separating concerns into three distinct layers:

*   **Presentation:** This layer will be responsible for the UI and user interaction. It will include widgets, screens, and state management providers.
*   **Domain:** This layer will contain the business logic of the application. It will define entities, use cases, and repository interfaces.
*   **Data:** This layer will be responsible for data retrieval and storage. It will include repository implementations and data sources that interact with external services like a signaling server.

## Features

### 1. Main Screen

*   **List of Rooms:** The main screen will display a list of active WebRTC rooms that users can join.
*   **Create Room FAB:** A Floating Action Button (FAB) will allow users to create a new room.

### 2. Create a Room

*   This feature will allow a user to create a new WebRTC room.
*   The application will generate a unique room ID.
*   The user will be automatically connected to the newly created room.

### 3. Join a Room

*   This feature will allow a user to join an existing WebRTC room from the list on the main screen.
*   The user will be connected to the selected room and will be able to communicate with other participants.

## Implementation Plan

1.  **Project Setup:**
    *   Create the folder structure for the data, domain, and presentation layers.
    *   Add necessary dependencies to the `pubspec.yaml` file, including `flutter_webrtc`, `provider`, `uuid`, and `go_router`.

2.  **Domain Layer:**
    *   Define the `Room` entity.
    *   Define the `RoomRepository` and `SignalingRepository` interfaces.
    *   Create use cases for creating a room, getting a list of rooms, and connecting to a room.

3.  **Data Layer:**
    *   Implement the `RoomRepository` and `SignalingRepository`.
    *   Create a remote data source to communicate with the signaling server via WebSockets.
    *   The signaling server URL, STUN, and TURN server configurations will be passed as parameters.

4.  **Presentation Layer:**
    *   Implement the main screen with a list of rooms and a FAB.
    *   Create a `RoomProvider` to manage the state of the rooms.
    *   Implement the call screen where the WebRTC video call will take place.
    *   Create a `CallProvider` to manage the state of the call.
    *   Set up routing using `go_router`.

5.  **Main Application:**
    *   Initialize the application in `lib/main.dart`.
    *   Set up the necessary providers and routing.
