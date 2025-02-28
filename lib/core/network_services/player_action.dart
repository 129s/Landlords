import 'package:landlords_3/core/network_services/constants/constants.dart';

/// 玩家行动类
///
/// 定义了玩家行动类型和对应的数据
/// 服务端将根据对应的行动类型执行相关handle处理
class PlayerAction {
  final ActionType actionType;
  final dynamic data;

  PlayerAction(this.actionType, [this.data]);

  Map<String, dynamic> toJson() => {'type': actionType.name, 'data': data};
}
