import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:flutter/material.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter_bluetooth_basic/flutter_bluetooth_basic.dart';

class Print extends StatefulWidget {
  final String val;

  const Print({this.val});

  @override
  _PrintState createState() => _PrintState();
}

class _PrintState extends State<Print> {
  PrinterBluetoothManager _printerManager = PrinterBluetoothManager();
  BluetoothManager bluetoothManager = BluetoothManager.instance;
  List<PrinterBluetooth> _devices = [];
  String _deviceMsg;

  @override
  void initState() {
    bluetoothManager.state.listen((event) {
      if (!mounted) return;
      if (event == 12) {
        print('on');
        initPrinter();
      } else if (event == 10) {
        print('off');
        setState(() => _deviceMsg = 'Bluetooth disconnect !');
      }
    });
    super.initState();
  }

  void initPrinter() {
    _printerManager.startScan(Duration(seconds: 2));
    _printerManager.scanResults.listen((val) {
      if (!mounted) return;
      setState(() => _devices = val);
      print(_devices);
      if (_devices.isEmpty) setState(() => _deviceMsg = 'No Devices !');
    });
  }

  Future<void> _startPrint(PrinterBluetooth printer) async {
    _printerManager.selectPrinter(printer);
    final result =
        await _printerManager.printTicket(await _ticket(PaperSize.mm80));
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              content: Text(result.msg),
            ));
  }

  Future<Ticket> _ticket(PaperSize paper) async {
    final ticket = Ticket(paper);
    ticket.text('Test');
    ticket.text('Thank You ',styles: PosStyles(align: PosAlign.center,bold: true));
    ticket.cut();
    return ticket;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Print'),
        centerTitle: true,
      ),
      body: _devices.isEmpty
          ? Center(
              child: Text(_deviceMsg ?? ''),
            )
          : ListView.builder(itemBuilder: (c, i) {
              return ListTile(
                leading: Icon(Icons.print),
                title: Text(_devices[i].name),
                subtitle: Text(_devices[i].address),
                onTap: () {
                  _startPrint(_devices[i]);
                },
              );
            }),
    );
  }

  @override
  void dispose() {
    _printerManager.stopScan();
    super.dispose();
  }
}
