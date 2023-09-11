
import 'dart:async';
import 'dart:convert';


import 'package:dart_nats/dart_nats.dart';
import 'package:dart_nats/src/clientjs.dart';
import 'package:test/test.dart';

void main() {
  group('all', () {
    ///TODO: NEED CORRECT PAYLOAD
    test('jetstreamCreateConsumer', () async {
      var client = ClientJS();
      await client.connect(Uri.parse('nats://localhost:4222'),
          retryInterval: 1);

      var inbox = newInbox();
      var inboxSub = client.sub(inbox);
  
      var string = "TESTSTREAM";
      var apiPrefix = JetStreamAPIConstants.apiConsumerCreateT.replaceAll("%s", string);
      String apiString = JetStreamAPIConstants.defaultAPIPrefix + apiPrefix;     
      print(apiString);     
      client.pubString(apiString, '{"Stream Name":"TESTSTREAM", "Name":"mythird"}', replyTo: inbox);

      var receive = await inboxSub.stream.first;
      var receiveString =   utf8.decode(receive.data);
      var map =  jsonDecode(receiveString);
      print(map);
      expect(map['type'], equals('io.nats.jetstream.api.v1.consumer_create_response'));
    });

     ///TODO: NEED CORRECT PAYLOAD
    test('jetstreamCreateConsumerWithDurable', () async {
      var client = ClientJS();
      await client.connect(Uri.parse('nats://localhost:4222'),
          retryInterval: 1);

      var inbox = newInbox();
      var inboxSub = client.sub(inbox);
  
      var string = "TESTSTREAM";
      var consumer = "MYCONSUMER";
      var apiPrefix = JetStreamAPIConstants.apiConsumerCreateWithDurableT.replaceAll("%s", string);
      apiPrefix = apiPrefix.replaceAll("%c", consumer);
      String apiString = JetStreamAPIConstants.defaultAPIPrefix + apiPrefix;     
      print(apiString);     
      client.pubString(apiString, '{"Name":"TESTSTREAM", "Durable":"MYCONSUMER"}', replyTo: inbox);

      var receive = await inboxSub.stream.first;
      var receiveString =   utf8.decode(receive.data);
      var map =  jsonDecode(receiveString);
      print(map);
      expect(map['type'], equals('io.nats.jetstream.api.v1.consumer_create_response'));
    });

    ///TODO: NEED CORRECT PAYLOAD
    test('jetstreamCreateConsumerFilterSubject', () async {
      var client = ClientJS();
      await client.connect(Uri.parse('nats://localhost:4222'),
          retryInterval: 1);

      var inbox = newInbox();
      var inboxSub = client.sub(inbox);
  
      var string = "TESTSTREAM";
      var consumer = "MYCONSUMER";
      var filter = "myfilter";
      var apiPrefix = JetStreamAPIConstants.apiConsumerCreateWithFilterSubjectT.replaceAll("%s", string);
      apiPrefix = apiPrefix.replaceAll("%c", consumer);
      apiPrefix = apiPrefix.replaceAll("%f", filter);
      String apiString = JetStreamAPIConstants.defaultAPIPrefix + apiPrefix;     
      print(apiString);     
      client.pubString(apiString, '{"Name":"TESTSTREAM"}', replyTo: inbox);

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
  
      var string = "TESTSTREAM";
      var apiPrefix = JetStreamAPIConstants.apiConsumerListT.replaceAll("%s", string);
      String apiString = JetStreamAPIConstants.defaultAPIPrefix + apiPrefix;     
      print(apiString);     
      client.pubString(apiString, '{"Name":"TESTSTREAM"}', replyTo: inbox);

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
  
      var string = "TESTSTREAM";
      var apiPrefix = JetStreamAPIConstants.apiConsumerNamesT.replaceAll("%s", string);
      String apiString = JetStreamAPIConstants.defaultAPIPrefix + apiPrefix;     
      print(apiString);     
      client.pubString(apiString, '{"Name":"TESTSTREAM"}', replyTo: inbox);

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
  
      var string = "TESTSTREAM";
      var consumer = "myconsumer";
      var apiPrefix = JetStreamAPIConstants.apiConsumerInfoT.replaceAll("%s", string);
      apiPrefix = apiPrefix.replaceAll("%c", consumer);
      String apiString = JetStreamAPIConstants.defaultAPIPrefix + apiPrefix;     
      print(apiString);     
      client.pubString(apiString, '{}', replyTo: inbox);

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
  
      var string = "TESTSTREAM";
      var consumer = "myconsumer";
      var apiPrefix = JetStreamAPIConstants.apiConsumerDeleteT.replaceAll("%s", string);
      apiPrefix = apiPrefix.replaceAll("%c", consumer);
      String apiString = JetStreamAPIConstants.defaultAPIPrefix + apiPrefix;     
      print(apiString);     
      client.pubString(apiString, '{}', replyTo: inbox);

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

