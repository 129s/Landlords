import 'dart:async';

import 'package:landlords_3/core/network_services/constants/constants.dart';
import 'package:landlords_3/core/network_services/player_action.dart';
import 'package:landlords_3/core/network_services/socket_service.dart';
import 'package:landlords_3/data/models/game_state.dart';
import 'package:landlords_3/data/models/poker.dart';
import 'package:logger/logger.dart';

/// GameService 类：
///
/// 单例类，管理游戏核心逻辑的 Socket 通信与状态维护
/// 依赖 SocketService 进行底层通信，维护游戏状态流
///
/// 主要功能：
///   - 监听游戏状态更新、出牌结果、叫分结果等事件
///   - 提供游戏操作接口：出牌、叫分、开始游戏
///   - 通过 gameStateStream 广播游戏状态变化
///
/// 使用方式：
///   - 通过 GameService() 获取实例
///   - 监听 gameStateStream 获取状态更新
///   - 调用 playCards()/placeBid()/passTurn() 进行游戏操作

class GameService {
  final _logger = Logger();
  final SocketService _socketService = SocketService();

  GameState? _currentGameState;
  final _gameStateController = StreamController<GameState?>.broadcast();

  static final _instance = GameService._internal();
  factory GameService() => _instance;

  GameService._internal() {
    _setupEventListeners();
  }

  Stream<GameState?> get gameStateStream => _gameStateController.stream;
  GameState? get currentGameState => _currentGameState;

  void _setupEventListeners() {
    _socketService.on<Map<String, dynamic>>(
      'gameStateUpdate',
      _handleGameStateUpdate,
    );
  }

  // 游戏状态更新处理
  void _handleGameStateUpdate(Map<String, dynamic> data) {
    try {
      _logger.d(data);
      _currentGameState = GameState.fromJson(data);

      _gameStateController.add(_currentGameState);
      _logger.i('GameState Updated:$_currentGameState');
    } catch (e) {
      _logger.e('GameState update error: ${e.toString()}');
    }
  }

  Future<void> playerAction(PlayerAction action) async {
    final completer = Completer();
    final jsonData = action.toJson();
    _logger.d(jsonData);
    _socketService.emitWithAck('playerAction', jsonData, (data) {
      try {
        if (data is Map && data['status'] == 'success') {
          completer.complete();
        } else {
          completer.completeError('Invalid player action response');
        }
      } catch (e) {
        completer.completeError(e);
        _logger.e('Action failed: ${e.toString()}');
      }
    });
    _logger.i(
      'Request playerAction: ${action.actionType} with data: ${jsonData['data']}',
    );
    return completer.future;
  }

  Future<void> playCards(List<Poker> cards) => playerAction(
    PlayerAction(ActionType.playCards, cards.map((c) => c.toJson()).toList()),
  );

  Future<void> placeBid(int value) =>
      playerAction(PlayerAction(ActionType.placeBid, value));

  Future<void> passTurn() => playerAction(PlayerAction(ActionType.passTurn));

  void dispose() {
    _gameStateController.close();
    _socketService.off('gameStateUpdate');
  }
}
