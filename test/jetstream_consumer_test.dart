
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';


import 'package:dart_nats/dart_nats.dart';
import 'package:dart_nats/src/clientjs.dart';
import 'package:test/test.dart';

void main() {
  group('all', () {
    test('jetstreamCreateConsumer', () async {
      var client = ClientJS();
      await client.connect(Uri.parse('nats://localhost:4222'),
          retryInterval: 1);

      var inbox = newInbox();
      var inboxSub = client.sub(inbox);
  
      var streamname = "MAZDA";
       ConsumerConfig config = ConsumerConfig(
        name: "checkpls"
      );
      JsConsumerConfig consumerConfig = JsConsumerConfig(
        streamName: streamname, 
        config: config);

      client.createJsConsumer(client, inbox, streamname, consumerConfig);
      
      var receive = await inboxSub.stream.first;
      var receiveString =   utf8.decode(receive.data);
      var map =  jsonDecode(receiveString);
      print(map);
      expect(map['type'], equals('io.nats.jetstream.api.v1.consumer_create_response'));
    });

    test('jetstreamCreateConsumerWithDurable', () async {
      var client = ClientJS();
      await client.connect(Uri.parse('nats://localhost:4222'),
          retryInterval: 1);

      var inbox = newInbox();
      var inboxSub = client.sub(inbox);
  
      var streamname = "MYSTREAMAGAIN";
      var consumername = "checkcodetest";
      ConsumerConfig config = ConsumerConfig(
        durableName: "checkcodetest",
        flowControl: true,
        deliverSubject: "checkcodetest",
        heartbeat: 5000000000
      );
      JsConsumerConfig consumerConfig = JsConsumerConfig(
        streamName: streamname, 
        config: config);
      
      client.createJsConsumerWithDurable(client, inbox, streamname, consumername, consumerConfig);

      var receive = await inboxSub.stream.first;
      var receiveString =   utf8.decode(receive.data);
      var map =  jsonDecode(receiveString);
      print(map);
      expect(map['type'], equals('io.nats.jetstream.api.v1.consumer_create_response'));
    });

    test('jetstreamCreateConsumerFilterSubject', () async {
      var client = ClientJS();
      await client.connect(Uri.parse('nats://localhost:4222'),
          retryInterval: 1);

      var inbox = newInbox();
      var inboxSub = client.sub(inbox);
  
      var streamname = "MYVI";
      var consumername = "checkcodetest";
      var filterSubject = "MYVI.CAR";
      ConsumerConfig config = ConsumerConfig(
        durableName: "checkcodetest",
        filterSubject: filterSubject,
        flowControl: true,
        deliverSubject: "_INBOX.BhXb1hBxCUSOtCTu7uLD6M",
        heartbeat: 5000000000
      );
      JsConsumerConfig consumerConfig = JsConsumerConfig(
        streamName: streamname, 
        config: config);
    
      client.createJsConsumerWithFilter(client, inbox, streamname, consumername, filterSubject, consumerConfig);

      var receive = await inboxSub.stream.first;
      var receiveString =   utf8.decode(receive.data);
      var map =  jsonDecode(receiveString);
      print(map);
      expect(map['type'], equals('io.nats.jetstream.api.v1.consumer_create_response'));
    });

    test('jetstreamConsumerList', () async {
      var client = ClientJS();
      await client.connect(Uri.parse('nats://localhost:4222'),
          retryInterval: 1);

      var inbox = newInbox();
      var inboxSub = client.sub(inbox);
  
      var streamname = "TESTSTREAM";

      client.getJsConsumerList(client, inbox, streamname);

      var receive = await inboxSub.stream.first;
      var receiveString =   utf8.decode(receive.data);
      var map =  jsonDecode(receiveString);
      print(map);
      expect(map['type'], equals('io.nats.jetstream.api.v1.consumer_list_response'));
    });

    test('jetstreamConsumerNames', () async {
      var client = ClientJS();
      await client.connect(Uri.parse('nats://localhost:4222'),
          retryInterval: 1);

      var inbox = newInbox();
      var inboxSub = client.sub(inbox);
  
      var streamname = "TESTSTREAM";
 
      client.getJsStreamConsumerNames(client, inbox, streamname);

      var receive = await inboxSub.stream.first;
      var receiveString =   utf8.decode(receive.data);
      var map =  jsonDecode(receiveString);
      print(map);
      expect(map['type'], equals('io.nats.jetstream.api.v1.consumer_names_response'));
    });

    test('jetstreamConsumerInfo', () async {
      var client = ClientJS();
      await client.connect(Uri.parse('nats://localhost:4222'),
          retryInterval: 1);

      var inbox = newInbox();
      var inboxSub = client.sub(inbox);
  
      var streamname = "TESTSTREAM";
      var consumername = "myconsumer";
    
      client.getJsConsumerInfo(client, inbox, streamname, consumername);

      var receive = await inboxSub.stream.first;
      var receiveString =   utf8.decode(receive.data);
      var map =  jsonDecode(receiveString);
      print(map);
      expect(map['type'], equals('io.nats.jetstream.api.v1.consumer_info_response'));
    });

    test('jetstreamDeleteConsumer', () async {
      var client = ClientJS();
      await client.connect(Uri.parse('nats://localhost:4222'),
          retryInterval: 1);

      var inbox = newInbox();
      var inboxSub = client.sub(inbox);
  
      var streamname = "MYVI";
      var consumername = "checkcodetest";
    
      client.deleteJsConsumer(client, inbox, streamname, consumername);
      var receive = await inboxSub.stream.first;
      var receiveString =   utf8.decode(receive.data);
      var map =  jsonDecode(receiveString);
      print(map);
      expect(map['type'], equals('io.nats.jetstream.api.v1.consumer_delete_response'));
    });

    // test('jetstreamConsumerMsgNext', () async {
    //   var client = ClientJS();
    //   await client.connect(Uri.parse('nats://localhost:4222'),
    //       retryInterval: 1);

    //   var inbox = newInbox();
    //   var inboxSub = client.sub(inbox);
  
    //   var string = "TESTSTREAM";
    //   var consumer = "MYCONSUMER";
    //   var apiPrefix = JetStreamAPIConstants.apiRequestNextT.replaceAll("%s", string);
    //   apiPrefix = apiPrefix.replaceAll("%c", consumer);
    //   String apiString = JetStreamAPIConstants.defaultAPIPrefix + apiPrefix;     
    //   print(apiString);     
    //   client.pubString(apiString, '{}', replyTo: inbox);

    //   var receive = await inboxSub.stream.first;
    //   var receiveString =   utf8.decode(receive.data);
    //   var map =  jsonDecode(receiveString);
    //   print(map);
    //   expect(map['type'], equals('io.nats.jetstream.api.v1.consumer_delete_response'));
    // });

   
  });
}

