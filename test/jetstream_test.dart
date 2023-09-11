
import 'dart:async';
import 'dart:convert';


import 'package:dart_nats/dart_nats.dart';
import 'package:dart_nats/src/clientjs.dart';
import 'package:test/test.dart';

void main() {
  group('all', () {
    test('jetstreamInfo', () async {
      var client = ClientJS();
      await client.connect(Uri.parse('nats://localhost:4222'),
          retryInterval: 1);

      var inbox = newInbox();
      var inboxSub = client.sub(inbox);
    
      client.pubString('\$JS.API.INFO', '{}', replyTo: inbox);

      var receive = await inboxSub.stream.first;
      var receiveString =   utf8.decode(receive.data);
      var map =  jsonDecode(receiveString);
  
      expect(map['type'], equals('io.nats.jetstream.api.v1.account_info_response'));
    });

    test('jetstreamCreateStream', () async {
      var client = ClientJS();
      await client.connect(Uri.parse('nats://localhost:4222'),
          retryInterval: 1);

      var inbox = newInbox();
      var inboxSub = client.sub(inbox);
  
      client.pubString('\$JS.API.STREAM.CREATE.TESTSTREAM', '{"Name":"TESTSTREAM","Subjects":["foo"]}', replyTo: inbox);

      var receive = await inboxSub.stream.first;
      var receiveString =   utf8.decode(receive.data);
      var map =  jsonDecode(receiveString);

       expect(map['type'], equals('io.nats.jetstream.api.v1.stream_create_response'));
    });

    test('jetstreamConsumerList', () async {
      var client = ClientJS();
      await client.connect(Uri.parse('nats://localhost:4222'),
          retryInterval: 1);

      var inbox = newInbox();
      var inboxSub = client.sub(inbox);
  
      client.pubString('\$JS.API.CONSUMER.LIST.TESTSTREAM', '{"Name":"TESTSTREAM"}', replyTo: inbox);

      var receive = await inboxSub.stream.first;
      var receiveString =   utf8.decode(receive.data);
      var map =  jsonDecode(receiveString);

      expect(map['type'], equals('io.nats.jetstream.api.v1.consumer_list_response'));
    });

  });
}

