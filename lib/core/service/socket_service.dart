import 'dart:async';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../utils/api/app_url.dart';
import '../utils/logger_utils.dart';
import '../utils/token_service/token_storage_service.dart';

class SocketServices {
  static final SocketServices _instance = SocketServices._internal();
  factory SocketServices() => _instance;
  SocketServices._internal();

  IO.Socket? socket;
  String accessToken = '';

  Future<void> init() async {
    if (socket != null && socket!.connected) {
      return;
    }
    final SharedPrefService sharedPrefService = SharedPrefService();
    accessToken = await sharedPrefService.getAccessToken() ?? '';
    _connect();
  }

  // Ensure the socket is initialized and connected before proceeding.
  Future<void> checkSocketInitialized() async {
    if (socket == null || !socket!.connected) {
      LoggerUtils.debug(
        "⚠️ Socket not initialized or connected, calling `init()`...",
      );
      await init(); // Wait for the socket connection to initialize
      await _waitForConnection(); // Ensure the socket is connected
    }
  }

  // Wait until the socket is connected before proceeding.
  Future<void> _waitForConnection() async {
    // Wait until the socket is connected before proceeding
    if (socket != null) {
      await Future.doWhile(() async {
        if (socket!.connected) {
          return false;
        } else {
          await Future<dynamic>.delayed(const Duration(milliseconds: 500));
          return true;
        }
      });
    }
  }

  void _connect() {
    socket = IO.io(
      "${AppUrl.socketBaseUrl}?token=$accessToken",
      IO.OptionBuilder()
          .setTransports(<String>['websocket'])
          .setExtraHeaders(<String, dynamic>{
      })
          .setReconnectionAttempts(5)
          .setReconnectionDelay(2000)
          .build(),
    );

    socket!.onConnect((_) {
      LoggerUtils.debug('✅ Socket connected');
    });
    socket!.onDisconnect((_) {
      LoggerUtils.debug('⚠️ Socket disconnected, retrying...');
    });
    socket!.onConnectError((dynamic err) {
      LoggerUtils.debug('❌ Socket connection error: $err');
    });
    socket!.onError((dynamic err) {
      LoggerUtils.debug('🚨 Socket error: $err');
    });
  }

  // Emit event after ensuring socket is connected.
  Future<void> emit(String event, dynamic data) async {
    await checkSocketInitialized(); // Ensure the socket is connected first
    if (socket != null && socket!.connected) {
      socket!.emit(event, data);
      LoggerUtils.debug('📤 Emit: $event \nData: $data');
    } else {
      LoggerUtils.debug("⚠️ Cannot emit, socket not connected.");
    }
  }

  // Listen to event after ensuring socket is connected.
  Future<void> listen(String event, void Function(dynamic) callback) async {
    LoggerUtils.debug("listening method is called 1");

    await checkSocketInitialized(); // Ensure the socket is connected first
    LoggerUtils.debug("listening method is called 1");
    if (socket != null && socket!.connected) {
      socket!.on(event, (dynamic data) {
        callback(data); // Call the callback with the data received
        LoggerUtils.debug('📥 Received $event: $data');
      });
    } else {
      LoggerUtils.debug("⚠️ Cannot listen, socket not connected.");
    }
  }

  void disconnect() {
    socket?.dispose();
    LoggerUtils.debug('🔌 Socket disconnected');
  }
}