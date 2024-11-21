import 'dart:convert';
import 'dart:io';
import 'package:cropx/realtimedevicedata.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class splashscreen extends StatefulWidget {
  const splashscreen({super.key});
  @override
  State<splashscreen> createState() => _splashscreenState();
}

class _splashscreenState extends State<splashscreen> {
  List<Map<String, String>> receivedDataList = [];
  void adddata() async {
    print("sajid dakh abhi ${receivedDataList}");
    print("\n\n\n\n\n");

    bool allDataSaved = true; // Flag to check if all data is saved successfully

    for (var i = 0; i < receivedDataList.length; i++) {
      if (receivedDataList[i]["id"] == null) {
        print("ID is null, skipping entry at index $i");
        allDataSaved = false; // Mark as false if there's a null ID
      } else {
        String? deviceid = receivedDataList[i]["id"];
        deviceid = deviceid?.replaceAll(' ', '');

        try {
          int realintid = int.parse(deviceid!);
          String realstringid = realintid.toString();
          String? date = receivedDataList[i]["date"]?.trim();
          String? time = receivedDataList[i]["time"]?.trim();
          time = time?.replaceAll('-', ':');
          String doc1 = "$date-$time";
          doc1 = doc1.trim();
          DatabaseReference starDataRef = FirebaseDatabase.instance
              .ref("realtimedevices")
              .child(realstringid)
              .child(doc1);
          await starDataRef.set({
            "conductivity": receivedDataList[i]["c"],
            "potassium": receivedDataList[i]["k"],
            "moisture": receivedDataList[i]["m"],
            "nitrogen": receivedDataList[i]["n"],
            "phosphor": receivedDataList[i]["p"],
            "pH": receivedDataList[i]["pH"],
            "temperature": receivedDataList[i]["t"],
            "longitude": receivedDataList[i]["longitude"],
            "latitude": receivedDataList[i]["latitude"],
          });
          print("Data saved successfully for ID: $deviceid");
        } catch (e) {
          print("Error saving data for ID: $deviceid - $e");
          allDataSaved = false; // Mark as false if an error occurs during save
        }
      }
    }

    // Only clear the file and list if all data was saved successfully
    if (allDataSaved) {
      await (await _localFile).writeAsString('');
      receivedDataList.clear();
      print("Text file cleared as all data was saved successfully.");
    } else {
      print("Text file not cleared due to errors in saving data.");
    }

    print("Txt Content: ${await readCounter(context)}");
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () async {
      receivedDataList = await readCounter(context);
      adddata();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => MyBluetoothApp()));
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(
      children: [
        SizedBox(
          height: 190,
        ),
        Container(
          height: 200,
          width: 200,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(300),
              border: Border.all(width: 2, color: Colors.black)),
          child: ClipOval(
            child: Image.asset(
              ("assets/icons/icon.png"),
              height: 200,
              width: 200,
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Text(
          "CROP 2X",
          style: TextStyle(
              // color: Color.fromARGB(255, 33, 150, 70),
              color: Color.fromARGB(255, 0x00, 0x60, 0x4F),
              fontSize: 45,
              fontWeight: FontWeight.bold),
        ),
      ],
    )));
  }
}

class data {
  static String datalist = "realtimedata";
}

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<File> get _localFile async {
  final path = await _localPath;
  return File('$path/crop1.txt');
}

Map<String, String> parseStringToMap(String line) {
  try {
    line = line
        .replaceAll('{', '{"')
        .replaceAll(':', '":"')
        .replaceAll(', ', '","')
        .replaceAll('}', '"}');
    return Map<String, String>.from(json.decode(line));
  } catch (e) {
    print('Error parsing line: $e');
    return {};
  }
}

Future<List<Map<String, String>>> readCounter(BuildContext context) async {
  try {
    final file = await _localFile;
    String content = await file.readAsString();
    List<String> lines = content.split('\n');
    List<Map<String, String>> mapsList = [];
    for (String line in lines) {
      try {
        Map<String, String> map = parseStringToMap(line);
        mapsList.add(map);
      } catch (e) {
        print('Error parsing line: $e');
      }
    }
    return mapsList;
  } catch (e) {
    return [];
  }
}
