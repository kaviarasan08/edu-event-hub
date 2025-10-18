import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../Events Screen/event_stepper.dart';
import 'management_page.dart';

class OrganizerDashboard extends StatefulWidget {
  final String organizerId;
  const OrganizerDashboard({super.key, required this.organizerId});

  @override
  State<OrganizerDashboard> createState() => _OrganizerDashboardState();
}

class _OrganizerDashboardState extends State<OrganizerDashboard> {
  final supabase = Supabase.instance.client;
  String image_url = 'empty';

  Future<List<Map<String, dynamic>>> fetchEvents() async {
    final res = await supabase
        .from('events')
        .select()
        .eq('college_id', widget.organizerId)
        .order('start_date', ascending: true);
    print(' event_id : ${res[0]['event_id']}');
    getImage(res[0]['event_id']);

    return (res as List).map((e) => e as Map<String, dynamic>).toList();
  }

  Future<void> getImage(String eventId) async {
    final image = await supabase
        .from('event_images')
        .select('image_url')
        .eq('event_id', eventId);
    print('image_url : $image');

    setState(() {
      image_url = image[0]['image_url'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Organizer Dashboard")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchEvents(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final events = snapshot.data!;
          if (events.isEmpty) {
            return const Center(child: Text("No events created yet."));
          }

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                margin: const EdgeInsets.all(12),
                child: ListTile(
                  leading: image_url != 'empty'
                      ? Image.network(image_url, width: 60, fit: BoxFit.cover)
                      : const Icon(Icons.event),
                  title: Text(event['event_name']),
                  subtitle: Text(
                    "${event['location']} • ${DateTime.parse(event['start_date']).toString().split(" ")[0]}",
                  ),
                  trailing: ElevatedButton(
                    child: const Text("Manage"),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              EventManagementPage(eventId: event['event_id']),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to Create Event Page
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => EventStepperPage(collegeId: widget.organizerId),
            ),
          );
        },
        label: const Text("Create Event"),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
