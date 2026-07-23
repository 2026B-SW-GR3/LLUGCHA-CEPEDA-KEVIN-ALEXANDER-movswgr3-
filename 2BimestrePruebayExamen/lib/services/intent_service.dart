import 'package:flutter/services.dart';
import '../models/meetup_event.dart';

class IntentService {
  static const _channel = MethodChannel('com.fitmap.intent');

  Future<void> sendEventToApp2(MeetupEvent event) async {
    try {
      await _channel.invokeMethod('sendEvent', {
        'action': 'com.fitmap.RECEIVE_EVENT',
        'extras': event.toMap(),
      });
    } on PlatformException catch (e) {
      throw Exception('Error al enviar evento: ${e.message}');
    }
  }
}
