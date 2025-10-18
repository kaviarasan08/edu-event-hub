import 'dart:async';
import 'package:eduevent_hub/Service/authentication.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class EventDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> event;
  final String eventUrl;

  const EventDetailsScreen({
    super.key,
    required this.event,
    required this.eventUrl,
  });

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  late Timer _timer;
  Duration _timeLeft = Duration.zero;
  final supabase = Supabase.instance.client;
  int remainingSeats = 0;
  bool isRegistered = false;

  @override
  void initState() {
    super.initState();
    checkUserRegistration();
    _calculateTimeLeft();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _calculateTimeLeft(),
    );

    getRemainingSeats();
  }

  void _calculateTimeLeft() {
    final now = DateTime.now();
    final eventTime = DateTime.parse(widget.event["start_date"]);
    setState(() {
      _timeLeft = eventTime.difference(now);
      if (_timeLeft.isNegative) {
        _timeLeft = Duration.zero;
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String formatDuration(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    return "${days}d ${hours.toString().padLeft(2, '0')}h "
        "${minutes.toString().padLeft(2, '0')}m "
        "${seconds.toString().padLeft(2, '0')}s";
  }

  Future<void> registerForEvent(String eventId, String userId) async {
    try {
      final ticketQr = "${eventId}_${userId}_${const Uuid().v4()}";

      final res = await supabase.from('registrations').insert({
        'event_id': eventId,
        'user_id': userId,
        'ticket_qr': ticketQr,
      }).select();

      debugPrint("Registration successful: $res");
    } catch (error) {
      debugPrint("Registration failed: $error");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to register: $error")));
      }
      rethrow;
    }
  }

  Future<void> getRemainingSeats() async {
    final res = await supabase
        .from('registrations')
        .select()
        .eq('event_id', widget.event['event_id']);
    List<Map<String, dynamic>> data = res; // as List<Map<String, dynamic>>
    print('seats remaing ${widget.event['total_seats'] - data.length}');
    if (data.isEmpty) {
      setState(() {
        remainingSeats = widget.event['total_seats'];
      });
    } else {
      setState(() {
        remainingSeats = widget.event['total_seats'] - data.length;
      });
    }
  }

  Future<void> checkUserRegistration() async {
    final supabase = SupabaseService.client;
    final user = supabase.auth.currentUser;
    final eventId = widget.event['event_id'];

    if (user == null) return; // user not logged in

    try {
      final res = await supabase
          .from('registrations')
          .select('id') // or 'user_id' if you want
          .eq('user_id', user.id)
          .eq('event_id', eventId); // check for this event

      if (res != null && (res as List).isNotEmpty) {
        // user is registered
        setState(() {
          isRegistered = true;
        });
      } else {
        // user not registered
        setState(() {
          isRegistered = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Something went wrong')));
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    String convertTo12HourFormat(String time24) {
      // Parse the 24-hour format string into DateTime
      final dt = DateFormat("HH:mm:ss").parse(time24);
      // Format into 12-hour format with AM/PM
      return DateFormat("hh:mm a").format(dt);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: const Text('Event Details'),
      ),
      floatingActionButton: (isRegistered == false)
          ? FloatingActionButton.extended(
              onPressed: () async {
                try {
                  await registerForEvent(
                    widget.event['event_id'],
                    supabase.auth.currentUser!.id,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Registered successfully!")),
                    );
                  }
                } catch (_) {}
              },
              backgroundColor: Theme.of(context).primaryColor,
              icon: const Icon(Icons.event_available),
              label: const Text("Register"),
            )
          : null,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              child: Image.network(
                widget.eventUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),

            // Event Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                widget.event["event_name"],
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Date & Location
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                spacing: 6.0,
                children: [
                  Text(
                    '📆 ${dateFormat.format(DateTime.parse(widget.event["start_date"]))} ',
                  ),
                  Text(
                    '⏰ ${convertTo12HourFormat(widget.event['start_time'])} - ${convertTo12HourFormat(widget.event['end_time'])}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text('  📍${widget.event["location"]}'),
            const SizedBox(height: 20),

            // Countdown Timer
            Center(
              child: Column(
                children: [
                  const Text(
                    "Time Left",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formatDuration(_timeLeft),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Seats Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      const Icon(Icons.event_seat, color: Colors.blue),
                      const SizedBox(height: 4),
                      const Text("Total Seats"),
                      Text(
                        "${widget.event["total_seats"]}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Icon(Icons.event_available, color: Colors.green),
                      const SizedBox(height: 4),
                      const Text("Available"),
                      Text(
                        remainingSeats
                            .toString(), // replace with available seats calc
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                widget.event["description"] ?? "No description provided.",
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),

            // Extra Content – About Organizer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "About Organizer",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "This organizer has hosted multiple successful events and workshops. Join to learn, network, and grow.",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Event Tips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Event Tips",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "- Arrive 15 minutes early.\n- Carry a notebook and pen.\n- Connect with other attendees.",
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 100,
            ), // Padding at the bottom for FAB spacing
          ],
        ),
      ),
    );
  }
}
