import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyRegistrationsPage extends StatefulWidget {
  const MyRegistrationsPage({super.key});
  @override
  _MyRegistrationsPageState createState() {
    return _MyRegistrationsPageState();
  }
  
}

class _MyRegistrationsPageState extends State<MyRegistrationsPage> {
  final supabase = Supabase.instance.client;
  List<dynamic> activeRegistrations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadRegistrations();
  }

  Future<void> loadRegistrations() async {
    try {
      final userId = supabase.auth.currentUser!.id;

      final response = await supabase
          .from('registrations')
          .select(
            '*, events(event_name, location, start_date, start_time, end_time, start_day)',
          )
          .eq('user_id', userId);

      if (response.isEmpty) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final now = DateTime.now();
      List<dynamic> filtered = [];

      for (var reg in response) {
        final event = reg['events'];

        if (event != null) {
          final DateTime eventDate = DateTime.parse(event['start_date']);
          final String eTime = event['end_time'];
          List<String> endParts = eTime.split(":");

          DateTime endDateTime = DateTime(
            eventDate.year,
            eventDate.month,
            eventDate.day,
            int.parse(endParts[0]),
            int.parse(endParts[1]),
          );

          // ✅ Keep only events that have not yet ended
          if (endDateTime.isAfter(now)) {
            filtered.add(reg);
          }
        }
      }

      if (mounted) {
        setState(() {
          activeRegistrations = filtered;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading registrations: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void zoomQr(
    String eventName,
    String location,
    String qrCode,
    String startTime,
    String endTime,
    String status,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(16.0),

          // height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(eventName, style: Theme.of(context).textTheme.titleLarge),
              Text("📍 $location"),
              // Text(
              //   "📆 ${event['start_date']} (Day: ${event['start_day']})",
              // ),
              const SizedBox(height: 12),
              Center(child: QrImageView(data: qrCode, size: 200)),
              const SizedBox(height: 8),
              Text("Status: $status"),
              Text("⏰ $startTime to $endTime"),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Registrations")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : (activeRegistrations.isEmpty)
          ? const Center(
              child: Text(
                "You have no active event registrations right now.",
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              itemCount: activeRegistrations.length,
              itemBuilder: (context, index) {
                final reg = activeRegistrations[index];
                final event = reg['events'];

                return InkWell(
                  onTap: () {
                    zoomQr(
                      event['event_name'],
                      event['location'],
                      reg['ticket_qr'],
                      event['start_time'],
                      event['end_time'],
                      reg['status'],
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.all(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event['event_name'],
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text("📍 ${event['location']}"),
                          Text(
                            "📆 ${event['start_date']} (Day: ${event['start_day']})",
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: QrImageView(
                              data: reg['ticket_qr'],
                              size: 200,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text("Status: ${reg['status']}"),
                          Text(
                            "⏰ ${event['start_time']} to ${event['end_time']}",
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
