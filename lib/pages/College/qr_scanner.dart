import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QRScannerScreen extends StatefulWidget {
  final String eventId; // event for which attendance is being taken

  const QRScannerScreen({super.key, required this.eventId});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool isProcessing = false;
  String? lastScanned;

  final supabase = Supabase.instance.client;

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (isProcessing) return;

    final code = capture.barcodes.first.rawValue;
    if (code == null) return;

    print('code: ' + code);

    setState(() {
      isProcessing = true;
      lastScanned = code;
    });

    try {
      // Parse QR value: eventId_userId_uuid
      final parts = code.split("_");
      if (parts.length < 2) {
        _showMessage("❌ Invalid QR format", Colors.red);
        return;
      }

      final qrEventId = parts[0];
      final userId = parts[1];

      print('eventid: $qrEventId');
      print('user_id: $userId');

      // 1️⃣ Ensure QR belongs to this event
      if (qrEventId != widget.eventId) {
        _showMessage("❌ Wrong Event QR", Colors.red);
        return;
      }

      // 2️⃣ Get registration
      final regRes = await supabase
          .from("registrations")
          .select("id")
          .eq("event_id", qrEventId)
          .eq("user_id", userId)
          .maybeSingle();

      if (regRes == null) {
        _showMessage("❌ No registration found", Colors.red);
        return;
      }

      final regId = regRes['id'];

      // 3️⃣ Check if attendance already exists
      final attendRes = await supabase
          .from("attendance")
          .select("id")
          .eq("registration_id", regId)
          .maybeSingle();

      if (attendRes != null) {
        _showMessage("⚠️ Already Marked!", Colors.orange);
        return;
      }

      // 4️⃣ Insert attendance
      // final user = supabase.auth.currentUser;
      await supabase.from("attendance").insert({
        "registration_id": regId,
        "event_id": qrEventId,
        "scanned_by": userId,
      });

      _showMessage("✅ Attendance Marked", Colors.green);
    } catch (e) {
      _showMessage("Error: $e", Colors.red);
      print(e);
    } finally {
      setState(() => isProcessing = false);
    }
  }

  void _showMessage(String msg, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Attendance"), centerTitle: true),
      body: Stack(
        children: [
          MobileScanner(onDetect: _onDetect),
          if (isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
