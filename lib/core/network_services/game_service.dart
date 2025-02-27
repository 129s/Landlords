import 'dart:async';

import 'package:landlords_3/core/network_services/constants/constants.dart';
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
      'gamePhaseUpdate',
      _handleGamePhaseUpdate,
    );
    _socketService.on<Map<String, dynamic>>(
      'playCardUpdate',
      _handlePlayCardUpdate,
    );
    _socketService.on<Map<String, dynamic>>(
      'biddingUpdate',
      _handleBiddingUpdate,
    );
    _socketService.on<Map<String, dynamic>>(
      'landlordUpdate',
      _handleLandlordUpdate,
    );
  }

  // 游戏阶段更新处理
  void _handleGamePhaseUpdate(Map<String, dynamic> data) {
    try {
      final phase = GamePhase.values.firstWhere(
        (e) => e.name == data['gamePhase'],
        orElse: () => GamePhase.error,
      );
      final currentPlayerIndex = data['currentPlayerIndex'] as int;

      _currentGameState = _currentGameState?.copyWith(
        gamePhase: phase,
        currentPlayerIndex: currentPlayerIndex,
      );

      _gameStateController.add(_currentGameState);
      _logger.i('Phase changed to $phase');
    } catch (e) {
      _logger.e('Phase update error: ${e.toString()}');
    }
  }

  // 地主更新处理
  void _handleLandlordUpdate(Map<String, dynamic> data) {
    try {
      final landlordIndex = data['landlordIndex'] as int;
      final additionalCards =
          (data['additionalCards'] as List)
              .map((c) => Poker.fromJson(c as Map<String, dynamic>))
              .toList();

      _currentGameState = _currentGameState?.copyWith(
        landlordIndex: landlordIndex,
        additionalCards: additionalCards,
      );

      _gameStateController.add(_currentGameState);
      _logger.i('Landlord updated to $landlordIndex');
    } catch (e) {
      _logger.e('Landlord update error: ${e.toString()}');
    }
  }

  // 出牌处理实现
  void _handlePlayCardUpdate(Map<String, dynamic> data) {
    try {
      final currentPlayerIndex = data['currentPlayerIndex'] as int;
      final playerCards =
          (data['playerCards'] as List)
              .map((c) => Poker.fromJson(c as Map<String, dynamic>))
              .toList();
      final lastPlayedCards =
          (data['lastPlayedCards'] as List)
              .map((c) => Poker.fromJson(c as Map<String, dynamic>))
              .toList();

      _currentGameState = _currentGameState?.copyWith(
        currentPlayerIndex: currentPlayerIndex,
        lastPlayedCards: lastPlayedCards,
        playerCards: playerCards,
      );

      _gameStateController.add(_currentGameState);
      _logger.i(
        'Card play update: ${lastPlayedCards.length} cards by $currentPlayerIndex',
      );
    } catch (e) {
      _logger.e('Play update parse error: ${e.toString()}');
    }
  }

  // 叫分处理实现
  void _handleBiddingUpdate(Map<String, dynamic> data) {
    try {
      final currentPlayerIndex = data['currentPlayerIndex'] as int;
      final bidValue = data['bidValue'] as int;
      final isHighest = data['isHighest'] as bool;

      _currentGameState = _currentGameState?.copyWith(
        currentPlayerIndex: currentPlayerIndex,
        highestBid: isHighest ? bidValue : _currentGameState?.highestBid,
        gamePhase: GamePhase.bidding,
      );

      _gameStateController.add(_currentGameState);
      _logger.i('New bid: $bidValue by $currentPlayerIndex');
    } catch (e) {
      _logger.e('Bidding update parse error: ${e.toString()}');
    }
  }

  void playCards(List<Poker> cards) {
    final cardData = cards.map((c) => c.toJson()).toList();
    _socketService.emit('playCards', cardData);
    _logger.i('Playing ${cards.length} cards');
  }

  void placeBid(int value) {
    _socketService.emit('placeBid', {'bid_value': value});
    _logger.i('Bidding with value: $value');
  }

  void passTurn() {
    _socketService.emit('passTurn');
    _logger.i('passTurn');
  }

  void dispose() {
    _gameStateController.close();
    _socketService.off('gamePhaseUpdate');
    _socketService.off('playCardUpdate');
    _socketService.off('biddingUpdate');
    _socketService.off('landlordUpdate');
  }
}
