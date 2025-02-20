// 抽象类，用于检查网络连接状态
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

// TODO: 实现 NetworkInfo 接口，可以使用 connectivity_plus 包
