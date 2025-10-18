import 'package:flutter/material.dart';

class EventManagementScreen extends StatelessWidget {
  final String title;
  final String date;
  final int totalSeats;
  final int registered;
  final int attended;

  const EventManagementScreen({
    super.key,
    required this.title,
    required this.date,
    required this.totalSeats,
    required this.registered,
    required this.attended,
  });

  @override
  Widget build(BuildContext context) {
    int availableSeats = totalSeats - registered;
    double attendancePercent =
        registered == 0 ? 0 : (attended / registered) * 100;

    // Dummy students list
    final students = [
      {"name": "John Doe", "roll": "21CS001", "attended": true},
      {"name": "Priya Sharma", "roll": "21CS005", "attended": false},
      {"name": "Rahul Kumar", "roll": "21CS007", "attended": true},
      {"name": "Ananya Iyer", "roll": "21CS010", "attended": false},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Manage $title"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: QR scanner to mark attendance
        },
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text("Scan QR"),
        backgroundColor: Colors.indigo,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Event Info
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style:
                          const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(date, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _infoChip(Icons.event_seat, "Total: $totalSeats"),
                      _infoChip(Icons.people, "Registered: $registered"),
                      _infoChip(Icons.check_circle,
                          "Attended: $attended (${attendancePercent.toStringAsFixed(0)}%)"),
                      _infoChip(Icons.chair_alt, "Available: $availableSeats"),
                    ],
                  )
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          const Text("Registered Students",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 10),

          // Student List
          ...students.map((student) => Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        student["attended"]! as bool ? Colors.green : Colors.red,
                    child: Icon(
                      student["attended"]! as bool? Icons.check : Icons.close,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(student["name"]! as String),
                  subtitle: Text("Roll: ${student["roll"]}"),
                  trailing: Text(
                    student["attended"]! as bool ? "Present" : "Absent",
                    style: TextStyle(
                        color: student["attended"]! as bool
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.indigo),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
