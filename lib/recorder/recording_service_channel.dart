import 'package:flutter/services.dart';

class RecordingServiceChannel {
  static const _channel = MethodChannel('rexorder/recording_service');

  static Future<void> start() => _channel.invokeMethod<void>('start');

  static Future<void> stop() => _channel.invokeMethod<void>('stop');
}
