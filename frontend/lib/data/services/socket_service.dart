import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';

class SocketService {
  IO.Socket? _socket;
  final Box _authBox = Hive.box('auth');

  void connect() {
    if (_socket != null && _socket!.connected) return;

    final token = _authBox.get('accessToken');

    _socket = IO.io(
      AppConstants.socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      print('Socket подключен');
    });

    _socket!.onDisconnect((_) {
      print('Socket отключен');
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  IO.Socket? get socket => _socket;

  bool get isConnected => _socket?.connected ?? false;

  void on(String event, Function(dynamic) callback) {
    _socket?.on(event, callback);
  }

  void off(String event) {
    _socket?.off(event);
  }

  void emit(String event, dynamic data) {
    _socket?.emit(event, data);
  }
}

final socketServiceProvider = Provider<SocketService>((ref) {
  return SocketService();
});
