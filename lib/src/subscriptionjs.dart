///subscription model
import 'dart:async';

import 'package:dart_nats/src/messagejs.dart';

import 'clientjs.dart';


/// subscription class
class SubscriptionJS<T> {
  ///subscriber id (audo generate)
  final int sid;

  ///subject and queuegroup of this subscription
  final String? subject, queueGroup;

  final ClientJS _client;

  late StreamController<JSMessage<T>> _controller;

  late Stream<JSMessage<T>> _stream;

  ///convert from json string to T for structure data
  T Function(String)? jsonDecoder;

  ///constructure
  SubscriptionJS(this.sid, this.subject, this._client,
      {this.queueGroup, this.jsonDecoder}) {
    _controller = StreamController<JSMessage<T>>();
    _stream = _controller.stream.asBroadcastStream();
  }

  ///
  void unSub() {
    _client.unSub(this);
  }

  ///Stream output when server publish message
  Stream<JSMessage<T>> get stream => _stream;

  ///sink messat to listener
  void add(JSMessage raw) {
    if (_controller.isClosed) return;
    _controller.sink.add(JSMessage<T>(
      raw.subject,
      raw.sid,
      raw.byte,
      _client,
      replyTo: raw.replyTo,
      jsonDecoder: jsonDecoder,
      header: raw.header,
    ));
  }

  ///close the stream
  Future close() async {
    await _controller.close();
  }
}
