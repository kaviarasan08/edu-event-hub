import 'package:eduevent_hub/components/button.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
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
  final MobileScannerController _controller = MobileScannerController();

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
    return attendanceFunction(code);
  }

  void attendanceFunction(String code) async {
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
      _controller.stop();

      // 4️⃣ Insert attendance
      // final user = supabase.auth.currentUser;

      // show name card
      return showUserCard(userId, qrEventId, regId, code);
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

  void showUserCard(
    String userId,
    String qrEventId,
    String regId,
    String qr_code,
  ) async {
    final userData = await getUser(userId);
    String res = 'loading..';
    // 3️⃣ Check if attendance already exists
    final registrationStatus = await supabase
        .from("registrations")
        .select("status")
        .eq("ticket_qr", qr_code)
        .maybeSingle();
    print('attendance : $registrationStatus');
    // if (attendRes == null) {
    //   _showMessage('User already exist', Colors.orange);
    //   return;
    // }
    if (registrationStatus!['status'] == 'registered') {
      await supabase.from("attendance").insert({
        "registration_id": regId,
        "event_id": qrEventId,
        "scanned_by": userId,
      });
      setState(() {
        res = '✅ Attendance Marked';
      });
    }

    bool status = (registrationStatus['status'] == 'scanned') ? false : true;

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 700,
          child: Column(
            spacing: 8.0,
            mainAxisSize: MainAxisSize.max,
            children: [
              ListTile(
                leading: (userData['profile_image_url'] != null)
                    ? Container(
                        decoration: BoxDecoration(shape: BoxShape.circle),
                        child: Image.network(userData['profile_image_url']),
                      )
                    : Icon(Icons.person),
                title: Text(userData['name']),
                subtitle: Text(userData['email']),
              ),
              Text(
                (status) ? 'Attendance marked' : 'Already attendance marked',
                style: TextStyle(
                  color: (status) ? Colors.green : Colors.orange,
                ),
              ),
              LottieBuilder.asset(
                (status) ? 'assets/success.json' : 'assets/blue_allert.json',
                height: 250,
                width: 400,
              ),
              SizedBox(height: 15),
              CustomButton(
                text: 'next',
                onPressed: () {
                  _controller.start();
                  Navigator.pop(context);
                },
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
          MobileScanner(controller: _controller, onDetect: _onDetect),
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
