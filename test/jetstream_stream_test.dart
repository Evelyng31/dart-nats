
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';


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
    
      // client.pubString('\$JS.API.INFO', '{}', replyTo: inbox);
      client.getJsServerInfo(client ,inbox);

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
      
      // var apiPrefix = JetStreamAPIConstants.apiStreamListT;
      // String apiString = JetStreamAPIConstants.defaultAPIPrefix + apiPrefix;
   
      // client.pubString(apiString, '{}', replyTo: inbox);
      client.getJsStreamList(client, inbox);

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
      
      // var apiPrefix = JetStreamAPIConstants.apiStreams;
      // String apiString = JetStreamAPIConstants.defaultAPIPrefix + apiPrefix;
      // print(apiString);
      // client.pubString(apiString, '{}', replyTo: inbox);
      client.getJsStreamNames(client, inbox);
      var receive = await inboxSub.stream.first;
      var receiveString =   utf8.decode(receive.data);
      var map =  jsonDecode(receiveString);
      print(map);
     //  expect(map['type'], equals('io.nats.jetstream.api.v1.stream_names_response'));
    });


    test('jetstreamCreateStream', () async {
      var client = ClientJS();
      await client.connect(Uri.parse('nats://localhost:4222'),
          retryInterval: 1);

      var inbox = newInbox();
      var inboxSub = client.sub(inbox);
      String streamName = 'MAZDA';
      JSStreamConfig myconfig = JSStreamConfig(
        name: streamName,
        subjects: ["MAZDA.*"]
      );
  
      //bare min config as below
      // client.pubString('\$JS.API.STREAM.CREATE.MYVI', '{"Name":"MYVI","Subjects":["MYVI.*"], "Storage":"file", "Retention Policy":"Limits", "Discard policy":"old"}', replyTo: inbox);

      client.createJsStream(client, inbox, streamName, myconfig);

      var receive = await inboxSub.stream.first;
      var receiveString =   utf8.decode(receive.data);
      var map =  jsonDecode(receiveString);
      print(map);
       expect(map['type'], equals('io.nats.jetstream.api.v1.stream_create_response'));
    });

      test('jetstreamUpdateStream', () async {
        //Can only update subjects
      var client = ClientJS();
      await client.connect(Uri.parse('nats://localhost:4222'),
          retryInterval: 1);

      var inbox = newInbox();
      var inboxSub = client.sub(inbox);

      var streamName = "TESTSTREAM";
      JSStreamConfig myconfig = JSStreamConfig(
        name: streamName,
        subjects: ["barbar"]
      );
      // var apiPrefix = JetStreamAPIConstants.apiStreamUpdateT.replaceAll("%s", streamName);
      // String apiString = JetStreamAPIConstants.defaultAPIPrefix + apiPrefix;
      // print(apiString);
  
      // client.pubString(apiString, '{"Name":"TESTSTREAM","Subjects":["foo"]}', replyTo: inbox);
      client.updateJsStream(client, inbox, streamName, myconfig);

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
      // var apiPrefix = JetStreamAPIConstants.apiStreamInfoT.replaceAll("%s", streamName);
      // String apiString = JetStreamAPIConstants.defaultAPIPrefix + apiPrefix;
      // print(apiString);
  
      // client.pubString(apiString, '{}', replyTo: inbox);

      client.getJsStreamInfo(client,inbox,streamName);

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
      // var apiPrefix = JetStreamAPIConstants.apiStreamDeleteT.replaceAll("%s", streamName);
      // String apiString = JetStreamAPIConstants.defaultAPIPrefix + apiPrefix;
      // print(apiString);
  
      // client.pubString(apiString, '{}', replyTo: inbox);
      client.deleteJsStream(client, inbox, streamName);

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
      // var apiPrefix = JetStreamAPIConstants.apiStreamPurgeT.replaceAll("%s", streamName);
      // String apiString = JetStreamAPIConstants.defaultAPIPrefix + apiPrefix;
      // print(apiString);
  
      // client.pubString(apiString, '{}', replyTo: inbox);
      client.purgeJsStream(client, inbox, streamName);

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

    test('testingjs', () async {
      var client = ClientJS();
      await client.connect(Uri.parse('nats://localhost:4222'),
          retryInterval: 1);

      var inbox = newInbox();
     
      // client.pubString(apiString, '{"Subjects":["foo"]}', replyTo: inbox);
      client.pub('MYVI.CAR', Uint8List.fromList('testasdasdapass'.codeUnits), replyTo: inbox);
      client.pub('MYVI.CAR', Uint8List.fromList('testasapass'.codeUnits), replyTo: inbox);
      client.pub('MYVI.CAR', Uint8List.fromList('tllenns'.codeUnits), replyTo: inbox);

        // In order to get the durable, it must go with delivery subject name. so first need to get consumer info
       var inboxSub = client.sub("_INBOX.3nfA6a88BASpbhpIBvzpKd");
        // var inboxSub = client.sub(inbox);
      inboxSub.stream.listen((m) {
        print(m.header);
        var myreceiveString =   utf8.decode(m.data);
      var mymap =  jsonDecode(myreceiveString);
      print(mymap);
      
        // m.respondString('respond');
      });
      // var receive = await inboxSub.stream.first;
      // var receiveString =   utf8.decode(receive.data);
      // var map =  jsonDecode(receiveString);
      // print(map);
     // expect(map['type'], equals('io.nats.jetstream.api.v1.stream_restore_response'));
    });

    
  });
}

