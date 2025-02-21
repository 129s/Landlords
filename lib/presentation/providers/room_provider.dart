import 'package:flutter/material.dart';
import 'package:landlords_3/core/network/socket_client.dart';

class RoomProvider extends ChangeNotifier {
  String? _roomId;
  String? _playerName;
  List<PlayerInfo> _players = [];
  String? _errorMessage;

  String? get roomId => _roomId;
  String? get playerName => _playerName;
  List<PlayerInfo> get players => _players;
  String? get errorMessage => _errorMessage;

  bool get isRoomCreated => _roomId != null;
  bool get isRoomJoined => _roomId != null && _playerName != null;

  void createRoom(String playerName) {
    _playerName = playerName;
    SocketClient.socket.emit('createRoom', playerName);

    SocketClient.socket.on('roomCreated', (roomId) {
      _roomId = roomId;
      _errorMessage = null;
      notifyListeners();
    });

    SocketClient.socket.on('roomUpdate', (data) {
      _players =
          (data['players'] as List<dynamic>)
              .map(
                (player) => PlayerInfo(id: player['id'], name: player['name']),
              )
              .toList();
      notifyListeners();
    });

    SocketClient.socket.on('error', (message) {
      _errorMessage = message;
      notifyListeners();
    });
  }

  void joinRoom(String roomId, String playerName) {
    _roomId = roomId;
    _playerName = playerName;
    SocketClient.socket.emit('joinRoom', {
      'roomId': roomId,
      'playerName': playerName,
    });

    SocketClient.socket.on('roomUpdate', (data) {
      _players =
          (data['players'] as List<dynamic>)
              .map(
                (player) => PlayerInfo(id: player['id'], name: player['name']),
              )
              .toList();
      notifyListeners();
    });

    SocketClient.socket.on('error', (message) {
      _errorMessage = message;
      notifyListeners();
    });
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void resetRoom() {
    _roomId = null;
    _playerName = null;
    _players = [];
    _errorMessage = null;
    notifyListeners();
  }

  // Add a method to update the player list.  This is important for handling
  // playerLeft events from the server.
  void updatePlayers(List<PlayerInfo> newPlayers) {
    _players = newPlayers;
    notifyListeners();
  }
}

class PlayerInfo {
  final String id;
  final String name;

  PlayerInfo({required this.id, required this.name});
}
