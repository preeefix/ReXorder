import 'package:flutter/services.dart';

class PowerChannel {
  static const MethodChannel _methodChannel = MethodChannel('rexorder/power');
  static const EventChannel _chargingChannel = EventChannel(
    'rexorder/power/charging',
  );

  static Future<bool> isCharging() async =>
      await _methodChannel.invokeMethod<bool>('isCharging') ?? false;

  static Stream<bool> get chargingChanges =>
      _chargingChannel.receiveBroadcastStream().map((event) => event as bool);
}
