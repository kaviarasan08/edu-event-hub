// import 'package:flutter/material.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';

// class QRScannerScreen extends StatefulWidget {
//   final String eventId;

//   const QRScannerScreen({super.key, required this.eventId});

//   @override
//   State<QRScannerScreen> createState() => _QRScannerScreenState();
// }

// class _QRScannerScreenState extends State<QRScannerScreen> {
//   bool isProcessing = false;
//   String? lastScanned;

//   void _onDetect(BarcodeCapture capture) async {
//     if (isProcessing) return;

//     final code = capture.barcodes.first.rawValue;
//     if (code == null) return;

//     setState(() {
//       isProcessing = true;
//       lastScanned = code;
//     });

//     // TODO: integrate Supabase attendance update
//     await Future.delayed(const Duration(seconds: 2));

//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Scanned QR: $code")),
//     );

//     setState(() => isProcessing = false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Scan Attendance"),
//         centerTitle: true,
//       ),
//       body: Stack(
//         children: [
//           MobileScanner(
//             onDetect: _onDetect,
//           ),
//           if (isProcessing)
//             Container(
//               color: Colors.black54,
//               child: const Center(
//                 child: CircularProgressIndicator(color: Colors.white),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
