import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class GraphPage extends StatefulWidget {
  final BluetoothConnection connection;

  const GraphPage({Key? key, required this.connection}) : super(key: key);

  @override
  State<GraphPage> createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  bool isConnected = true;
  String statusMessage = "Esperando datos...";

  @override
  void initState() {
    super.initState();
    _listenToConnection();
  }

  void _listenToConnection() {
    widget.connection.input?.listen((Uint8List data) {
      final message = String.fromCharCodes(data).trim();
      if (message.isNotEmpty) {
        setState(() {
          statusMessage = "Datos recibidos: $message";
        });
      }
    }).onDone(() {
      setState(() {
        isConnected = false;
        statusMessage = "Conexión terminada.";
      });
    });
  }

  @override
  void dispose() {
    widget.connection.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Estado de los Datos"),
        actions: [
          if (isConnected)
            IconButton(
              icon: const Icon(Icons.stop),
              onPressed: () {
                widget.connection.close();
                setState(() {
                  isConnected = false;
                  statusMessage = "Conexión cerrada manualmente.";
                });
              },
            ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            statusMessage,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

