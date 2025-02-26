# 聊天服务通信协议

## 事件列表

| 事件名称     | 方向          | 数据格式                                                                           | 说明                 |
| ------------ | ------------- | ---------------------------------------------------------------------------------- | -------------------- |
| send_message | 客户端→服务端 | `{"sender_id": string, "content": string, "timestamp": int}`                       | 发送聊天消息         |
| new_message  | 服务端→客户端 | `{"message_id": string, "sender_id": string, "content": string, "timestamp": int}` | 广播新消息到所有用户 |

## 数据结构示例
```json
// 发送消息请求
{
  "sender_id": "user_123",
  "content": "大家好！",
  "timestamp": 1677654321
}

// 接收消息示例
{
  "message_id": "msg_8910",
  "sender_id": "user_456", 
  "content": "准备开始了吗？",
  "timestamp": 1677654333
}
```