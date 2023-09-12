Map<String, dynamic> _removeNull(Map<String, dynamic> data) {
  var data2 = <String, dynamic>{};

  data.forEach((s, d) {
    if (d != null) data2[s] = d;
  });
  return data2;
}

///NATS Server Info
class Info {
  /// sever id
  String? serverId;

  /// server name
  String? serverName;

  /// server version
  String? version;

  /// protocol
  int? proto;

  /// server go version
  String? go;

  /// host
  String? host;

  /// port number
  int? port;

  /// TLS Required
  bool? tlsRequired;

  /// max payload
  int? maxPayload;

  /// nounce
  String? nonce;

  ///client id assigned by server
  int? clientId;

  //todo
  //authen required
  //tls_required
  //tls_verify
  //connect_url

  ///constructure
  Info(
      {this.serverId,
      this.serverName,
      this.version,
      this.proto,
      this.go,
      this.host,
      this.port,
      this.tlsRequired,
      this.maxPayload,
      this.nonce,
      this.clientId});

  ///constructure from json
  Info.fromJson(Map<String, dynamic> json) {
    serverId = json['server_id'];
    serverName = json['server_name'];
    version = json['version'];
    proto = json['proto'];
    go = json['go'];
    host = json['host'];
    port = json['port'];
    tlsRequired = json['tls_required'];
    maxPayload = json['max_payload'];
    nonce = json['nonce'];
    clientId = json['client_id'];
  }

  ///convert to json
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['server_id'] = serverId;
    data['server_name'] = serverName;
    data['version'] = version;
    data['proto'] = proto;
    data['go'] = go;
    data['host'] = host;
    data['port'] = port;
    data['tls_required'] = tlsRequired;
    data['max_payload'] = maxPayload;
    data['nonce'] = nonce;
    data['client_id'] = clientId;

    return _removeNull(data);
  }
}

///connection option to send to server
class ConnectOption {
  ///NATS server send +OK or not (default nats server is turn on)  this client will auto tuen off as after connect
  bool? verbose;

  ///
  bool? pedantic;

  /// TLS require or not //not implement yet
  bool? tlsRequired;

  /// Auehtnticatio Token
  String? authToken;

  /// JWT
  String? jwt;

  /// NKEY
  String? nkey;

  /// signature jwt.sig = sign(hash(jwt.header + jwt.body), private-key(jwt.issuer))(jwt.issuer is part of jwt.body)
  String? sig;

  /// username
  String? user;

  /// password
  String? pass;

  ///server name
  String? name;

  /// lang??
  String? lang;

  /// sever version
  String? version;

  /// headers
  bool? headers;

  ///protocol
  int? protocol;

  ///construcure
  ConnectOption(
      {this.verbose = false,
      this.pedantic,
      this.authToken,
      this.jwt,
      this.nkey,
      this.user,
      this.pass,
      this.tlsRequired,
      this.name,
      this.lang = 'dart',
      this.version = '0.6.0',
      this.headers = true,
      this.protocol = 1});

  ///constructure from json
  ConnectOption.fromJson(Map<String, dynamic> json) {
    verbose = json['verbose'];
    pedantic = json['pedantic'];
    tlsRequired = json['tls_required'];
    authToken = json['auth_token'];
    jwt = json['jwt'];
    nkey = json['nkey'];
    sig = json['sig'];
    user = json['user'];
    pass = json['pass'];
    name = json['name'];
    lang = json['lang'];
    version = json['version'];
    headers = json['headers'];
    protocol = json['protocol'];
  }

  ///export to json
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['verbose'] = verbose;
    data['pedantic'] = pedantic;
    data['tls_required'] = tlsRequired;
    data['auth_token'] = authToken;
    data['jwt'] = jwt;
    data['nkey'] = nkey;
    data['sig'] = sig;
    data['user'] = user;
    data['pass'] = pass;
    data['name'] = name;
    data['lang'] = lang;
    data['version'] = version;
    data['headers'] = headers;
    data['protocol'] = protocol;

    return _removeNull(data);
  }
}

class JsConsumerConfig{
  String streamName = "";
  String? name;
  ConsumerConfig config;

   JsConsumerConfig({
    required this.streamName,
    this.name,
    required this.config,
  });

  Map<String, dynamic> toJson() {
    return {
      'stream_name': streamName,
      'name': name,
      'config': config.toJson(), // Convert the inner ConsumerConfig to JSON
    };
  }
}

class ConsumerConfig {
  String? description;
  String ackPolicy = "none";
  int ackWait = 0;
  String deliverPolicy = "all";
  String? deliverSubject;
  String? deliverGroup;
  String? durableName;
  String name = "";
  String? filterSubject;
  List<String>? filterSubjects;
  bool flowControl = false;
  int heartbeat = 0;
  int maxAckPending = 0;
  int maxDeliver = 0;
  int maxWaiting = 0;
  int optStartSeq = 0;
  String replayPolicy = "instant";
  String? sampleFrequency = "";
  bool headersOnly = false;
  int maxRequestBatch = 0;
  int maxRequestExpires = 0;
  int maxRequestMaxBytes = 0;
  int inactiveThreshold = 0;
  int replicas = 0;
  bool memoryStorage = false;

    ConsumerConfig({
    this.description,
    this.ackPolicy = "none",
    this.ackWait = 0,
    this.deliverPolicy = "all",
    this.deliverSubject,
    this.deliverGroup,
    this.durableName,
    this.name = "",
    this.filterSubject,
    this.filterSubjects,
    this.flowControl = false,
    this.heartbeat = 0,
    this.maxAckPending = 0,
    this.maxDeliver = 0,
    this.maxWaiting = 0,
    this.optStartSeq = 0,
    this.replayPolicy = "instant",
    this.sampleFrequency,
    this.headersOnly = false,
    this.maxRequestBatch = 0,
    this.maxRequestExpires = 0,
    this.maxRequestMaxBytes = 0,
    this.inactiveThreshold = 0,
    this.replicas = 0,
    this.memoryStorage = false,
  });

   Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['description'] = description;
    data['ack_policy'] = ackPolicy;
    data['ack_wait'] = ackWait;
    data['delivery_policy'] = deliverPolicy;
    data['deliver_subject'] = deliverSubject;
    data['deliver_group'] = deliverGroup;
    data['durable_name'] = durableName;
    data['name'] = name;
    data['filter_subject'] = filterSubject;
    data['filter_subjects'] = filterSubjects;
    data['flow_control'] = flowControl;
    data['idle_heartbeat'] = heartbeat;
    data['max_ack_pending'] = maxAckPending;
    data['max_deliver'] = maxDeliver;
    data['max_waiting'] = maxWaiting;
    data['max_deliver'] = maxDeliver;
    data['opt_start_seq'] = optStartSeq;
    data['replay_policy'] = replayPolicy;
    data['sample_freq'] = sampleFrequency;
    data['headers_only'] = headersOnly;
    data['max_batch'] = maxRequestBatch;
    data['max_expires'] = maxRequestExpires;
    data['max_bytes'] = maxRequestMaxBytes;
    data['inactive_threshold'] = inactiveThreshold;
    data['num_replicas'] = replicas;
    data['mem_storage'] = memoryStorage;

    return _removeNull(data);
   }
}

/// Nats Exception
class NatsException implements Exception {
  /// Description of the cause of the timeout.
  final String? message;

  /// NatsException
  NatsException(this.message);

  @override
  String toString() {
    var result = 'NatsException';
    if (message != null) result = '$result: $message';
    return result;
  }
}

/// nkeys Exception
class NkeysException implements Exception {
  /// Description of the cause of the timeout.
  final String? message;

  /// NkeysException
  NkeysException(this.message);

  @override
  String toString() {
    var result = 'NkeysException';
    if (message != null) result = '$result: $message';
    return result;
  }
}
