// NAMA Rustaq - Flutter Starter (main.dart)
// Updated scaffold with download button placeholders and area separation for records

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

const COLOR_PRIMARY = Color(0xFF0D47A1);
const COLOR_ACCENT = Color(0xFF00A859);
const COLOR_BG = Color(0xFFF6F8FA);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AreaProvider()),
      ],
      child: MaterialApp(
        title: 'NAMA Rustaq',
        theme: ThemeData(
          primaryColor: COLOR_PRIMARY,
          colorScheme: ColorScheme.fromSwatch().copyWith(secondary: COLOR_ACCENT),
          scaffoldBackgroundColor: COLOR_BG,
        ),
        home: AreaSelectionPage(),
      ),
    );
  }
}

class AreaProvider extends ChangeNotifier {
  List<String> areas = [
    'RUSTAQ EMERGENCY',
    'HAZAM EMERGENCY',
    'HOQAIN EMERGENCY',
    'KHAFDI EMERGENCY',
    'AWABI EMERGENCY',
    'RUSTAQ MAINTENANCES - 1',
    'HAZAM MAINTENANCES - 2',
    'RUSTAQ ASSET SECURITY - 1',
    'HAZAM ASSET SECURITY - 1',
  ];
}

class AreaSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final areas = context.watch<AreaProvider>().areas;
    return Scaffold(
      appBar: AppBar(title: Text('NAMA ELECTRICITY DISTRIBUTION COMPANY RUSTAQ')),
      body: Column(
        children: [
          SizedBox(height: 16),
          Image.asset('assets/images/artboard2_logo.png', height: 120),
          SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(12),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 3,
              ),
              itemCount: areas.length,
              itemBuilder: (ctx, i) {
                return ElevatedButton(
                  child: Text(areas[i]),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DataEntryPage(areaName: areas[i])),
                    );
                  },
                );
              },
            ),
          ),
          Image.asset('assets/images/nama_curve.png', height: 80, fit: BoxFit.cover),
        ],
      ),
    );
  }
}

class DataEntryPage extends StatefulWidget {
  final String areaName;
  DataEntryPage({required this.areaName});

  @override
  _DataEntryPageState createState() => _DataEntryPageState();
}

class _DataEntryPageState extends State<DataEntryPage> {
  String entryType = '';
  String subType = '';
  String size = '';
  List<String> materials = [];
  String conductor = '';
  String meters = '';
  String txNo = '';
  String place = '';
  Map<String, dynamic>? location;
  List<XFile> beforeImages = [];
  List<XFile> afterImages = [];

  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage(bool isBefore) async {
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked == null) return;
    setState(() {
      if (isBefore) beforeImages.add(picked); else afterImages.add(picked);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Data Entry - ${widget.areaName}')),
      body: ListView(
        padding: EdgeInsets.all(12),
        children: [
          DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: 'Entry Type'),
            items: ['OHL', 'CABLE', 'MFP CLEARANCE']
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) => setState(() => entryType = v ?? ''),
          ),
          SizedBox(height: 8),
          TextFormField(decoration: InputDecoration(labelText: 'How many meters (MTR)'), onChanged: (v) => meters = v),
          SizedBox(height: 8),
          TextFormField(decoration: InputDecoration(labelText: 'TX No'), onChanged: (v) => txNo = v),
          SizedBox(height: 8),
          TextFormField(decoration: InputDecoration(labelText: 'Place'), onChanged: (v) => place = v),
          SizedBox(height: 8),
          ListTile(
            title: Text(location == null ? 'Pick Location' : location!['address'] ?? 'Location'),
            trailing: ElevatedButton(
              child: Text('Pick'),
              onPressed: () async {
                // Placeholder for map picker
                final result = {'lat': 23.592, 'lng': 57.428, 'address': 'Sample Location'};
                setState(() => location = result);
              },
            ),
          ),
          SizedBox(height: 12),
          Text('Before Photos'),
          Row(children: [
            for (var img in beforeImages) Image.file(File(img.path), width: 80, height: 60, fit: BoxFit.cover),
            IconButton(icon: Icon(Icons.camera_alt), onPressed: () => pickImage(true)),
          ]),
          SizedBox(height: 12),
          Text('After Photos'),
          Row(children: [
            for (var img in afterImages) Image.file(File(img.path), width: 80, height: 60, fit: BoxFit.cover),
            IconButton(icon: Icon(Icons.camera_alt), onPressed: () => pickImage(false)),
          ]),
          SizedBox(height: 20),
          ElevatedButton(onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => RecordsPage(areaName: widget.areaName)));
          }, child: Text('Go to Records')),
        ],
      ),
    );
  }
}

class RecordsPage extends StatelessWidget {
  final String areaName;
  RecordsPage({required this.areaName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Records - $areaName')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(onPressed: () {}, child: Text('Download Excel')),
                ElevatedButton(onPressed: () {}, child: Text('Download PDF')),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 5, // Placeholder for records
              itemBuilder: (ctx, i) {
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  child: ListTile(
                    title: Text('Sample Record ${i + 1}'),
                    subtitle: Text('Details here...'),
                    trailing: Icon(Icons.more_vert),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
