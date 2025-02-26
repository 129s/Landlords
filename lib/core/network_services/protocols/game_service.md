# 游戏服务通信协议

## 核心事件

### 游戏状态更新
```json
// 服务端→客户端
{
  "event_type": "game_state_update",
  "data": {
    "current_player_index": 0,
    "game_phase": "bidding",
    "played_cards": [
      {"suit": "heart", "value": "K"},
      {"suit": "spade", "value": "A"}
    ],
    "current_bid_value": 3
  }
}
```

### 玩家操作
| 操作类型 | 发送事件   | 数据格式                                              |
| -------- | ---------- | ----------------------------------------------------- |
| 出牌     | play_cards | `{"cards": [{"suit": string, "value": string}, ...]}` |
| 叫分     | place_bid  | `{"bid_value": int}`                                  |
| 跳过回合 | pass_turn  | `{}`                                                  |

### 操作响应
```json
// 服务端→客户端（出牌响应示例）
{
  "status": "success",
  "current_player_index": 1,
  "played_cards": [...],
  "validation": {
    "is_valid": true,
    "error_code": null
  }
}
```