import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BluetoothApp(),
    );
  }
}

class BluetoothApp extends StatefulWidget {
  @override
  _BluetoothAppState createState() => _BluetoothAppState();
}

class _BluetoothAppState extends State<BluetoothApp> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<ScanResult> devicesList = [];
  BluetoothDevice? connectedDevice;

  @override
  void initState() {
    super.initState();
    _startScanning();
  }

void _startScanning() {
  flutterBlue.stopScan(); // Detener el escaneo existente
  flutterBlue.startScan(timeout: Duration(seconds: 10)); // Iniciar un nuevo escaneo

  flutterBlue.scanResults.listen((results) {
    setState(() {
      devicesList = results;
    });
  });

  flutterBlue.isScanning.listen((isScanning) {
    print('Scanning: $isScanning');
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Scanner'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _startScanning,
            child: Text('Reiniciar Escaneo'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: devicesList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(devicesList[index].device.name),
                  subtitle: Text(devicesList[index].device.id.toString()),
                  trailing: connectedDevice == devicesList[index].device
                      ? ElevatedButton(
                          onPressed: () {
                            _disconnectDevice(devicesList[index].device);
                          },
                          child: Text('Desconectar'),
                        )
                      : ElevatedButton(
                          onPressed: () {
                            _connectToDevice(devicesList[index].device);
                          },
                          child: Text('Conectar'),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _connectToDevice(BluetoothDevice device) async {
    await device.connect();
    setState(() {
      connectedDevice = device;
    });
    print('Connected to ${device.name}');
  }

  void _disconnectDevice(BluetoothDevice device) async {
    await device.disconnect();
    setState(() {
      connectedDevice = null;
    });
    print('Disconnected from ${device.name}');
  }
}
