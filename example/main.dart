import 'package:dart_nats/dart_nats.dart';


void main() async {
  var client = Client();
  await client.connect(Uri.parse('ws://localhost:80'));
  var sub = client.sub('subject1');
  client.pubString('subject1', 'message1');
  var data = await sub.stream.first;

  print(data.string);
  client.unSub(sub);
  await client.close();
  ///Example of ClientJS()
  // var clientjs = ClientJS();
  // await clientjs.connect(Uri.parse('nats://localhost:4222'));
  // var subjs = clientjs.sub('subject1');

  // clientjs.getJsServerInfo(clientjs, 'subject1');
  
  // var datajs = await subjs.stream.first;
  // print(datajs.string);

  // clientjs.unSub(subjs);
  // await clientjs.close();
}
