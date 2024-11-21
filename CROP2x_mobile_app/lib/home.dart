// // ignore_for_file: unused_local_variable, unused_field

// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'dart:typed_data';
// // ignore: unused_import
// import 'package:audioplayers/audioplayers.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:vibration/vibration.dart';

// class MyBluetoothApp extends StatefulWidget {
//   @override
//   _MyBluetoothAppState createState() => _MyBluetoothAppState();
// }

// class _MyBluetoothAppState extends State<MyBluetoothApp> {
//   BluetoothConnection? _connection;
//   BluetoothDevice? connectedDevice;
//   String latitude = '';
//   String longitude = '';
//   String currentDate = '';
//   String currentTime = '';
//   late StreamSubscription<Position> _positionStreamSubscription;
//   late Timer _timer;

//   // physical devices connection
//   final String esp32SensorMacAddress = "E4:65:B8:84:05:EA";

//   // dume device connection
//   // final String esp32SensorMacAddress = "40:91:51:FC:D1:2A";
//   StreamSubscription<Uint8List>? _dataStreamSubscription;
//   String dataBuffer = '';
//   bool isConnected = false;
//   bool isLoading = false;
//   bool soundAndVibrationCalled = false;

//   String currentId = '0';
//   String temperatureValue = '0';
//   String conductivityValue = '0';
//   String moistureValue = '0';
//   String pHValue = '0';
//   String nitrogenValue = '0';
//   String phosphorusValue = '0';
//   String potassiumValue = '0';
//   bool indicator = false;
//   bool indicatorzero = false;
//   bool isFirstZero = true;

//   bool? conductanceInRange = false;
//   bool? moistureInRange = false;
//   bool snackShownPh = true;
//   bool snackShownC = true;
//   bool snackShownM = true;

//   String addidstr = " ";
//   String addtemstr = " ";
//   String addcondstr = " ";
//   String addmoisstr = " ";
//   String addphstr = " ";
//   String addnitstr = " ";
//   String addphosstr = " ";
//   String addpotstr = " ";
//   String nitrogenvalues = " ";
//   String potasiumvalues = " ";
//   String phosphorusvalues = " ";

//   List<Map<String, String>> receivedDataList = [];
//   List recivedsnapshot = [];
//   Map<String, String> avgMap = {};
//   StreamController<String> idStream = StreamController<String>.broadcast();
//   StreamController<String> temperatureStream =
//       StreamController<String>.broadcast();
//   StreamController<String> conductivityStream =
//       StreamController<String>.broadcast();
//   StreamController<String> moistureStream =
//       StreamController<String>.broadcast();
//   StreamController<String> pHStream = StreamController<String>.broadcast();
//   StreamController<String> nitrogenStream =
//       StreamController<String>.broadcast();
//   StreamController<String> phosphorusStream =
//       StreamController<String>.broadcast();
//   StreamController<String> potassiumStream =
//       StreamController<String>.broadcast();

//   int dataCount = 0;
//   @override
//   void initState() {
//     super.initState();
//     checkBluetoothState();
//     _listenForLocationChanges();
//     _requestPermissions();
//     connectToDevice();
//     _updateDateTime(); // Initial update
//     _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
//       _updateDateTime(); // Update every second
//     });
//   }

//   Future<void> checkBluetoothState() async {
//     // isEnabled
//     bool? isOn = await FlutterBluetoothSerial.instance.isEnabled;
//     if (isOn != null && !isOn) {
//       disconnectFromDevice();
//     }
//   }

//   void performVibration(BuildContext context) {
//     try {
//       Vibration.vibrate();
//     } catch (e) {}
//   }

//   Future<void> playSound() async {
//     String url = 'sound.mp3';
//     final player = AudioPlayer();
//     await player.play(AssetSource(url));
//   }

//   void _listenForLocationChanges() {
//     _positionStreamSubscription = Geolocator.getPositionStream().listen(
//       (Position position) {
//         setState(() {
//           latitude = position.latitude.toString();
//           longitude = position.longitude.toString();
//         });
//       },
//       onError: (dynamic error) => print('Error: $error'),
//       onDone: () => print('Done!'),
//       cancelOnError: false,
//     );
//   }

//   void _updateDateTime() {
//     DateTime now = DateTime.now();
//     setState(() {
//       currentDate =
//           '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
//       currentTime =
//           '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
//     });
//   }

//   void _onDataReceived(Uint8List data) {
//     String receivedData = utf8.decode(data);
//     print('Received data: $receivedData');
//     dataBuffer += receivedData;

//     while (dataBuffer.contains('{') && dataBuffer.contains('}')) {
//       int startIndex = dataBuffer.indexOf('{');
//       int endIndex = dataBuffer.indexOf('}') + 1;

//       if (startIndex != -1 && endIndex != -1) {
//         String completeData = dataBuffer.substring(startIndex, endIndex);
//         setState(() {
//           try {
//             Map<String, dynamic> jsonData = json.decode(completeData);

//             idStream.add(jsonData['id'].toString());
//             temperatureStream.add(jsonData['t'].toString());
//             conductivityStream.add(jsonData['c'].toString());
//             moistureStream.add(jsonData['m'].toString());
//             pHStream.add(jsonData['pH'].toString());
//             nitrogenStream.add(jsonData['n'].toString());
//             phosphorusStream.add(jsonData['p'].toString());
//             potassiumStream.add(jsonData['k'].toString());

//             // Increment the data count
//             dataCount++;
//           } catch (e) {
//             print('Error parsing JSON: $e');
//           }
//         });

//         dataBuffer = dataBuffer.substring(endIndex);
//       }
//     }
//   }

//   Future<void> _requestPermissions() async {
//     await [
//       Permission.bluetooth,
//       Permission.bluetoothScan,
//       Permission.bluetoothConnect,
//       Permission.location,
//     ].request();
//   }

//   //
//   Future<void> connectToDevice() async {
//     setState(() {
//       isLoading = true;
//     });

//     try {
//       // Fetch a list of bonded Bluetooth devices
//       List<BluetoothDevice> devices =
//           await FlutterBluetoothSerial.instance.getBondedDevices();

//       // Show a dialog to let the user select a device
//       BluetoothDevice? selectedDevice = await showDialog<BluetoothDevice>(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text('Select a Bluetooth Device'),
//             content: SingleChildScrollView(
//               child: ListBody(
//                 children: devices
//                     .map((device) => ListTile(
//                           title: Text(device.name.toString()),
//                           onTap: () {
//                             Navigator.pop(context, device);
//                           },
//                         ))
//                     .toList(),
//               ),
//             ),
//           );
//         },
//       );

//       if (selectedDevice == null) {
//         throw Exception('No device selected');
//       }

//       // Establish a connection to the selected device
//       BluetoothConnection connection =
//           await BluetoothConnection.toAddress(selectedDevice.address);

//       // Set up data stream subscription
//       _dataStreamSubscription = connection.input!.listen(
//         _onDataReceived,
//         onDone: () {
//           print('Data stream closed.');
//         },
//         onError: (error) {
//           print('Data stream error: $error');
//         },
//       );

//       setState(() {
//         _connection = connection;
//         connectedDevice = selectedDevice;
//         isConnected = true;
//         isLoading = false;
//       });

//       print('Connected to the device');
//     } catch (error) {
//       print('Error connecting to the device: $error');
//     }
//   }

//   Future<void> disconnectFromDevice() async {
//     await _connection?.close();
//     setState(() {
//       _connection = null;
//       connectedDevice = null;
//     });
//   }

//   Map<String, String> average(List<Map<String, String>> list) {
//     Map<String, double> sumMap = {
//       'c': 0,
//       'k': 0,
//       'm': 0,
//       'n': 0,
//       'p': 0,
//       'pH': 0,
//       't': 0,
//     };
//     for (var map in list) {
//       map.forEach((key, value) {
//         if (sumMap.containsKey(key)) {
//           sumMap[key] = (sumMap[key] ?? 0) + (double.tryParse(value) ?? 0);
//         }
//       });
//     }

//     int length = list.length;
//     sumMap.forEach((key, value) {
//       sumMap[key] = value / length;
//     });

//     Map<String, String> avgMap = {};
//     list[0].forEach((key, value) {
//       if (sumMap.containsKey(key)) {
//         avgMap[key] = sumMap[key]?.toStringAsFixed(4) ?? "";
//       } else {
//         avgMap[key] = value;
//       }
//     });

//     return avgMap;
//   }

//   Future<bool> isConnectionAvailable(BuildContext context) async {
//     final connectivityResult = await Connectivity().checkConnectivity();

//     if (connectivityResult == ConnectivityResult.none) {
//       return false;
//     }

//     return true;
//   }

//   // void showSnackBarChangePlaceph(BuildContext context, bool below) {
//   //   ScaffoldMessenger.of(context).showSnackBar(
//   //     SnackBar(
//   //       content: Center(
//   //         // Center widget to center the text
//   //         child: Text(
//   //           below
//   //               ? 'پی ایچ کی کم ہونے کی وجہ سے اپنی جگہ تبدیل کریں'
//   //               : "پی ایچ زیادہ ہونے کی وجہ سے اپنی جگہ تبدیل کریں",
//   //           style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255)),
//   //         ),
//   //       ),
//   //       backgroundColor: Colors.red,
//   //     ),
//   //   );
//   // }

//     void showSnackBarChangePlaceph(BuildContext context, bool below) {
      
//     snackShownPh
//         ? (
         
//             ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//               content: Center(
//                 // Center widget to center the text
//                 child: Text(
//                   below
//                       ? 'پی ایچ کی کم ہونے کی وجہ سے اپنی جگہ تبدیل کریں'
//                       : "پی ایچ زیادہ ہونے کی وجہ سے اپنی جگہ تبدیل کریں",
//                   style: TextStyle(
//                       color: const Color.fromARGB(255, 255, 255, 255)),
//                 ),
//               ),
//               backgroundColor: Colors.red,
//             )),
//             snackShownPh = false
//           )
//         : null;
//   }

//   void showSnackBarChangePlacemoisture(BuildContext context, bool below) {
//     snackShownM
//         ? (
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Center(
//                   // Center widget to center the text
//                   child: Text(
//                     below
//                         ? 'نمی کی کم ہونے کی وجہ سے جگہ تبدیل کریں'
//                         : "نمی زیادہ ہونے کی وجہ سے اپنی جگہ تبدیل کریں",
//                     style: TextStyle(
//                         color: const Color.fromARGB(255, 255, 255, 255)),
//                   ),
//                 ),
//                 backgroundColor: Colors.red,
//               ),
//             ),
//             snackShownM = false
//           )
//         : null;
//   }

//   void showSnackBarChangePlaceConductivity(BuildContext context) {
//     snackShownC
//         ? (
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Center(
//                   // Center widget to center the text
//                   child: Text(
//                     'زمین بہت زیادہ کھاری ہے، براہ کرم جگہ تبدیل کریں۔',
//                     style: TextStyle(
//                         color: const Color.fromARGB(255, 255, 255, 255)),
//                   ),
//                 ),
//                 backgroundColor: Colors.red,
//               ),
//             ),
//             snackShownC = false
//           )
//         : null;
//   }

//   // void showSnackBarChangePlacemoisture(BuildContext context, bool below) {
//   //   ScaffoldMessenger.of(context).showSnackBar(
//   //     SnackBar(
//   //       content: Center(
//   //         // Center widget to center the text
//   //         child: Text(
//   //           below
//   //               ? 'نمی کی کم ہونے کی وجہ سے جگہ تبدیل کریں'
//   //               : "نمی زیادہ ہونے کی وجہ سے اپنی جگہ تبدیل کریں",
//   //           style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255)),
//   //         ),
//   //       ),
//   //       backgroundColor: Colors.red,
//   //     ),
//   //   );
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Padding(
//           padding: EdgeInsets.only(left: 45),
//           child: Text(
//             "CROP 2X",
//             style: TextStyle(
//               fontSize: 30,
//               fontWeight: FontWeight.w700,
//               color: Color.fromARGB(255, 0x00, 0x60, 0x4F),
//             ),
//           ),
//         ),
//         elevation: 0,
//         backgroundColor: Color.fromARGB(255, 0x00, 0x60, 0x4F),
//       ),
//       body: Center(
//         child: Column(
//           children: [
//             SizedBox(
//               height: 10,
//             ),
//             Row(
//               children: [
//                 Container(
//                   margin: EdgeInsets.fromLTRB(20, 0, 50, 0),
//                   child: Text(""),
//                   width: 80,
//                   height: 7,
//                   decoration: BoxDecoration(
//                     color: Color.fromARGB(255, 0x00, 0x60, 0x4F),
//                     borderRadius: BorderRadius.circular(50),
//                   ),
//                 ),
//                 SizedBox(
//                   width: 10,
//                 ),
//                 Container(
//                   margin: EdgeInsets.fromLTRB(0, 0, 50, 0),
//                   child: Text(""),
//                   width: 30,
//                   height: 7,
//                   decoration: BoxDecoration(
//                     color: Color.fromARGB(255, 0x00, 0x60, 0x4F),
//                     borderRadius: BorderRadius.circular(50),
//                   ),
//                 ),
//                 // SizedBox(width: 10,),
//                 Container(
//                   margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
//                   child: Text(""),
//                   width: 80,
//                   height: 7,
//                   decoration: BoxDecoration(
//                     color: Color.fromARGB(255, 0x00, 0x60, 0x4F),
//                     borderRadius: BorderRadius.circular(50),
//                   ),
//                 ),
//               ],
//             ),

//             SizedBox(
//               height: 10,
//             ),
//             Container(
//               //////////////main black ----------------
//               width: 350,
//               height: 600,
//               decoration: BoxDecoration(
//                 border: Border.all(
//                   // color: const Color.fromARGB(255, 0, 128, 6),
//                   color: Colors.black,
//                   width: 3, // Adjust border width here
//                 ),
//                 borderRadius:
//                     BorderRadius.circular(20), // Adjust border radius here
//               ),
//               child: Column(
//                 children: [
//                   Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       SizedBox(
//                         height: 7,
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           ElevatedButton(
//                             onPressed: connectToDevice,
//                             child: Text(
//                               'منسلک کریں',
//                               style: TextStyle(
//                                 // fontFamily: "Gilroy-Bold",
//                                 fontSize: 17,
//                                 fontWeight: FontWeight.w700,
//                                 color: Colors.white,
//                               ),
//                             ),
//                             style: ElevatedButton.styleFrom(
//                               fixedSize: Size(140, 5),
//                               // side: BorderSide(width: 2),
//                               shape: StadiumBorder(),
//                               backgroundColor:
//                                   Color.fromARGB(255, 0x00, 0x60, 0x4F),
//                             ),
//                           ),
//                           SizedBox(
//                             width: 35,
//                           ),
//                           ElevatedButton(
//                             onPressed: disconnectFromDevice,
//                             child: Text(
//                               'منقطع',
//                               style: TextStyle(
//                                 // fontFamily: "Gilroy-Bold",
//                                 fontSize: 17,
//                                 fontWeight: FontWeight.w700,
//                                 color: Colors.white,
//                               ),
//                             ),
//                             style: ElevatedButton.styleFrom(
//                               fixedSize: Size(140, 5),
//                               // side: BorderSide(width: 2),
//                               shape: StadiumBorder(),
//                               backgroundColor:
//                                   Color.fromARGB(255, 0x00, 0x60, 0x4F),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(
//                         height: 7,
//                       ),
//                       Container(
//                         width: 320,
//                         height: 40,
//                         decoration: BoxDecoration(
//                           border: Border.all(
//                             color: Color.fromARGB(255, 0x00, 0x60, 0x4F),
//                             width: 3, // Adjust border width here
//                           ),
//                           borderRadius: BorderRadius.circular(
//                               20), // Adjust border radius here
//                         ),
//                         child: Center(
//                           child: Text(
//                             textAlign: TextAlign.center,
//                             connectedDevice == null
//                                 ? 'منسلک نہیں'
//                                 : 'سے جڑا ہوا ${connectedDevice!.name}',
//                             style: TextStyle(
//                               // fontFamily: "Gilroy-Bold",
//                               fontSize: 17,
//                               fontWeight: FontWeight.w700,
//                               color: Color.fromARGB(255, 0x00, 0x60, 0x4F),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(
//                     height: 7,
//                   ),
//                   Container(
//                     padding: EdgeInsets.only(bottom: 20),
//                     //container of details ----------------------------//
//                     width: 330,
//                     height: 250,
//                     decoration: BoxDecoration(
//                       border: Border.all(
//                         color: Color.fromARGB(255, 0x00, 0x60, 0x4F),
//                         width: 3, // Adjust border width here
//                       ),
//                       borderRadius: BorderRadius.circular(
//                           20), // Adjust border radius here
//                     ),
//                     // margin: EdgeInsets.only(right: 90),
//                     child: SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Container(
//                             margin: EdgeInsets.fromLTRB(0, 0, 60, 10),
//                             child: StreamBuilder<String>(
//                               stream: idStream.stream,
//                               initialData: '',
//                               builder: (context, snapshot) {
//                                 currentId = snapshot.data ?? '';
//                                 if (snapshot.data != addidstr) {
//                                   addidstr = snapshot.data ?? '';
//                                 }

//                                 // Check if snapshot data is not empty before displaying the text
//                                 String displayText =
//                                     isConnected ? snapshot.data ?? '' : "";
//                                 TextSpan textSpan = TextSpan(
//                                   text: ' آئی ڈی ',
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 20,
//                                     color:
//                                         Color.fromARGB(255, 0x00, 0x60, 0x4F),
//                                   ),
//                                   children: [
//                                     TextSpan(
//                                       text: displayText,
//                                       style: TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 20,
//                                         color: Color.fromARGB(
//                                             255, 0x00, 0x60, 0x4F),
//                                       ),
//                                     ),
//                                   ],
//                                 );

//                                 // Use RichText to display the styled text
//                                 return RichText(
//                                   text: textSpan,
//                                 );
//                               },
//                             ),
//                           ),
//                           StreamBuilder<String>(
//                             stream: temperatureStream.stream,
//                             initialData: '',
//                             builder: (context, snapshot) {
//                               temperatureValue = snapshot.data ?? '';
//                               if (snapshot.data != addtemstr) {
//                                 addtemstr = snapshot.data ?? '';
//                               }
//                               String displayText;
//                               if (isConnected) {
//                                 displayText = snapshot.data ?? '';
//                               } else {
//                                 displayText = '';
//                               }
//                               return Info(
//                                 ': % درجہ حرارت',
//                                 displayText,
//                               );
//                             },
//                           ),
//                           // StreamBuilder<String>(
//                           //   stream: conductivityStream.stream,
//                           //   initialData: '',
//                           //   builder: (context, snapshot) {
//                           //     conductivityValue = snapshot.data ?? '';
//                           //     if (snapshot.data != addcondstr) {
//                           //       addcondstr = snapshot.data ?? '';
//                           //     }
//                           //     String displayText =
//                           //         isConnected ? (snapshot.data ?? '') : "";
//                           //     return Info(': uS/cmکٹئؤئٹئ', displayText);
//                           //   },
//                           // ),
//                           StreamBuilder<String>(
//                             stream: conductivityStream.stream,
//                             initialData: '',
//                             builder: (context, snapshot) {
//                               conductivityValue = snapshot.data ?? '';
//                               if (snapshot.data != addcondstr) {
//                                 addcondstr = snapshot.data ?? '';
//                               }
//                               Future.delayed(Duration(seconds: 5), () {
//                                 // int checkerC = int.parse(snapshot.data!);
//                                 if (int.parse(snapshot.data!) >= 0 &&
//                                     int.parse(snapshot.data!) <= 2000) {
//                                   conductanceInRange = true;
//                                 } else {
//                                   conductanceInRange = false;
//                                 }
//                                 // Future.delayed(Duration(seconds: 5), () {
//                                 if ((int.parse(snapshot.data!) < 0 ||
//                                         int.parse(snapshot.data!) > 2000) &&
//                                     snapshot.data != null &&
//                                     snapshot.data != '') {
//                                   showSnackBarChangePlaceConductivity(
//                                       context); // Call the function with context
//                                 }
//                               });
//                               // });
//                               String displayText =
//                                   isConnected ? (snapshot.data ?? '') : "";
//                               return Info(': uS/cmکٹئؤئٹئ', displayText);
//                             },
//                           ),
//                           StreamBuilder<String>(
//                             stream: moistureStream.stream,
//                             initialData: '',
//                             builder: (context, snapshot) {
//                               moistureValue = snapshot.data ?? '';
//                               if (snapshot.data != addmoisstr) {
//                                 addmoisstr = snapshot.data ?? '';
//                               }
//                               Future.delayed(Duration(seconds: 5), () {
//                                 if (int.parse(snapshot.data!) >= 20 &&
//                                     int.parse(snapshot.data!) <= 40) {
//                                   moistureInRange = true;
//                                 } else {
//                                   moistureInRange = false;
//                                 }
//                                 if ((int.parse(snapshot.data!) < 20) &&
//                                     snapshot.data != null &&
//                                     snapshot.data != '') {
//                                   showSnackBarChangePlacemoisture(context,
//                                       true); // Call the function with context
//                                 } else if ((int.parse(snapshot.data!) > 40) &&
//                                     snapshot.data != null &&
//                                     snapshot.data != '') {
//                                   showSnackBarChangePlacemoisture(context,
//                                       false); // Call the function with context
//                                 }
//                               });
//                               if (addmoisstr == "0" || addmoisstr == "") {
//                                 indicator = false;
//                                  snackShownPh = true;
//                                  snackShownC = true;
//                                  snackShownM = true;
//                               } else {
//                                 if (!indicator) {
//                                   performVibration(context);
//                                   playSound();
//                                   const duration = Duration(seconds: 3);
//                                   int counter = 1;
//                                   Timer.periodic(duration, (Timer timer) async {
//                                     counter++;
//                                     if (counter < 5) {
//                                       Map<String, String> adddatmap = {
//                                         "date": currentDate,
//                                         "time":
//                                             currentTime.replaceAll(':', '-'),
//                                         "id": addidstr,
//                                         "c": addcondstr,
//                                         "k": addpotstr,
//                                         "m": addmoisstr,
//                                         "n": addnitstr,
//                                         "p": addphosstr,
//                                         "pH": addphstr,
//                                         "t": addtemstr,
//                                         "latitude": latitude,
//                                         "longitude": longitude,
//                                       };
//                                       receivedDataList.add(adddatmap);
//                                     }
//                                     if (counter == 5) {
//                                       performVibration(context);
//                                       playSound();
//                                       avgMap = average(receivedDataList);
//                                       if (await isConnectionAvailable(
//                                           context)) {
//                                         String? deviceid = avgMap["id"];
//                                         deviceid =
//                                             deviceid?.replaceAll(' ', '');
//                                         int? realintid = int.parse(deviceid!);
//                                         String realstringid =
//                                             realintid.toString();
//                                         try {
//                                           String? date = avgMap["date"];
//                                           String? time = avgMap["time"];
//                                           time = time?.replaceAll('-', ':');
//                                           String doc1 = "$date-$time";
//                                           late DatabaseReference starDataRef =
//                                               FirebaseDatabase.instance
//                                                   .ref("realtimedevices")
//                                                   .child(realstringid)
//                                                   .child(doc1);
//                                           await starDataRef.set({
//                                             "conductivity": avgMap["c"],
//                                             "potassium": avgMap["k"],
//                                             "moisture": avgMap["m"],
//                                             "nitrogen": avgMap["n"],
//                                             "phosphor": avgMap["p"],
//                                             "pH": avgMap["pH"],
//                                             "temperature": avgMap["t"],
//                                             "longitude": avgMap["longitude"],
//                                             "latitude": avgMap["latitude"],
//                                           });
//                                           ScaffoldMessenger.of(context)
//                                               .showSnackBar(
//                                             SnackBar(
//                                               content: Text(
//                                                   'Your data has been saved on firebase!'),
//                                               duration: Duration(seconds: 2),
//                                               backgroundColor: Color.fromARGB(
//                                                   255, 0x00, 0x60, 0x4F),
//                                             ),
//                                           );
//                                         } catch (e) {
//                                           print("{e}");
//                                         }
//                                       } else {
//                                         String mapAsString1 = avgMap.toString();
//                                         writeCounter(mapAsString1, context);
//                                         print("\n");
//                                         print("\n");
//                                         print("\n");
//                                         print("\n");
//                                         print("\n");
//                                         List<Map<String, String>> counterList =
//                                             await readCounter(context);
//                                         ScaffoldMessenger.of(context)
//                                             .showSnackBar(
//                                           SnackBar(
//                                               content: Text(
//                                                   'Your data has been saved on txt!'),
//                                               duration: Duration(seconds: 2),
//                                               backgroundColor: Color.fromARGB(
//                                                   255, 0x00, 0x60, 0x4F)),
//                                         );
//                                       }
//                                     }
//                                   });
//                                   indicator = true;
//                                 }
//                               }
//                               String displayText =
//                                   isConnected ? (snapshot.data ?? '') : "";
//                               return Info(': % نمی', displayText);
//                             },
//                           ),
//                           StreamBuilder<String>(
//                             stream: pHStream.stream,
//                             initialData: '',
//                             builder: (context, snapshot) {
//                               pHValue = snapshot.data ?? '';
//                               Future.delayed(Duration(seconds: 5), () {
//                                 if ((int.parse(snapshot.data!) < 0) &&
//                                     snapshot.data != null &&
//                                     snapshot.data != '') {
//                                   showSnackBarChangePlaceph(context, true);
//                                 }
//                               });
//                               if (snapshot.data != addphstr) {
//                                 addphstr = snapshot.data ?? '';
//                               }
//                               String displayText =
//                                   isConnected ? (snapshot.data ?? '') : "";

//                               return Info(': پی ایچ', displayText);
//                             },
//                           ),
//                           StreamBuilder<String>(
//                             stream: nitrogenStream.stream,
//                             initialData: '',
//                             builder: (context, snapshot) {
//                               nitrogenValue = snapshot.data ?? '';
//                               if (snapshot.data != addnitstr) {
//                                 addnitstr = snapshot.data ?? '';
//                               }
//                               String nitrogenvalues = ' ';
//                               if (isConnected) {
//                                 final data = snapshot.data;
//                                 if (data != null) {
//                                   final parsedData = int.tryParse(data);
//                                   if (parsedData != null) {
//                                     if (parsedData < 100) {
//                                       nitrogenvalues = 'انتہائی کم';
//                                     } else if (parsedData >= 100 &&
//                                         parsedData <= 200) {
//                                       nitrogenvalues = 'کم';
//                                     } else if (parsedData >= 201 &&
//                                         parsedData <= 300) {
//                                       nitrogenvalues = 'درمیانہ';
//                                     } else if (parsedData > 300) {
//                                       nitrogenvalues = 'زیادہ';
//                                     } else {
//                                       nitrogenvalues = parsedData.toString();
//                                     }
//                                   } else {
//                                     nitrogenvalues =
//                                         data; // if parsing fails, just display the data as it is
//                                   }
//                                 } else {
//                                   nitrogenvalues = '';
//                                 }
//                               } else {
//                                 nitrogenvalues = '';
//                               }
//                               return Info(
//                                   ': mg/Kg نائٹروجن',
//                                   (conductanceInRange! && moistureInRange!)
//                                       ? nitrogenvalues
//                                       : '');
//                               // return Info(': mg/Kg نائٹروجن', nitrogenvalues);
//                             },
//                           ),
//                           StreamBuilder<String>(
//                             stream: phosphorusStream.stream,
//                             initialData: '',
//                             builder: (context, snapshot) {
//                               phosphorusValue = snapshot.data ?? '';
//                               if (snapshot.data != addphosstr) {
//                                 addphosstr = snapshot.data ?? '';
//                               }
//                               String phosphorvalues = ' ';
//                               if (isConnected) {
//                                 final data = snapshot.data;
//                                 if (data != null) {
//                                   final parsedData = int.tryParse(data);
//                                   if (parsedData != null) {
//                                     if (parsedData < 30) {
//                                       phosphorvalues = 'انتہائی کم';
//                                     } else if (parsedData >= 30 &&
//                                         parsedData <= 60) {
//                                       phosphorvalues = 'کم';
//                                     } else if (parsedData >= 61 &&
//                                         parsedData <= 90) {
//                                       phosphorvalues = 'درمیانہ';
//                                     } else if (parsedData > 91) {
//                                       phosphorvalues = 'زیادہ';
//                                     } else {
//                                       phosphorvalues = parsedData.toString();
//                                     }
//                                   } else {
//                                     phosphorvalues =
//                                         data; // if parsing fails, just display the data as it is
//                                   }
//                                 } else {
//                                   phosphorvalues = '';
//                                 }
//                               } else {
//                                 phosphorvalues = '';
//                               }
//                               return Info(
//                                   ': mg/Kg فاسفورس',
//                                   (conductanceInRange! && moistureInRange!)
//                                       ? phosphorvalues
//                                       : '');
//                               // return Info(': mg/Kg فاسفورس', phosphorvalues);
//                             },
//                           ),
//                           StreamBuilder<String>(
//                             stream: potassiumStream.stream,
//                             initialData: '',
//                             builder: (context, snapshot) {
//                               potassiumValue = snapshot.data ?? '';
//                               if (snapshot.data != addpotstr) {
//                                 addpotstr = snapshot.data ?? '';
//                               }
//                               String potashvalues = ' ';
//                               if (isConnected) {
//                                 final data = snapshot.data;
//                                 if (data != null) {
//                                   final parsedData = int.tryParse(data);
//                                   if (parsedData != null) {
//                                     if (parsedData < 80) {
//                                       potashvalues = 'انتہائی کم';
//                                     } else if (parsedData >= 80 &&
//                                         parsedData <= 160) {
//                                       potashvalues = 'کم';
//                                     } else if (parsedData >= 161 &&
//                                         parsedData <= 240) {
//                                       potashvalues = 'درمیانہ';
//                                     } else if (parsedData > 240) {
//                                       potashvalues = 'زیادہ';
//                                       // } else if (conductanceInRange!) {
//                                       //   potashvalues = '';
//                                       // }
//                                       //  else if (moistureInRange!) {
//                                       //   potashvalues = '';
//                                       // } else {
//                                       potashvalues = parsedData.toString();
//                                     }
//                                   } else {
//                                     potashvalues =
//                                         data; // if parsing fails, just display the data as it is
//                                   }
//                                 } else {
//                                   potashvalues = '';
//                                 }
//                               } else {
//                                 potashvalues = '';
//                               }

//                               return Info(
//                                   ': mg/Kg پوٹاشیم',
//                                   (conductanceInRange! && moistureInRange!)
//                                       ? potashvalues
//                                       : '');
//                               // return Info(': mg/Kg پوٹاشیم', potashvalues);
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   // Display the count of received data items
//                   Text(
//                       'Data Count: $dataCount'), //-------------------for testing
//                   SizedBox(
//                     height: 10,
//                   ),
//                   Column(
//                     children: [
//                       Container(
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               longitude,
//                               style: TextStyle(
//                                   fontSize: 17, fontWeight: FontWeight.bold),
//                             ),
//                             SizedBox(
//                               width: 10,
//                             ),
//                             Text(
//                               ": طول البلد",
//                               style: TextStyle(fontWeight: FontWeight.bold),
//                             )
//                           ],
//                         ),
//                       ),
//                       Container(
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               latitude,
//                               style: TextStyle(
//                                   fontSize: 17, fontWeight: FontWeight.bold),
//                             ),
//                             SizedBox(
//                               width: 10,
//                             ),
//                             Text(
//                               ": عرض البلد",
//                               style: TextStyle(fontWeight: FontWeight.bold),
//                             )
//                           ],
//                         ),
//                       ),
//                       Container(
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               currentDate,
//                               style: TextStyle(
//                                   fontSize: 17, fontWeight: FontWeight.bold),
//                             ),
//                             SizedBox(
//                               width: 10,
//                             ),
//                             Text(
//                               ": تاریخ",
//                               style: TextStyle(fontWeight: FontWeight.bold),
//                             )
//                           ],
//                         ),
//                       ),
//                       Container(
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               currentTime,
//                               style: TextStyle(
//                                   fontSize: 17, fontWeight: FontWeight.bold),
//                             ),
//                             SizedBox(
//                               width: 10,
//                             ),
//                             Text(
//                               ": اوقات",
//                               style: TextStyle(fontWeight: FontWeight.bold),
//                             )
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(
//                     height: 20,
//                   ),

//                   ElevatedButton(
//                     onPressed: () {
//                       Map<String, String> adddatmap = {
//                         "date": currentDate,
//                         "time": currentTime.replaceAll(':', '-'),
//                         "id": addidstr,
//                         "c": addcondstr,
//                         "k": addpotstr,
//                         "m": addmoisstr,
//                         "n": addnitstr,
//                         "p": addphosstr,
//                         "pH": addphstr,
//                         "t": addtemstr,
//                         "latitude": latitude,
//                         "longitude": longitude,
//                       };
//                       print("  hogya maping      ${adddatmap}");
//                       String mapAsString = adddatmap.toString();
//                       writeCounter(mapAsString, context);
//                     },
//                     child: Text(
//                       'محفوظ کریں۔',
//                       style: TextStyle(
//                         // fontFamily: "Gilroy-Bold",
//                         fontSize: 17,
//                         fontWeight: FontWeight.w700,
//                         color: Colors.white,
//                       ),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       fixedSize: Size(200, 5),
//                       // side: BorderSide(width: 2),
//                       shape: StadiumBorder(),
//                       backgroundColor: Color.fromARGB(255, 0x00, 0x60, 0x4F),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             //last design pattern -----------------------------
//             SizedBox(
//               height: 18,
//             ),
//             Row(
//               children: [
//                 Container(
//                   margin: EdgeInsets.fromLTRB(20, 0, 50, 0),
//                   child: Text(""),
//                   width: 80,
//                   height: 12,
//                   decoration: BoxDecoration(
//                     color: Color.fromARGB(255, 0x00, 0x60, 0x4F),
//                     borderRadius: BorderRadius.circular(50),
//                   ),
//                 ),
//                 SizedBox(
//                   width: 10,
//                 ),
//                 Container(
//                   margin: EdgeInsets.fromLTRB(0, 0, 50, 0),
//                   child: Text(""),
//                   width: 30,
//                   height: 12,
//                   decoration: BoxDecoration(
//                     color: Color.fromARGB(255, 0x00, 0x60, 0x4F),
//                     borderRadius: BorderRadius.circular(50),
//                   ),
//                 ),
//                 // SizedBox(width: 10,),
//                 Container(
//                   margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
//                   child: Text(""),
//                   width: 80,
//                   height: 12,
//                   decoration: BoxDecoration(
//                     color: Color.fromARGB(255, 0x00, 0x60, 0x4F),
//                     borderRadius: BorderRadius.circular(50),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     disconnectFromDevice();
//     idStream.close();
//     temperatureStream.close();
//     conductivityStream.close();
//     moistureStream.close();
//     pHStream.close();
//     nitrogenStream.close();
//     phosphorusStream.close();
//     potassiumStream.close();
//     _positionStreamSubscription.cancel();
//     _timer.cancel();
//     super.dispose();
//   }
// }

// Widget Info(String label, String data) {
//   return Row(
//     children: [
//       Container(
//         width: 180,
//         height: 23,
//         child: Text(
//           data,
//           style: TextStyle(
//             fontSize: 15,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         alignment: Alignment.centerRight,
//       ),
//       SizedBox(
//         width: 10,
//       ),
//       Container(
//         width: 180,
//         height: 23,
//         child: Text(
//           label,
//           style: TextStyle(
//             fontSize: 15,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         alignment: Alignment.centerLeft,
//       ),
//     ],
//   );
// }

// Future<String> get _localPath async {
//   final directory = await getApplicationDocumentsDirectory();
//   return directory.path;
// }

// Future<File> get _localFile async {
//   final path = await _localPath;
//   return File('$path/crop1.txt');
// }

// Future<void> writeCounter(String counter, BuildContext context) async {
//   try {
//     final file = await _localFile;
//     String existingContent = '';
//     if (file.existsSync()) {
//       existingContent = await file.readAsString();
//     }
//     String newContent = '$existingContent\n$counter';
//     await file.writeAsString(newContent);
//     print('File saved at: ${file.path}');
//   } catch (e) {
//     print(e);
//   }
// }

// Map<String, String> parseStringToMap(String line) {
//   try {
//     line = line
//         .replaceAll('{', '{"')
//         .replaceAll(':', '":"')
//         .replaceAll(', ', '","')
//         .replaceAll('}', '"}');
//     return Map<String, String>.from(json.decode(line));
//   } catch (e) {
//     print('Error parsing line: $e');
//     return {};
//   }
// }

// Future<List<Map<String, String>>> readCounter(BuildContext context) async {
//   try {
//     final file = await _localFile;
//     String content = await file.readAsString();
//     List<String> lines = content.split('\n');
//     List<Map<String, String>> mapsList = [];
//     for (String line in lines) {
//       try {
//         Map<String, String> map = parseStringToMap(line);
//         mapsList.add(map);
//       } catch (e) {
//         print('Error parsing line: $e');
//       }
//     }
//     return mapsList;
//   } catch (e) {
//     return [];
//   }
// }

// class data {
//   static String datalist = "realtimedata";
//   // static String datalist = avgMap["id"];
// }
