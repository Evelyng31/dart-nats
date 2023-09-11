
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

    test('jetstreamAPIStreamList', () async {
      var client = ClientJS();
      await client.connect(Uri.parse('nats://localhost:4222'),
          retryInterval: 1);

      var inbox = newInbox();
      var inboxSub = client.sub(inbox);
      
      var apiPrefix = JetStreamAPIConstants.apiStreamListT;
      String apiString = JetStreamAPIConstants.defaultAPIPrefix + apiPrefix;
   
      client.pubString(apiString, '{}', replyTo: inbox);
      var receive = await inboxSub.stream.first;
      var receiveString =   utf8.decode(receive.data);
      var map =  jsonDecode(receiveString);
      print(map);
       expect(map['type'], equals('io.nats.jetstream.api.v1.stream_list_response'));
    });

    test('jetstreamAPIStreamNames', () async {
      var client = ClientJS();
      await client.connect(Uri.parse('nats://localhost:4222'),
          retryInterval: 1);

      var inbox = newInbox();
      var inboxSub = client.sub(inbox);
      
      var apiPrefix = JetStreamAPIConstants.apiStreams;
      String apiString = JetStreamAPIConstants.defaultAPIPrefix + apiPrefix;
      print(apiString);
      client.pubString(apiString, '{}', replyTo: inbox);
      var receive = await inboxSub.stream.first;
      var receiveString =   utf8.decode(receive.data);
      var map =  jsonDecode(receiveString);
      print(map);
     //  expect(map['type'], equals('io.nats.jetstream.api.v1.stream_list_response'));
    });

    test('jetstreamCreateStream', () async {
      var client = ClientJS();
      await client.connect(Uri.parse('nats://localhost:4222'),
          retryInterval: 1);

      var inbox = newInbox();
      var inboxSub = client.sub(inbox);
      //bare min config as below
      client.pubString('\$JS.API.STREAM.CREATE.MYSTREAMAGAIN', '{"Name":"MYSTREAMAGAIN","Subjects":["lonely"], "Storage":"file", "Retention Policy":"Limits", "Discard policy":"old"}', replyTo: inbox);

      var receive = await inboxSub.stream.first;
      var receiveString =   utf8.decode(receive.data);
      var map =  jsonDecode(receiveString);
      print(map);
       expect(map['type'], equals('io.nats.jetstream.api.v1.stream_create_response'));
    });

 ///TODO: Config Struct - Still need to add config file...
      test('jetstreamUpdateStream', () async {
      var client = ClientJS();
      await client.connect(Uri.parse('nats://localhost:4222'),
          retryInterval: 1);

      var inbox = newInbox();
      var inboxSub = client.sub(inbox);

      var streamName = "TESTSTREAM";
      var apiPrefix = JetStreamAPIConstants.apiStreamUpdateT.replaceAll("%s", streamName);
      String apiString = JetStreamAPIConstants.defaultAPIPrefix + apiPrefix;
      print(apiString);
  
      client.pubString(apiString, '{"Name":"TESTSTREAM","Subjects":["foo"]}', replyTo: inbox);

      var receive = await inboxSub.stream.first;
      var receiveString =   utf8.decode(receive.data);
      var map =  jsonDecode(receiveString);
      print(map);
      expect(map['type'], equals('io.nats.jetstream.api.v1.stream_update_response'));
    });


    test('jetstreamStreamInfo', () async {
      var client = ClientJS();
      await client.connect(Uri.parse('nats://localhost:4222'),
          retryInterval: 1);

      var inbox = newInbox();
      var inboxSub = client.sub(inbox);

      var streamName = "TESTSTREAM";
      var apiPrefix = JetStreamAPIConstants.apiStreamInfoT.replaceAll("%s", streamName);
      String apiString = JetStreamAPIConstants.defaultAPIPrefix + apiPrefix;
      print(apiString);
  
      client.pubString(apiString, '{"Name":"TESTSTREAM"}', replyTo: inbox);

      var receive = await inboxSub.stream.first;
      var receiveString =   utf8.decode(receive.data);
      var map =  jsonDecode(receiveString);
      print(map);
      expect(map['type'], equals('io.nats.jetstream.api.v1.stream_info_response'));
    });

    test('jetstreamDeleteStream', () async {
      var client = ClientJS();
      await client.connect(Uri.parse('nats://localhost:4222'),
          retryInterval: 1);

      var inbox = newInbox();
      var inboxSub = client.sub(inbox);

      var streamName = "MYSTREAM";
      var apiPrefix = JetStreamAPIConstants.apiStreamDeleteT.replaceAll("%s", streamName);
      String apiString = JetStreamAPIConstants.defaultAPIPrefix + apiPrefix;
      print(apiString);
  
      client.pubString(apiString, '{}', replyTo: inbox);

      var receive = await inboxSub.stream.first;
      var receiveString =   utf8.decode(receive.data);
      var map =  jsonDecode(receiveString);
      print(map);
      expect(map['type'], equals('io.nats.jetstream.api.v1.stream_delete_response'));
    });

    test('jetstreamPurgeStream', () async {
      var client = ClientJS();
      await client.connect(Uri.parse('nats://localhost:4222'),
          retryInterval: 1);

      var inbox = newInbox();
      var inboxSub = client.sub(inbox);

      var streamName = "TESTSTREAM";
      var apiPrefix = JetStreamAPIConstants.apiStreamPurgeT.replaceAll("%s", streamName);
      String apiString = JetStreamAPIConstants.defaultAPIPrefix + apiPrefix;
      print(apiString);
  
      client.pubString(apiString, '{}', replyTo: inbox);

      var receive = await inboxSub.stream.first;
      var receiveString =   utf8.decode(receive.data);
      var map =  jsonDecode(receiveString);
      print(map);
      expect(map['type'], equals('io.nats.jetstream.api.v1.stream_purge_response'));
    });

    /// TODO: CHECK CONFIG TO DELETE SINGLE MSG
    test('jetstreamDeleteStreamMsg', () async {
      var client = ClientJS();
      await client.connect(Uri.parse('nats://localhost:4222'),
          retryInterval: 1);

      var inbox = newInbox();
      var inboxSub = client.sub(inbox);

      var streamName = "MYSTREAM";
      var apiPrefix = JetStreamAPIConstants.apiMsgDeleteT.replaceAll("%s", streamName);
      String apiString = JetStreamAPIConstants.defaultAPIPrefix + apiPrefix;
      print(apiString);
  
      client.pubString(apiString, '{}', replyTo: inbox);

      var receive = await inboxSub.stream.first;
      var receiveString =   utf8.decode(receive.data);
      var map =  jsonDecode(receiveString);
      print(map);
      //expect(map['type'], equals('io.nats.jetstream.api.v1.stream_msg_delete_response'));
    });

/// TODO: CHECK CONFIG TO GET SINGLE MSG
    test('jetstreamGetStreamMsg', () async {
      var client = ClientJS();
      await client.connect(Uri.parse('nats://localhost:4222'),
          retryInterval: 1);

      var inbox = newInbox();
      var inboxSub = client.sub(inbox);

      var streamName = "MYSTREAM";
      var apiPrefix = JetStreamAPIConstants.apiMsgGetT.replaceAll("%s", streamName);
      String apiString = JetStreamAPIConstants.defaultAPIPrefix + apiPrefix;
      print(apiString);
  
      client.pubString(apiString, '{}', replyTo: inbox);

      var receive = await inboxSub.stream.first;
      var receiveString =   utf8.decode(receive.data);
      var map =  jsonDecode(receiveString);
      print(map);
      //expect(map['type'], equals('io.nats.jetstream.api.v1.stream_msg_get_response'));
    });
/// TODO: CHECK CONFIG TO DO STREAM SNAPSHOT
     test('jetstreamStreamSnapshot', () async {
      var client = ClientJS();
      await client.connect(Uri.parse('nats://localhost:4222'),
          retryInterval: 1);

      var inbox = newInbox();
      var inboxSub = client.sub(inbox);

      var streamName = "MYSTREAM";
      var apiPrefix = JetStreamAPIConstants.apiStreamSnapshotT.replaceAll("%s", streamName);
      String apiString = JetStreamAPIConstants.defaultAPIPrefix + apiPrefix;
      print(apiString);
  
      client.pubString(apiString, '{}', replyTo: inbox);

      var receive = await inboxSub.stream.first;
      var receiveString =   utf8.decode(receive.data);
      var map =  jsonDecode(receiveString);
      print(map);
      //expect(map['type'], equals('io.nats.jetstream.api.v1.stream_snapshot_response'));
    });

    test('jetstreamStreamRestore', () async {
      var client = ClientJS();
      await client.connect(Uri.parse('nats://localhost:4222'),
          retryInterval: 1);

      var inbox = newInbox();
      var inboxSub = client.sub(inbox);

      var streamName = "MYSTREAM";
      var apiPrefix = JetStreamAPIConstants.apiStreamRestoreT.replaceAll("%s", streamName);
      String apiString = JetStreamAPIConstants.defaultAPIPrefix + apiPrefix;
      print(apiString);
  
      client.pubString(apiString, '{"Subjects":["foo"]}', replyTo: inbox);

      var receive = await inboxSub.stream.first;
      var receiveString =   utf8.decode(receive.data);
      var map =  jsonDecode(receiveString);
      print(map);
      expect(map['type'], equals('io.nats.jetstream.api.v1.stream_restore_response'));
    });

    
  });
}

