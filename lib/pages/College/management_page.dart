import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'qr_scanner.dart';

class EventManagementPage extends StatefulWidget {
  final String eventId;
  const EventManagementPage({super.key, required this.eventId});

  @override
  State<EventManagementPage> createState() => _EventManagementPageState();
}

class _EventManagementPageState extends State<EventManagementPage> {
  final supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> fetchEventDetails() async {
    final eventRes = await supabase
        .from('events')
        .select()
        .eq('event_id', widget.eventId)
        .single();

    final regRes = await supabase
        .from('registrations')
        .select('id, user_id, ticket_qr, attendance(id)')
        .eq('event_id', widget.eventId);

    eventRes['registrations'] = regRes;
    return eventRes;
  }

  Future<void> scanAttendance(BuildContext context, String eventId) async {
    // Navigate to a scanner screen
    // final id = eventId;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => QRScannerScreen(eventId: eventId)),
    );

    if (result != null) {
      try {
        // Assume QR contains registration_id
        final registrationId = result;

        // Insert attendance record
        final response = await supabase.from('attendance').insert({
          'registration_id': registrationId,
          'event_id': eventId,
          'scanned_at': DateTime.now().toIso8601String(),
        });

        if (response.error == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Attendance marked successfully ✅")),
          );
          setState(() {}); // refresh UI
        } else {
          throw response.error!;
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
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

  Map<String, dynamic> event = {};
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Event Management")),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchEventDetails(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          event = snapshot.data!;
          String convertTo12HourFormat(String time24) {
            // Parse the 24-hour format string into DateTime
            final dt = DateFormat("HH:mm:ss").parse(time24);
            // Format into 12-hour format with AM/PM
            return DateFormat("hh:mm a").format(dt);
          }

          final registrations = event['registrations'] as List<dynamic>;
          final attendedCount = registrations
              .where((r) => (r['attendance'] as List).isNotEmpty)
              .length;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['event_name'],
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text("Location: ${event['location']}"),
                Text(
                  "Start Time: ${convertTo12HourFormat(event['start_time'])}",
                ),
                Text("End Time: ${convertTo12HourFormat(event['end_time'])}"),
                Text("Seats: ${event['total_seats']}"),
                Text("Registered: ${registrations.length}"),
                Text("Attended: $attendedCount"),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: registrations.length,
                    itemBuilder: (context, index) {
                      final reg = registrations[index];
                      final attended = (reg['attendance'] as List).isNotEmpty;

                      return FutureBuilder<Map<String, dynamic>>(
                        future: getUser(reg['user_id']),
                        builder: (context, userSnapshot) {
                          if (!userSnapshot.hasData) {
                            return const ListTile(
                              leading: CircularProgressIndicator(),
                              title: Text("Loading student..."),
                            );
                          }

                          final userData = userSnapshot.data!;
                          return ListTile(
                            leading: const Icon(Icons.person),
                            title: Text(
                              "name: ${userData['name'] ?? reg['user_id']}",
                            ),
                            subtitle: Text("email: ${userData['email']}"),
                            trailing: Icon(
                              attended ? Icons.check_circle : Icons.access_time,
                              color: attended ? Colors.green : Colors.orange,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          scanAttendance(context, event['event_id']);
        },
        label: const Text("Scan Attendance"),
        icon: const Icon(Icons.qr_code_scanner),
      ),
    );
  }
}
