
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';


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
  
      var streamname = "MAZDA";
       ConsumerConfig config = ConsumerConfig(
        name: "checkpls"
      );
      JsConsumerConfig consumerConfig = JsConsumerConfig(
        streamName: streamname, 
        config: config);
      // var apiPrefix = JetStreamAPIConstants.apiConsumerCreateT.replaceAll("%s", streamname);
      // String apiString = JetStreamAPIConstants.defaultAPIPrefix + apiPrefix;     
      // print(apiString);

      // {\\\"stream_name\\\":\\\"MAZDA\\\",\\\
      //"config\\\":{\\\"ack_policy\\\":\\\"explicit\\\",\\\"deliver_policy\\\":\\\"all\\\",\\\
      //"durable_name\\\":\\\"MAZCARNODURABLE\\\",\\\"max_deliver\\\":-1,\\\"replay_policy\\\":\\\
      //"instant\\\",\\\"num_replicas\\\":0}}     
      // client.pubString(apiString, '{"Stream Name":"${string}", "Name":"mycodeconsumer", "Acknowledgement Policy":"explicit","Replay Policy":"instant"}', replyTo: inbox);
  // client.pubString(apiString, '{"Name":"myteststreamconsumer","Delivery Target":"mydeliverytargetagain", "Delivery Queue Group":"queuename", "Acknowledgement Policy":"explicit","Replay Policy":"instant",}', replyTo: inbox);
  //  var loadstring = '{"stream_name":"MAZDA","config":{"deliver_policy":"all","ack_policy":"none", "max_deliver":-1 ,"replay_policy":"instant","num_replicas":0}}';
  // client.pubString(apiString, loadstring, replyTo: inbox);
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
      // var apiPrefix = JetStreamAPIConstants.apiConsumerCreateWithDurableT.replaceAll("%s", string);
      // apiPrefix = apiPrefix.replaceAll("%c", consumer);
      // String apiString = JetStreamAPIConstants.defaultAPIPrefix + apiPrefix;     
      // print(apiString);
      // $JS.API.CONSUMER.CREATE.MYVI.checkrequest.MYVI.CAR     
      // var loadstring = '{"stream_name":"MYSTREAMAGAIN","config":{"durable_name":"checkterminalnofilter","deliver_policy":"all","ack_policy":"none","replay_policy":"instant","flow_control":true,"idle_heartbeat":5000000000,"deliver_subject":"checkterminalnofilter","num_replicas":0}}';
      //  var loadstring = '{"stream_name":"MYVI","config":{"durable_name":"checkterminalnofilter","deliver_policy":"all","ack_policy":"none","filter_subject":"MYVI.CAR","replay_policy":"instant","flow_control":true,"idle_heartbeat":5000000000,"deliver_subject":"_INBOX.BhXb1hBxCUSOtCTu7uLD6M","num_replicas":0}}';
      // client.pubString('\$JS.API.CONSUMER.CREATE.MYSTREAMAGAIN.checkterminalnofilter ', loadstring, replyTo: inbox);

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
      // var apiPrefix = JetStreamAPIConstants.apiConsumerCreateWithFilterSubjectT.replaceAll("%s", string);
      // apiPrefix = apiPrefix.replaceAll("%c", consumer);
      // apiPrefix = apiPrefix.replaceAll("%f", filterSubject);
      // String apiString = JetStreamAPIConstants.defaultAPIPrefix + apiPrefix;     
      // print(apiString);     
      
     // var loadstring = '{"stream_name":"MYVI","config":{"durable_name":"checkterminalwithfilter","deliver_policy":"all","ack_policy":"none","filter_subject":"MYVI.CAR","replay_policy":"instant","flow_control":true,"idle_heartbeat":5000000000,"deliver_subject":"_INBOX.BhXb1hBxCUSOtCTu7uLD6M","num_replicas":0}}';
     // client.pubString('\$JS.API.CONSUMER.CREATE.MYVI.checkterminalwithfilter.MYVI.CAR ', loadstring, replyTo: inbox);
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
      // var apiPrefix = JetStreamAPIConstants.apiConsumerListT.replaceAll("%s", string);
      // String apiString = JetStreamAPIConstants.defaultAPIPrefix + apiPrefix;     
      // print(apiString);     
      // client.pubString(apiString, '{"Name":"TESTSTREAM"}', replyTo: inbox);

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
      // var apiPrefix = JetStreamAPIConstants.apiConsumerNamesT.replaceAll("%s", string);
      // String apiString = JetStreamAPIConstants.defaultAPIPrefix + apiPrefix;     
      // print(apiString);     
      // client.pubString(apiString, '{"Name":"TESTSTREAM"}', replyTo: inbox);
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
      // var apiPrefix = JetStreamAPIConstants.apiConsumerInfoT.replaceAll("%s", string);
      // apiPrefix = apiPrefix.replaceAll("%c", consumer);
      // String apiString = JetStreamAPIConstants.defaultAPIPrefix + apiPrefix;     
      // print(apiString);     
      // client.pubString(apiString, '{}', replyTo: inbox);
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
      // var apiPrefix = JetStreamAPIConstants.apiConsumerDeleteT.replaceAll("%s", string);
      // apiPrefix = apiPrefix.replaceAll("%c", consumer);
      // String apiString = JetStreamAPIConstants.defaultAPIPrefix + apiPrefix;     
      // print(apiString);     
      // client.pubString(apiString, '{}', replyTo: inbox);
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

