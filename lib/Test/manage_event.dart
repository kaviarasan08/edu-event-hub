import 'package:eduevent_hub/Test/view_event.dart';
import 'package:flutter/material.dart';

class ManageEventsScreen extends StatelessWidget {
  const ManageEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Dummy event list (later you’ll fetch from Supabase)
    final events = [
      {
        "title": "AI Workshop",
        "date": "25 Sept 2025",
        "registrations": 120,
        "attendance": "75%",
      },
      {
        "title": "Cybersecurity Symposium",
        "date": "28 Sept 2025",
        "registrations": 200,
        "attendance": "60%",
      },
      {
        "title": "Flutter Bootcamp",
        "date": "30 Sept 2025",
        "registrations": 80,
        "attendance": "90%",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Manage Events",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 3,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => EventManagementScreen(
                      title: event["title"] as String,
                      date: event['date'] as String,
                      totalSeats: 150,
                      registered: event['registrations'] as int,
                      attended: 175,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title & Date
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            event["title"]! as String,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      event["date"]! as String,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const Divider(height: 24),

                    // Stats row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _statChip(
                          icon: Icons.people,
                          label: "${event["registrations"]} registered",
                          color: theme.colorScheme.primary,
                        ),
                        _statChip(
                          icon: Icons.check_circle,
                          label: "Attendance ${event["attendance"]}",
                          color: Colors.green,
                        ),
                      ],
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

  Widget _statChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w500, color: color),
        ),
      ],
    );
  }
}
