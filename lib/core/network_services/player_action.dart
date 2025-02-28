enum ActionType { playCards, placeBid, passTurn, toggleReady }

class PlayerAction {
  final ActionType actionType;
  final dynamic data;

  PlayerAction(this.actionType, [this.data]);

  Map<String, dynamic> toJson() => {'type': actionType.name, 'data': data};
}
