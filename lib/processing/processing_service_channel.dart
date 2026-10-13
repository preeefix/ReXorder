import 'package:flutter/services.dart';

class ProcessingServiceChannel {
  static const MethodChannel _channel = MethodChannel(
    'rexorder/processing_service',
  );

  static Future<void> start(String title) =>
      _channel.invokeMethod<void>('start', {'title': title});

  static Future<void> update(String title, int progress, int max) =>
      _channel.invokeMethod<void>('update', {
        'title': title,
        'progress': progress,
        'max': max,
      });

  static Future<void> stop() => _channel.invokeMethod<void>('stop');
}
