import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'graph_page.dart'; // Página de visualización de datos

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bluetooth RFCOMM Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light, // Tema claro
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white, // Color de texto en la AppBar
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark, // Tema oscuro
        primarySwatch: Colors.blueGrey,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueGrey,
          foregroundColor: Colors.white, // Color de texto en la AppBar
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueGrey[600], // Color para botones elevados
          ),
        ),
      ),
      themeMode: ThemeMode.system, // Cambia automáticamente según el sistema
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<BluetoothDevice> devices = [];
  bool isDiscovering = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions(); // Solicitar permisos en tiempo de ejecución
  }

  // Solicitar permisos de Bluetooth y ubicación en tiempo de ejecución
  Future<void> _requestPermissions() async {
    final permissions = [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ];

    final statuses = await permissions.request();

    if (statuses.values.any((status) => status.isDenied)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Es necesario otorgar todos los permisos para continuar con la aplicación.'),
        ),
      );
    } else {
      _startDiscovery(); // Iniciar el escaneo después de otorgar permisos
    }
  }

  // Iniciar el escaneo de dispositivos Bluetooth
  void _startDiscovery() async {
    setState(() {
      isDiscovering = true;
      devices.clear();
    });

    FlutterBluetoothSerial.instance.startDiscovery().listen((result) {
      if (!devices.any((d) => d.address == result.device.address)) {
        setState(() {
          devices.add(result.device);
        });
      }
    }).onDone(() {
      setState(() {
        isDiscovering = false;
      });
    });
  }

  // Conexión al dispositivo seleccionado
  void _connectToDevice(BluetoothDevice device) async {
    try {
      final connection = await BluetoothConnection.toAddress(device.address);

      if (connection.isConnected) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Conectado exitosamente a ${device.name}')),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GraphPage(connection: connection),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al conectar con ${device.name}: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dispositivos Bluetooth"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: isDiscovering ? null : _startDiscovery,
          ),
        ],
      ),
      body: devices.isEmpty
          ? const Center(
        child: Text(
          'No se encontraron dispositivos. Inicia un nuevo escaneo.',
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView(
        children: devices.map((device) {
          return ListTile(
            title: Text(device.name ?? "Dispositivo sin nombre"),
            subtitle: Text(device.address),
            trailing: ElevatedButton(
              onPressed: () => _connectToDevice(device),
              child: const Text("Conectar"),
            ),
          );
        }).toList(),
      ),
      floatingActionButton: isDiscovering
          ? FloatingActionButton(
        onPressed: null,
        backgroundColor: Colors.grey,
        child: const CircularProgressIndicator(
          color: Colors.white,
        ),
      )
          : null,
    );
  }
}
