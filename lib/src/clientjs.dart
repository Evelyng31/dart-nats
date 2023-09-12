// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:typed_data';

import 'package:mutex/mutex.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'common.dart';
import 'inbox.dart';
import 'messagejs.dart';
import 'nkeys.dart';
import 'subscriptionjs.dart';

enum _ReceiveJSState {
  idle, //op=msg -> msg
  msg, //newline -> idle

}

///status of the nats client
enum jsStatus {
  /// disconnected or not connected
  disconnected,

  /// tlsHandshake
  tlsHandshake,

  /// channel layer connect wait for info connect handshake
  infoHandshake,

  ///connected to server ready
  connected,

  ///already close by close or server
  closed,

  ///automatic reconnection to server
  reconnecting,

  ///connecting by connect() method
  connecting,

  // draining_subs,
  // draining_pubs,
}

enum _ClientjsStatus {
  init,
  used,
  closed,
}
/// This class is to set Jetstream Configuration
class JSStreamConfig {
  /// set Consumer name
  String name = '';
  /// set Subject
  List<String> subjects = []; 
  /// there are 3 option - 'limits','all',
  String retention = 'limits';
  /// Set Maximum Consumer, default is unlimited
  int max_consumers = -1;
  /// Set Maximum Message per Subject, default is unlimited
  int max_msgs_per_subject = -1;
  /// Set Maximum Message, default is unlimited
  int max_msgs = -1;
  /// Set Maximum Byte, default is unlimited
  int max_bytes = -1;
  /// Set Maximum Age, default is zero
  int max_age = 0;
  /// Set Maximum Message Size, default is unlimited
  int max_msg_size = -1;
  /// Set storage place, 2 Option: 'file','memeory'
  String storage = 'file';
  /// Set Discard Policy, default is old.
  /// 2 Option: 'old','new'
  String discard = 'old';
  /// Set Number of Replication, default is One
  int num_replicas = 1;
  /// Set Duplicate Window, default below
  int duplicate_window = 120000000000;
  /// Set Sealed, default false
  bool sealed = false;
  /// Set 'Can msg be delete', default false
  bool deny_delete = false;
  /// Set 'Can msg be purge', default false
  bool deny_purge = false;
  /// Set Allow Header Rollup, default false
  bool allow_rollup_hdrs = false;
  /// Set Allow Direct, default false
  bool allow_direct = false;
  /// Set Mirrow Direct, default false
  bool mirror_direct = false;

  JSStreamConfig(
    {String name = '', 
    List<String> subjects = const [], 
    String retention = 'limits',
    int max_consumers = -1,
    int max_msgs_per_subject = -1,
    int max_msgs = -1,
    int max_bytes = -1,
    int max_age = 0,
    int max_msg_size = -1,
    String storage = 'file',
    String discard = 'old',
    int num_replicas = 1,
    int duplicate_window = 120000000000,
    bool sealed = false,
    bool deny_delete = false,
    bool deny_purge = false,
    bool allow_rollup_hdrs = false,
    bool allow_direct = false,
    bool mirror_direct = false,
    }) {
    this.name = name;
    this.subjects = subjects;
    this.retention = retention;
    this.max_consumers = max_consumers;
    this.max_msgs_per_subject = max_msgs_per_subject;
    this.max_msgs = max_msgs;
    this.max_bytes = max_bytes;
    this.max_age = max_age;
    this.max_msg_size = max_msg_size;
    this.storage = storage;
    this.discard = discard;
    this.num_replicas = num_replicas;
    this.duplicate_window = duplicate_window;
    this.sealed = sealed;
    this.deny_delete = deny_delete;
    this.deny_purge = deny_purge;
    this.allow_rollup_hdrs = allow_rollup_hdrs;
    this.allow_direct = allow_direct;
    this.mirror_direct = mirror_direct;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'subjects': subjects,
      'retention': retention,
      'max_consumers': max_consumers,
      'max_msgs_per_subject': max_msgs_per_subject,
      'max_msgs': max_msgs,
      'max_bytes': max_bytes,
      'max_age':max_age,
      'max_msg_size':max_msg_size,
      'storage':storage,
      'discard':discard,
      'num_replicas':num_replicas,
      'duplicate_window':duplicate_window,
      'sealed':sealed,
      'deny_delete':deny_delete,
      'allow_rollup_hdrs':allow_rollup_hdrs,
      'allow_direct':allow_direct,
      'mirror_direct':mirror_direct
    };
  }
}

class JetStreamAPIConstants {
  static const String defaultAPIPrefix = '\$JS.API.';
  static const String jsDomainT = '\$JS.%s.API.';
  static const String jsExtDomainT = '\$JS.%s.API';
  static const String apiAccountInfo = 'INFO';
  static const String apiConsumerCreateT = 'CONSUMER.CREATE.%s';
  static const String apiConsumerCreateWithDurableT = 'CONSUMER.CREATE.%s.%c';
  static const String apiConsumerCreateWithFilterSubjectT = 'CONSUMER.CREATE.%s.%c.%f';
  static const String apiConsumerInfoT = 'CONSUMER.INFO.%s.%c';
  // static const String apiRequestNextT = 'CONSUMER.MSG.NEXT.%s.%c';
  static const String apiConsumerDeleteT = 'CONSUMER.DELETE.%s.%c';
  static const String apiConsumerListT = 'CONSUMER.LIST.%s';
  static const String apiConsumerNamesT = 'CONSUMER.NAMES.%s';
  static const String apiStreams = 'STREAM.NAMES';
  static const String apiStreamCreateT = 'STREAM.CREATE.%s';
  static const String apiStreamInfoT = 'STREAM.INFO.%s';
  static const String apiStreamUpdateT = 'STREAM.UPDATE.%s';
  static const String apiStreamDeleteT = 'STREAM.DELETE.%s';
  static const String apiStreamPurgeT = 'STREAM.PURGE.%s';
  static const String apiStreamListT = 'STREAM.LIST';
  static const String apiStreamSnapshotT = 'STREAM.SNAPSHOT.%s';
  static const String apiStreamRestoreT = 'STREAM.RESTORE.%s';
  static const String apiMsgGetT = 'STREAM.MSG.GET.%s';
  static const String apiDirectMsgGetT = 'DIRECT.GET.%s';
  static const String apiDirectMsgGetLastBySubjectT = 'DIRECT.GET.%s.%s';
  static const String apiMsgDeleteT = 'STREAM.MSG.DELETE.%s';
  
}

class _Pubjs {
  final String? subject;
  final List<int> data;
  final String? replyTo;

  _Pubjs(this.subject, this.data, this.replyTo);
}

///NATS client
class ClientJS {
  var _ackStream = StreamController<bool>.broadcast();
  _ClientjsStatus _clientStatus = _ClientjsStatus.init;
  WebSocketChannel? _wsChannel;
  Socket? _tcpSocket;
  SecureSocket? _secureSocket;
  bool _tlsRequired = false;
  bool _retry = false;

  Info _info = Info();
  late Completer _pingCompleter;
  late Completer _connectCompleter;

  var _status = jsStatus.disconnected;

  /// true if connected
  bool get connected => _status == jsStatus.connected;

  final _statusController = StreamController<jsStatus>.broadcast();

  var _channelStream = StreamController();

  ///status of the client
  jsStatus get status => _status;

  /// accept bad certificate NOT recomend to use in production
  bool acceptBadCert = false;

  /// Stream status for status update
  Stream<jsStatus> get statusStream => _statusController.stream;

  var _connectOption = ConnectOption();

  Nkeys? _nkeys;

  /// Nkeys seed
  String? get seed => _nkeys?.seed;
  set seed(String? newseed) {
    if (newseed == null) {
      _nkeys = null;
      return;
    }
    _nkeys = Nkeys.fromSeed(newseed);
  }

  final _jsonDecoder = <Type, dynamic Function(String)>{};
  // final _jsonEncoder = <Type, String Function(Type)>{};

  /// add json decoder for type <T>
  void registerJsonDecoder<T>(T Function(String) f) {
    if (T == dynamic) {
      NatsException('can not register dyname type');
    }
    _jsonDecoder[T] = f;
  }

  /// add json encoder for type <T>
  // void registerJsonEncoder<T>(String Function(T) f) {
  //   if (T == dynamic) {
  //     NatsException('can not register dyname type');
  //   }
  //   _jsonEncoder[T] = f as String Function(Type);
  // }

  ///server info
  Info? get info => _info;

  final _subs = <int, SubscriptionJS>{};
  final _backendSubs = <int, bool>{};
  final _pubBuffer = <_Pubjs>[];

  int _ssid = 0;

  List<int> _buffer = [];
  _ReceiveJSState _receiveState = _ReceiveJSState.idle;
  String _receiveLine1 = '';
  Future _sign() async {
    if (_info.nonce != null && _nkeys != null) {
      var sig = _nkeys?.sign(utf8.encode(_info.nonce!));

      _connectOption.sig = base64.encode(sig!);
    }
  }

  ///NATS Client Constructor
  ClientJS() {
    _steamHandle();
  }

  void _steamHandle() {
    _channelStream.stream.listen((d) {
      _buffer.addAll(d);
      // org code
      // while (
      //     _receiveState == _ReceiveState.idle && _buffer.contains(13)) {
      //   _processOp();
      // }

      //Thank aktxyz for contribution
      while (_receiveState == _ReceiveJSState.idle && _buffer.contains(13)) {
        var n13 = _buffer.indexOf(13);
        var msgFull =
            String.fromCharCodes(_buffer.take(n13)).toLowerCase().trim();
        var msgList = msgFull.split(' ');

        var msgType = msgList[0];
        //print('... process $msgType ${_buffer.length}');

        if (msgType == 'msg' || msgType == 'hmsg') {
          var len = int.parse(msgList.last);
          if (len > 0 && _buffer.length < (msgFull.length + len + 4)) {
            break; // not a full payload, go around again
          }
        }

        _processOp();
      }
      // }, onDone: () {
      //   _setStatus(Status.disconnected);
      //   close();
      // }, onError: (err) {
      //   _setStatus(Status.disconnected);
      //   close();
    });
  }

  /// Connect to NATS server
  Future connect(
    Uri uri, {
    ConnectOption? connectOption,
    int timeout = 5,
    bool retry = true,
    int retryInterval = 10,
    int retryCount = 3,
  }) async {
    this._retry = retry;
    _connectCompleter = Completer();
    if (_clientStatus == _ClientjsStatus.used) {
      throw Exception(
          NatsException('client in use. must close before call connect'));
    }
    if (status != jsStatus.disconnected && status != jsStatus.closed) {
      return Future.error('Error: status not disconnected and not closed');
    }
    _clientStatus = _ClientjsStatus.used;
    if (connectOption != null) _connectOption = connectOption;
    do {
      _connectLoop(
        uri,
        timeout: timeout,
        retryInterval: retryInterval,
        retryCount: retryCount,
      );

      if (_clientStatus == _ClientjsStatus.closed || status == jsStatus.closed) {
        if (!_connectCompleter.isCompleted) {
          _connectCompleter.complete();
        }
        close();
        _clientStatus = _ClientjsStatus.closed;
        return;
      }
      if (!this._retry || retryCount != -1) {
        return _connectCompleter.future;
      }
      await for (var s in statusStream) {
        if (s == jsStatus.disconnected) {
          break;
        }
        if (s == jsStatus.closed) {
          return;
        }
      }
    } while (this._retry && retryCount == -1);
    return _connectCompleter.future;
  }

  void _connectLoop(Uri uri,
      {int timeout = 5,
      required int retryInterval,
      required int retryCount}) async {
    for (var count = 0;
        count == 0 || ((count < retryCount || retryCount == -1) && this._retry);
        count++) {
      if (count == 0) {
        _setStatus(jsStatus.connecting);
      } else {
        _setStatus(jsStatus.reconnecting);
      }

      try {
        if (_channelStream.isClosed) {
          _channelStream = StreamController();
        }
        var sucess = await _connectUri(uri, timeout: timeout);
        if (!sucess) {
          await Future.delayed(Duration(seconds: retryInterval));
          continue;
        }

        _buffer = [];

        return;
      } catch (err) {
        await close();
        if (!_connectCompleter.isCompleted) {
          _connectCompleter.completeError(err);
        }
        _setStatus(jsStatus.disconnected);
      }
    }
    if (!_connectCompleter.isCompleted) {
      _clientStatus = _ClientjsStatus.closed;
      _connectCompleter
          .completeError(NatsException('can not connect ${uri.toString()}'));
    }
  }

  Future<bool> _connectUri(Uri uri, {int timeout = 5}) async {
    try {
      if (uri.scheme == '') {
        throw Exception(NatsException('No scheme in uri'));
      }
      switch (uri.scheme) {
        case 'wss':
        case 'ws':
          try {
            _wsChannel = WebSocketChannel.connect(uri);
          } catch (e) {
            return false;
          }
          if (_wsChannel == null) {
            return false;
          }
          _setStatus(jsStatus.infoHandshake);
          _wsChannel?.stream.listen((event) {
            if (_channelStream.isClosed) return;
            _channelStream.add(event);
          }, onDone: () {
            _setStatus(jsStatus.disconnected);
          }, onError: (e) {
            close();
            throw NatsException('listen ws error: $e');
          });
          return true;
        case 'nats':
          var port = uri.port;
          if (port == 0) {
            port = 4222;
          }
          _tcpSocket = await Socket.connect(
            uri.host,
            port,
            timeout: Duration(seconds: timeout),
          );
          if (_tcpSocket == null) {
            return false;
          }
          _setStatus(jsStatus.infoHandshake);
          _tcpSocket!.listen((event) {
            if (_secureSocket == null) {
              if (_channelStream.isClosed) return;
              _channelStream.add(event);
            }
          }).onDone(() {
            _setStatus(jsStatus.disconnected);
          });
          return true;
        case 'tls':
          _tlsRequired = true;
          var port = uri.port;
          if (port == 0) {
            port = 4443;
          }
          _tcpSocket = await Socket.connect(uri.host, port,
              timeout: Duration(seconds: timeout));
          if (_tcpSocket == null) break;
          _setStatus(jsStatus.infoHandshake);
          _tcpSocket!.listen((event) {
            if (_secureSocket == null) {
              if (_channelStream.isClosed) return;
              _channelStream.add(event);
            }
          });
          return true;
        default:
          throw Exception(NatsException('schema ${uri.scheme} not support'));
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  void _backendSubscriptAll() {
    _backendSubs.clear();
    _subs.forEach((sid, s) async {
      _sub(s.subject, sid, queueGroup: s.queueGroup);
      // s.backendSubscription = true;
      _backendSubs[sid] = true;
    });
  }

  void _flushPubBuffer() {
    _pubBuffer.forEach((p) {
      _pub(p);
    });
  }

  void _processOp() async {
    ///find endline
    var nextLineIndex = _buffer.indexWhere((c) {
      if (c == 13) {
        return true;
      }
      return false;
    });
    if (nextLineIndex == -1) return;
    var line =
        String.fromCharCodes(_buffer.sublist(0, nextLineIndex)); // retest
    if (_buffer.length > nextLineIndex + 2) {
      _buffer.removeRange(0, nextLineIndex + 2);
    } else {
      _buffer = [];
    }

    ///decode operation
    var i = line.indexOf(' ');
 
    String op, data;
    if (i != -1) {
      op = line.substring(0, i).trim().toLowerCase();
      data = line.substring(i).trim();
    } else {
      op = line.trim().toLowerCase();
      data = '';
    }

    ///process operation
    switch (op) {
      case 'msg':
        _receiveState = _ReceiveJSState.msg;
        _receiveLine1 = line;
        _processMsg();
        _receiveLine1 = '';
        _receiveState = _ReceiveJSState.idle;
        break;
      case 'hmsg':
        _receiveState = _ReceiveJSState.msg;
        _receiveLine1 = line;
        _processHMsg();
        _receiveLine1 = '';
        _receiveState = _ReceiveJSState.idle;
        break;
      case 'info':
        _info = Info.fromJson(jsonDecode(data));
        if (_tlsRequired && !(_info.tlsRequired ?? false)) {
          throw Exception(NatsException('require TLS but server not required'));
        }

        if ((_info.tlsRequired ?? false) && _tcpSocket != null) {
          _setStatus(jsStatus.tlsHandshake);
          var secureSocket = await SecureSocket.secure(
            _tcpSocket!,
            onBadCertificate: (certificate) {
              if (acceptBadCert) return true;
              return false;
            },
          );

          _secureSocket = secureSocket;
          secureSocket.listen((event) {
            if (_channelStream.isClosed) return;
            _channelStream.add(event);
          });
        }

        await _sign();
        _addConnectOption(_connectOption);
        if (_connectOption.verbose == true) {
          var ack = await _ackStream.stream.first;
          if (ack) {
            _setStatus(jsStatus.connected);
          } else {
            _setStatus(jsStatus.disconnected);
          }
        } else {
          _setStatus(jsStatus.connected);
        }
        _backendSubscriptAll();
        _flushPubBuffer();
        if (!_connectCompleter.isCompleted) {
          _connectCompleter.complete();
        }
        break;
      case 'ping':
        if (status == jsStatus.connected) {
          _add('pong');
        }
        break;
      case '-err':
        // _processErr(data);
        if (_connectOption.verbose == true) {
          _ackStream.sink.add(false);
        }
        break;
      case 'pong':
        _pingCompleter.complete();
        break;
      case '+ok':
        //do nothing
        if (_connectOption.verbose == true) {
          _ackStream.sink.add(true);
        }
        break;
    }
  }

  void _processMsg() {
    var s = _receiveLine1.split(' ');
    var subject = s[1];
    var sid = int.parse(s[2]);
    String? replyTo;
    int length;
    if (s.length == 4) {
      length = int.parse(s[3]);
    } else {
      replyTo = s[3];
      length = int.parse(s[4]);
    }
    if (_buffer.length < length) return;
    var payload = Uint8List.fromList(_buffer.sublist(0, length));
    // _buffer = _buffer.sublist(length + 2);
    if (_buffer.length > length + 2) {
      _buffer.removeRange(0, length + 2);
    } else {
      _buffer = [];
    }

    if (_subs[sid] != null) {
      _subs[sid]?.add(JSMessage(subject, sid, payload, this, replyTo: replyTo));
    }
  }

  void _processHMsg() {
    var s = _receiveLine1.split(' ');
    var subject = s[1];
    var sid = int.parse(s[2]);
    String? replyTo;
    int length;
    int headerLength;
    if (s.length == 5) {
      headerLength = int.parse(s[3]);
      length = int.parse(s[4]);
    } else {
      replyTo = s[3];
      headerLength = int.parse(s[4]);
      length = int.parse(s[5]);
    }
    if (_buffer.length < length) return;
    var header = Uint8List.fromList(_buffer.sublist(0, headerLength));
    var payload = Uint8List.fromList(_buffer.sublist(headerLength, length));
    // _buffer = _buffer.sublist(length + 2);
    if (_buffer.length > length + 2) {
      _buffer.removeRange(0, length + 2);
    } else {
      _buffer = [];
    }

    if (_subs[sid] != null) {
      var msg = JSMessage(subject, sid, payload, this,
          replyTo: replyTo, header: JSHeader.fromBytes(header));
      _subs[sid]?.add(msg);
    }
  }

  /// get server max payload
  int? maxPayload() => _info.maxPayload;

  ///ping server current not implement pong verification
  Future ping() {
    _pingCompleter = Completer();
    _add('ping');
    return _pingCompleter.future;
  }

  void _addConnectOption(ConnectOption c) {
    _add('connect ' + jsonEncode(c.toJson()));
  }

  ///default buffer action for pub
  var defaultPubBuffer = true;

  ///publish by byte (Uint8List) return true if sucess sending or buffering
  ///return false if not connect
  Future<bool> pub(String? subject, Uint8List data,
      {String? replyTo, bool? buffer, JSHeader? header}) async {
    buffer ??= defaultPubBuffer;
    if (status != jsStatus.connected) {
      if (buffer) {
        _pubBuffer.add(_Pubjs(subject, data, replyTo));
        return true;
      } else {
        return false;
      }
    }

    String cmd;
    var headerByte = header?.toBytes();
    if (header == null) {
      cmd = 'pub';
    } else {
      cmd = 'hpub';
    }
    cmd += ' $subject';
    if (replyTo != null) {
      cmd += ' $replyTo';
    }
    if (headerByte != null) {
      cmd += ' ${headerByte.length}  ${headerByte.length + data.length}';
      _add(cmd);
      var dataWithHeader = headerByte.toList();
      dataWithHeader.addAll(data.toList());
      _addByte(dataWithHeader);
    } else {
      cmd += ' ${data.length}';
      _add(cmd);
      _addByte(data);
    }

    if (_connectOption.verbose == true) {
      var ack = await _ackStream.stream.first;
      return ack;
    }
    return true;
  }

  ///publish by string
  Future<bool> pubString(String subject, String str,
      {String? replyTo, bool buffer = true, JSHeader? header}) async {
    return pub(subject, utf8.encode(str) as Uint8List,
        replyTo: replyTo, buffer: buffer);
  }

  Future<bool> _pub(_Pubjs p) async {
    if (p.replyTo == null) {
      _add('pub ${p.subject} ${p.data.length}');
    } else {
      _add('pub ${p.subject} ${p.replyTo} ${p.data.length}');
    }
    _addByte(p.data);
    if (_connectOption.verbose == true) {
      var ack = await _ackStream.stream.first;
      return ack;
    }
    return true;
  }

  T Function(String) _getJsonDecoder<T>() {
    var c = _jsonDecoder[T];
    if (c == null) {
      throw NatsException('no decoder for type $T');
    }
    return c as T Function(String);
  }

  // String Function(dynamic) _getJsonEncoder(Type T) {
  //   var c = _jsonDecoder[T];
  //   if (c == null) {
  //     throw NatsException('no encoder for type $T');
  //   }
  //   return c as String Function(dynamic);
  // }

  ///subscribe to subject option with queuegroup
  SubscriptionJS<T> sub<T>(
    String subject, {
    String? queueGroup,
    T Function(String)? jsonDecoder,
  }) {
    _ssid++;

    //get registered json decoder
    if (T != dynamic && jsonDecoder == null) {
      jsonDecoder = _getJsonDecoder();
    }
    
    var s = SubscriptionJS<T>(_ssid, subject, this,
        queueGroup: queueGroup, jsonDecoder: jsonDecoder);
    _subs[_ssid] = s;
    if (status == jsStatus.connected) {
      _sub(subject, _ssid, queueGroup: queueGroup);
      // _subjs(subject, _ssid);
      _backendSubs[_ssid] = true;
    }
    return s;
  }
///subscribe to subject option with durable
   Future<SubscriptionJS<T>> subjs<T>(
    String subject, {
    bool durable = false,
    String? streamname,
    String? consumername,
  }) async {
    
    if(durable && (streamname == null || consumername == null)){
      throw Exception(NatsException("Stream Name and Consumer Name must be given when Durable set to true"));
    } 
    
    if(durable){
      var inbox = newInbox();
      var inboxSub = this.sub(inbox);
      this.getJsConsumerInfo(this, inbox, streamname!, consumername!);
      var receive = await inboxSub.stream.first;
      var receiveString =   utf8.decode(receive.data);
      var map =  jsonDecode(receiveString);
      // var configMap = jsonDecode(map['config']);
      subject = map['config']['deliver_subject'];
    }
 
  return this.sub(subject);
  }


  void _sub(String? subject, int sid, {String? queueGroup}) {
    if (queueGroup == null) {
      _add('sub $subject $sid');
    } else {
      _add('sub $subject $queueGroup $sid');
    }
  }

  ///unsubscribe
  bool unSub(SubscriptionJS s) {
    var sid = s.sid;

    if (_subs[sid] == null) return false;
    _unSub(sid);
    _subs.remove(sid);
    s.close();
    _backendSubs.remove(sid);
    return true;
  }

  ///unsubscribe by id
  bool unSubById(int sid) {
    if (_subs[sid] == null) return false;
    return unSub(_subs[sid]!);
  }

  //todo unsub with max msgs

  void _unSub(int sid, {String? maxMsgs}) {
    if (maxMsgs == null) {
      _add('unsub $sid');
    } else {
      _add('unsub $sid $maxMsgs');
    }
  }

  void _add(String str) {
    if (_wsChannel != null) {
      // if (_wsChannel?.closeCode == null) return;
      _wsChannel?.sink.add(utf8.encode(str + '\r\n'));
      return;
    } else if (_secureSocket != null) {
      _secureSocket!.add(utf8.encode(str + '\r\n'));
      return;
    } else if (_tcpSocket != null) {
      _tcpSocket!.add(utf8.encode(str + '\r\n'));
      return;
    }
    throw Exception(NatsException('no connection'));
  }

  void _addByte(List<int> msg) {
    if (_wsChannel != null) {
      _wsChannel?.sink.add(msg);
      _wsChannel?.sink.add(utf8.encode('\r\n'));
      return;
    } else if (_secureSocket != null) {
      _secureSocket?.add(msg);
      _secureSocket?.add(utf8.encode('\r\n'));
      return;
    } else if (_tcpSocket != null) {
      _tcpSocket?.add(msg);
      _tcpSocket?.add(utf8.encode('\r\n'));
      return;
    }
    throw Exception(NatsException('no connection'));
  }

  var _inboxPrefix = '_INBOX';

  /// get Inbox prefix default '_INBOX'
  set inboxPrefix(String i) {
    if (_clientStatus == _ClientjsStatus.used) {
      throw NatsException('inbox prefix can not change when connection in use');
    }
    _inboxPrefix = i;
  }

  /// set Inbox prefix default '_INBOX'
  String get inboxPrefix => _inboxPrefix;

  final _inboxs = <String, SubscriptionJS>{};
  final _mutex = Mutex();
  String? _inboxSubPrefix;
  SubscriptionJS? _inboxSub;

  /// Request will send a request payload and deliver the response message,
  /// TimeoutException on timeout.
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   await client.request('service', Uint8List.fromList('request'.codeUnits),
  ///       timeout: Duration(seconds: 2));
  /// } on TimeoutException {
  ///   timeout = true;
  /// }
  /// ```
  Future<JSMessage<T>> request<T>(
    String subj,
    Uint8List data, {
    Duration timeout = const Duration(seconds: 2),
    T Function(String)? jsonDecoder,
  }) async {
    if (!connected) {
      throw NatsException("request error: client not connected");
    }
    JSMessage resp;
    //ensure no other request
    await _mutex.acquire();
    //get registered json decoder
    if (T != dynamic && jsonDecoder == null) {
      jsonDecoder = _getJsonDecoder();
    }

    if (_inboxSubPrefix == null) {
      if (inboxPrefix == '_INBOX') {
        _inboxSubPrefix = inboxPrefix + '.' + Nuid().next();
      } else {
        _inboxSubPrefix = inboxPrefix;
      }
      _inboxSub = sub<T>(_inboxSubPrefix! + '.>', jsonDecoder: jsonDecoder);
    }
    var inbox = _inboxSubPrefix! + '.' + Nuid().next();
    var stream = _inboxSub!.stream;

    pub(subj, data, replyTo: inbox);

    try {
      do {
        resp = await stream.take(1).single.timeout(timeout);
      } while (resp.subject != inbox);
    } on TimeoutException {
      throw TimeoutException('request time > $timeout');
    } finally {
      _mutex.release();
    }
    var msg = JSMessage<T>(resp.subject, resp.sid, resp.byte, this,
        jsonDecoder: jsonDecoder);
    return msg;
  }

  /// requestString() helper to request()
  Future<JSMessage<T>> requestString<T>(
    String subj,
    String data, {
    Duration timeout = const Duration(seconds: 2),
    T Function(String)? jsonDecoder,
  }) {
    return request<T>(
      subj,
      Uint8List.fromList(data.codeUnits),
      timeout: timeout,
      jsonDecoder: jsonDecoder,
    );
  }

  void _setStatus(jsStatus newStatus) {
    _status = newStatus;
    _statusController.add(newStatus);
  }

  /// close connection and cancel all future retries
  Future forceClose() async {
    this._retry = false;
    this.close();
  }

  ///close connection to NATS server unsub to server but still keep subscription list at client
  Future close() async {
    _setStatus(jsStatus.closed);
    _backendSubs.forEach((_, s) => s = false);
    _inboxs.clear();
    await _wsChannel?.sink.close();
    _wsChannel = null;
    await _secureSocket?.close();
    _secureSocket = null;
    await _tcpSocket?.close();
    _tcpSocket = null;

    _buffer = [];
    _clientStatus = _ClientjsStatus.closed;
  }

  /// discontinue tcpConnect. use connect(uri) instead
  ///Backward compatible with 0.2.x version
  Future tcpConnect(String host,
      {int port = 4222,
      ConnectOption? connectOption,
      int timeout = 5,
      bool retry = true,
      int retryInterval = 10}) {
    return connect(
      Uri(scheme: 'nats', host: host, port: port),
      retry: retry,
      retryInterval: retryInterval,
      timeout: timeout,
      connectOption: connectOption,
    );
  }

  /// close tcp connect Only for testing
  Future<void> tcpClose() async {
    await _tcpSocket?.close();
    _setStatus(jsStatus.disconnected);
  }

  /// wait until client connected
  Future<void> waitUntilConnected() async {
    await waitUntil(jsStatus.connected);
  }

  /// wait untril status
  Future<void> waitUntil(jsStatus s) async {
    if (status == s) {
      return;
    }
    await for (var st in statusStream) {
      if (st == s) {
        break;
      }
    }
  }

  getJsServerInfo(ClientJS client,String inbox){
    client.sub(inbox);
    client.pubString('\$JS.API.INFO', '{}', replyTo: inbox);
  }

  getJsStreamList(ClientJS client,String inbox){
    var apiPrefix = JetStreamAPIConstants.apiStreamListT;
    String apiString = JetStreamAPIConstants.defaultAPIPrefix + apiPrefix;
    client.pubString(apiString, '{}', replyTo: inbox);
  }
  getJsStreamNames(ClientJS client,String inbox){
    var apiPrefix = JetStreamAPIConstants.apiStreams;
      String apiString = JetStreamAPIConstants.defaultAPIPrefix + apiPrefix;
      client.pubString(apiString, '{}', replyTo: inbox);
  }

  getJsStreamInfo(ClientJS client,String inbox, String streamname){
    var apiPrefix = JetStreamAPIConstants.apiStreamInfoT.replaceAll("%s", streamname);
      String apiString = JetStreamAPIConstants.defaultAPIPrefix + apiPrefix;
      client.pubString(apiString, '{}', replyTo: inbox);
  }
  deleteJsStream(ClientJS client,String inbox, String streamname){
     var apiPrefix = JetStreamAPIConstants.apiStreamDeleteT.replaceAll("%s", streamname);
      String apiString = JetStreamAPIConstants.defaultAPIPrefix + apiPrefix;  
      client.pubString(apiString, '{}', replyTo: inbox);
  }

  purgeJsStream(ClientJS client,String inbox, String streamname){
     var apiPrefix = JetStreamAPIConstants.apiStreamPurgeT.replaceAll("%s", streamname);
      String apiString = JetStreamAPIConstants.defaultAPIPrefix + apiPrefix;
      client.pubString(apiString, '{}', replyTo: inbox);
  }

  createJsStream(ClientJS client,String inbox, String streamname, JSStreamConfig config){
     var apiPrefix = JetStreamAPIConstants.apiStreamCreateT.replaceAll("%s", streamname);
      String apiString = JetStreamAPIConstants.defaultAPIPrefix + apiPrefix;
      Map<String, dynamic> configMap = config.toJson();
      String json = jsonEncode(configMap);
      client.pubString(apiString, '${json}', replyTo: inbox);
  }
  updateJsStream(ClientJS client,String inbox, String streamname, JSStreamConfig config){
     var apiPrefix = JetStreamAPIConstants.apiStreamUpdateT.replaceAll("%s", streamname);
      String apiString = JetStreamAPIConstants.defaultAPIPrefix + apiPrefix;
      Map<String, dynamic> configMap = config.toJson();
      String json = jsonEncode(configMap);
      client.pubString(apiString, '${json}', replyTo: inbox);
  }

  createJsConsumer(ClientJS client,String inbox, String streamname, JsConsumerConfig config){
    var apiPrefix = JetStreamAPIConstants.apiConsumerCreateT.replaceAll("%s", streamname);
      String apiString = JetStreamAPIConstants.defaultAPIPrefix + apiPrefix;     
      print(apiString);
      Map<String, dynamic> configMap = config.toJson();
      String json = jsonEncode(configMap); 
      client.pubString(apiString, '${json}', replyTo: inbox);
  }

  createJsConsumerWithDurable(ClientJS client,String inbox, String streamname,String consumername, JsConsumerConfig config){
     var apiPrefix = JetStreamAPIConstants.apiConsumerCreateWithDurableT.replaceAll("%s", streamname);
      apiPrefix = apiPrefix.replaceAll("%c", consumername);
      String apiString = JetStreamAPIConstants.defaultAPIPrefix + apiPrefix;     
      print(apiString);
      Map<String, dynamic> configMap = config.toJson();
      String json = jsonEncode(configMap); 
      client.pubString(apiString, '${json}', replyTo: inbox);
  }

  createJsConsumerWithFilter(ClientJS client,String inbox, String streamname,String consumername, String filterSubject,JsConsumerConfig config){
    var apiPrefix = JetStreamAPIConstants.apiConsumerCreateWithFilterSubjectT.replaceAll("%s", streamname);
      apiPrefix = apiPrefix.replaceAll("%c", consumername);
      apiPrefix = apiPrefix.replaceAll("%f", filterSubject);
      String apiString = JetStreamAPIConstants.defaultAPIPrefix + apiPrefix;     
      print(apiString);  
      Map<String, dynamic> configMap = config.toJson();
      String json = jsonEncode(configMap); 
      client.pubString(apiString, '${json}', replyTo: inbox);
  }

  getJsConsumerList(ClientJS client,String inbox, String streamname){
     var apiPrefix = JetStreamAPIConstants.apiConsumerListT.replaceAll("%s", streamname);
      String apiString = JetStreamAPIConstants.defaultAPIPrefix + apiPrefix;     
      print(apiString);     
      client.pubString(apiString, '{"Name":"${streamname}"}', replyTo: inbox);
  }

  getJsStreamConsumerNames(ClientJS client,String inbox, String streamname){
     var apiPrefix = JetStreamAPIConstants.apiConsumerNamesT.replaceAll("%s", streamname);
      String apiString = JetStreamAPIConstants.defaultAPIPrefix + apiPrefix;     
      print(apiString);     
      client.pubString(apiString, '{"Name":"${streamname}"}', replyTo: inbox);
  }

  getJsConsumerInfo(ClientJS client,String inbox, String streamname, String consumername){
    var apiPrefix = JetStreamAPIConstants.apiConsumerInfoT.replaceAll("%s", streamname);
      apiPrefix = apiPrefix.replaceAll("%c", consumername);
      String apiString = JetStreamAPIConstants.defaultAPIPrefix + apiPrefix;     
      print(apiString);     
      client.pubString(apiString, '{}', replyTo: inbox);
  }

  deleteJsConsumer(ClientJS client,String inbox, String streamname, String consumername ){
     var apiPrefix = JetStreamAPIConstants.apiConsumerDeleteT.replaceAll("%s", streamname);
      apiPrefix = apiPrefix.replaceAll("%c", consumername);
      String apiString = JetStreamAPIConstants.defaultAPIPrefix + apiPrefix;        
      client.pubString(apiString, '{}', replyTo: inbox);
  }
  
}

