# 房间服务通信协议

## 房间操作事件

| 事件名称    | 方向          | 数据格式 |
| ----------- | ------------- | -------- |
| create_room | 客户端→服务端 | `{       |
    "creator_id": string
}`                |
| join_room      | 客户端→服务端 | `{
    "room_id": string,
    "user_id": string
}` |
| leave_room     | 客户端→服务端 | `{
    "user_id": string
}`                    |

## 房间状态同步
```json
// 服务端→客户端（房间更新）
{
    "room_id": "room_888",
    "players": [
        {
            "id": "user_123",
            "ready": false
        },
        {
            "id": "user_456",
            "ready": true
        }
    ],
    "status": "waiting",
    "capacity": 3
}
```

## 房间列表协议
```json
// 服务端→客户端（房间列表响应）
{
    "rooms": [
        {
            "room_id": "room_001",
            "player_count": 2,
            "status": "playing"
        },
        {
            "room_id": "room_002",
            "player_count": 1,
            "status": "waiting"
        }
    ]
}
```

## 玩家进出通知
```json
// 服务端→客户端（玩家加入）
{
    "event_type": "player_joined",
    "user_id": "user_789",
    "room_status": "waiting"
}
```