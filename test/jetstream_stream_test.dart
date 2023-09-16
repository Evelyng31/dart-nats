import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dart_nats/dart_nats.dart';
import 'package:test/test.dart';

void main() { 
  group('all', () {
    test('jetstreamInfo', () async {
      var client = ClientJS();
      await client.connect(Uri.parse('nats://localhost:4222'),
          retryInterval: 1);

      var inbox = newInbox();
      var inboxSub = client.sub(inbox);
    
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
  
      client.purgeJsStream(client, inbox, streamName);

      var receive = await inboxSub.stream.first;
      var receiveString =   utf8.decode(receive.data);
      var map =  jsonDecode(receiveString);
      print(map);
      expect(map['type'], equals('io.nats.jetstream.api.v1.stream_purge_response'));
    });

    /// TODO: CHECK CONFIG TO DELETE SINGLE MSG
    // test('jetstreamDeleteStreamMsg', () async {
    //   var client = ClientJS();
    //   await client.connect(Uri.parse('nats://localhost:4222'),
    //       retryInterval: 1);

    //   var inbox = newInbox();
    //   var inboxSub = client.sub(inbox);

    //   var streamName = "MYSTREAM";
    //   var apiPrefix = JetStreamAPIConstants.apiMsgDeleteT.replaceAll("%s", streamName);
    //   String apiString = JetStreamAPIConstants.defaultAPIPrefix + apiPrefix;
    //   print(apiString);
  
    //   client.pubString(apiString, '{}', replyTo: inbox);

    //   var receive = await inboxSub.stream.first;
    //   var receiveString =   utf8.decode(receive.data);
    //   var map =  jsonDecode(receiveString);
    //   print(map);
    //   //expect(map['type'], equals('io.nats.jetstream.api.v1.stream_msg_delete_response'));
    // });

/// TODO: CHECK CONFIG TO GET SINGLE MSG
    // test('jetstreamGetStreamMsg', () async {
    //   var client = ClientJS();
    //   await client.connect(Uri.parse('nats://localhost:4222'),
    //       retryInterval: 1);

    //   var inbox = newInbox();
    //   var inboxSub = client.sub(inbox);

    //   var streamName = "MYSTREAM";
    //   var apiPrefix = JetStreamAPIConstants.apiMsgGetT.replaceAll("%s", streamName);
    //   String apiString = JetStreamAPIConstants.defaultAPIPrefix + apiPrefix;
    //   print(apiString);
  
    //   client.pubString(apiString, '{}', replyTo: inbox);

    //   var receive = await inboxSub.stream.first;
    //   var receiveString =   utf8.decode(receive.data);
    //   var map =  jsonDecode(receiveString);
    //   print(map);
    //   //expect(map['type'], equals('io.nats.jetstream.api.v1.stream_msg_get_response'));
    // });
/// TODO: CHECK CONFIG TO DO STREAM SNAPSHOT
    //  test('jetstreamStreamSnapshot', () async {
    //   var client = ClientJS();
    //   await client.connect(Uri.parse('nats://localhost:4222'),
    //       retryInterval: 1);

    //   var inbox = newInbox();
    //   var inboxSub = client.sub(inbox);

    //   var streamName = "MYSTREAM";
    //   var apiPrefix = JetStreamAPIConstants.apiStreamSnapshotT.replaceAll("%s", streamName);
    //   String apiString = JetStreamAPIConstants.defaultAPIPrefix + apiPrefix;
    //   print(apiString);
  
    //   client.pubString(apiString, '{}', replyTo: inbox);

    //   var receive = await inboxSub.stream.first;
    //   var receiveString =   utf8.decode(receive.data);
    //   var map =  jsonDecode(receiveString);
    //   print(map);
    //   //expect(map['type'], equals('io.nats.jetstream.api.v1.stream_snapshot_response'));
    // });

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

    test('testSubscribingjs', () async { 
      var client = ClientJS();
      await client.connect(Uri.parse('nats://localhost:4222'), retryInterval: 1);
      //below code is okay. We need to pass stream name
       client.pub('DEMO_CUSTOMERS.CHANGES.SANDBOXHQ', Uint8List.fromList('messagewild1pass'.codeUnits));
       client.pub('DEMO_CUSTOMERS.CHANGES.SANDBOXHQ', Uint8List.fromList('messagewild1pass1'.codeUnits));
       client.pub('DEMO_CUSTOMERS.CHANGES.SANDBOXHQ', Uint8List.fromList('messagewild1pass23'.codeUnits));
    
      //  var sub = await client.subjs('MYVI.CAR', durable: true, streamname: "MYVI", consumername: "checkrequest");
      var sub = await client.subjs('DEMO_CUSTOMERS.CHANGES.SANDBOXHQ',durable: true, streamname:'DEMO_CUSTOMERS',consumername:'devicetwo');
       sub.stream.listen((event) {
          print('CC:${event.string}');
        });

      // client.pub('ORDERS.MONITOR', Uint8List.fromList('listening 1'.codeUnits));
      // client.pub('ORDERS.MONITOR', Uint8List.fromList('listetning 2'.codeUnits));

     
      await Future.delayed(Duration(seconds: 2));
    
    });    
  });      
}

