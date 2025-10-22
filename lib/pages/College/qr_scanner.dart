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

      // 4️⃣ Insert attendance
      // final user = supabase.auth.currentUser;

      // show name card
      showUserCard(userId, qrEventId, regId);
    } catch (e) {
      _showMessage("Error: $e", Colors.red);
      print(e);
    } finally {
      setState(() => isProcessing = false);
    }
  }

  Future<Map<String, dynamic>> getUser(String userId) async {
    final res = await supabase
        .from('students')
        .select()
        .eq('user_id', userId)
        .single();
    print('Student: $res');
    return res;
  }

  void showUserCard(String userId, String qrEventId, String regId) async {
    final userData = await getUser(userId);
    String res = 'loading..';
    // 3️⃣ Check if attendance already exists
    final attendRes = await supabase
        .from("attendance")
        .select("id")
        .eq("registration_id", regId)
        .maybeSingle();

    // if (attendRes != null) {
    //   _showMessage("⚠️ Already Marked!", Colors.orange);
    //   return;
    // }
    // setState(() {
    //   res = ' ⚠️ Already Attendance Marked';
    // });
    await supabase.from("attendance").insert({
      "registration_id": regId,
      "event_id": qrEventId,
      "scanned_by": userId,
    });

    setState(() {
      res = '✅ Attendance Marked';
    });
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            spacing: 8.0,
            children: [
              ListTile(
                leading: (userData['profile_image_url'] != null)
                    ? Image.network(userData['profile_image_url'])
                    : Icon(Icons.person),
                title: Text(userData['name']),
                subtitle: Text(userData['email']),
              ),
              Text(
                (attendRes != null)
                    ? 'Already attendance marked'
                    : 'Attendance marked',
                style: TextStyle(
                  color: (attendRes != null)
                      ? Colors.orange
                      : (res == 'loading..')
                      ? Colors.grey[400]
                      : Colors.green,
                ),
              ),
            ],
          ),
        );
      },
    );

  

    // _showMessage("✅ Attendance Marked", Colors.green);
  }

  void _showMessage(String msg, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Attendance"), centerTitle: true),
      body: Stack(
        // alignment: Alignment.center,
        children: [
          MobileScanner(onDetect: _onDetect),
          if (isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          Positioned(
            top: size.height * 0.1,
            left: 40,
            right: 40,
            child: Container(
              height: 320,

              width: size.width * 0.8,
              decoration: BoxDecoration(
                border: Border.all(width: 0.8, color: Colors.white),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
