import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:adhara_socket_io/adhara_socket_io.dart';

void main() => runApp(MyApp());



class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  SocketIOManager manager; // gerenciador | transporter
  SocketIO io;             // emitter | listener

  bool isConnected = false; // há socket instanciado?
  String uri = '10.0.0.2:80'; // minha URI

  var toPrint; 

  @override // inicia o socket.io no start do app
  void initState() {
    super.initState();
    manager = SocketIOManager();
    initSocket();
  }

  initSocket() async {
    setState(() => isConnected = true);
    if (io == null) {
      io = await manager.createInstance(
        SocketOptions(
          uri,
          query: {
            "auth": "---", 
            "info": "new connection",
            "timestamp": DateTime.now().toString()
          },
        enableLogging: false,
        transports: [Transports.WEB_SOCKET,Transports.POLLING] //Enable required transport
        ),
      );

      io.onConnect((data) {
        ioPrint("connected..."); // console prints
        ioPrint(data);
      });
      // console prints: em caso de erro
      io.onConnectError(ioPrint);
      io.onConnectTimeout(ioPrint);
      io.onError(ioPrint);
      io.onDisconnect(ioPrint);

      io.connect();

      io.on("emiterMsg", (data){
        ioPrint("eventName");
        ioPrint(data);
      });
    }
  }

  disconnect() async {
    if (io != null) {
      await manager.clearInstance(io);
      setState(() => isConnected = false);
      print('disconnected :)');
    } else {
      print('already disconnected ');
    }
  }

  sendMessage() {
    if (io != null) {
      io.emit("emiterMsg", [{
        "sender_id": 13,
        "msg": "Olá Dartverso!",
      }]);
    }
  }

  ioPrint(data) {
    setState(() {
      if (data is Map) {
        data = json.encode(data);
      }
      print(data);
      toPrint.add(data);
    });
  }
  
  @override 
  Widget build(BuildContext context) {

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Dartverso diz \'Olá\'!'),
        ),
        body: Column(children: [
          Text('Olá!'),
        ],),
      ),
    );
  }
}
