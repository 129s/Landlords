abstract class EventHandler<T> {
  T convert(dynamic data);
  void handle(dynamic data);
}
