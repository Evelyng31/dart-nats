import 'dart:async';
import 'dart:typed_data';

import 'package:dart_nats/dart_nats.dart';
import 'package:dart_nats/src/clientjs.dart';
import 'package:test/test.dart';

void main() {
  group('all', () {
    test('simple', () async {
      var client = Client();
      await client.connect(Uri.parse('ws://localhost:8080'), retryInterval: 1);
      var sub = client.sub('subject1');
      client.pub('subject1', Uint8List.fromList('message1'.codeUnits));
      var msg = await sub.stream.first;
      await client.close();
      expect(String.fromCharCodes(msg.data), equals('message1'));
    });
    test('jssimple', () async {
      var client = ClientJS();
      // await client.connect(Uri.parse('nats://que.orderly.my:4222'), retryInterval: 1);
      await client.connect(Uri.parse('nats://localhost:4222'), retryInterval: 1);
      //below code is okay. We need to pass stream name
      client.pub('MYVI.CAR', Uint8List.fromList('messagewild1pass'.codeUnits));

      var sub = client.sub('MYVI.CAR');
      client.pub('MYVI.CAR', Uint8List.fromList('messagewildfailpass'.codeUnits));
      var msg = await sub.stream.first;
      print(msg);
      await client.close();
      //expect('message1', equals('message1'));
    });
    test('respond', () async {
      var server = Client();
      await server.connect(Uri.parse('ws://localhost:8080'));
      var service = server.sub('service');
      service.stream.listen((m) {
        m.respondString('respond');
      });

      var requester = Client();
      await requester.connect(Uri.parse('ws://localhost:8080'));
      var inbox = newInbox();
      var inboxSub = requester.sub(inbox);

      requester.pubString('service', 'request', replyTo: inbox);

      var receive = await inboxSub.stream.first;

      await requester.close();
      await service.close();
      expect(receive.string, equals('respond'));
    });
    // test('request', () async {
    //   var server = Client();
    //   await server.connect(Uri.parse('ws://localhost:8080'));
    //   var service = server.sub('service');
    //   unawaited(service.stream.first.then((m) {
    //     m.respond(Uint8List.fromList('respond'.codeUnits));
    //   }));

    //   var client = Client();
    //   await client.connect(Uri.parse('ws://localhost:8080'));
    //   var receive = await client.request(
    //       'service', Uint8List.fromList('request'.codeUnits));

    //   await client.close();
    //   await service.close();
    //   expect(receive.string, equals('respond'));
    // });
    // test('long message', () async {
    //   var txt =
    //       '12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890';
    //   var client = Client();
    //   await client.connect(Uri.parse('ws://localhost:8080'), retryInterval: 1);
    //   var sub = client.sub('subject1');
    //   client.pub('subject1', Uint8List.fromList(txt.codeUnits));
    //   client.pub('subject1', Uint8List.fromList(txt.codeUnits));
    //   var msg = await sub.stream.first;
    //   msg = await sub.stream.first;
    //   await client.close();
    //   expect(String.fromCharCodes(msg.data), equals(txt));
    // });
  });
}
