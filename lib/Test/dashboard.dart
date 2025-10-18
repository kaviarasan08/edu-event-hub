import 'package:eduevent_hub/Test/manage_event.dart';
import 'package:eduevent_hub/pages/College/management_page.dart';
import 'package:flutter/material.dart';

class CollegeDashboard extends StatelessWidget {
  const CollegeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // College Header
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  child: Icon(
                    Icons.school,
                    size: 36,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "ABC College of Engineering",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        "admin@abc.edu",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Quick Stats Section
            Text(
              "Quick Stats",
              style: theme.textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statCard(
                  "Events",
                  "12",
                  Icons.event,
                  theme.colorScheme.primary,
                  size,
                ),
                _statCard(
                  "Registrations",
                  "350",
                  Icons.people,
                  Colors.green,
                  size,
                ),
                _statCard(
                  "Attendance",
                  "82%",
                  Icons.check_circle,
                  Colors.orange,
                  size,
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Quick Actions
            Text(
              "Quick Actions",
              style: theme.textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _actionButton(
              title: "Create New Event",
              icon: Icons.add_circle_outline,
              color: theme.colorScheme.primary,
              onTap: () {
                // TODO: Navigate to create event
              },
            ),
            _actionButton(
              title: "Manage Events",
              icon: Icons.event_available,
              color: Colors.teal,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => ManageEventsScreen()),
                );
              },
            ),
            _actionButton(
              title: "Scan QR for Attendance",
              icon: Icons.qr_code_scanner,
              color: Colors.deepOrange,
              onTap: () {
                // TODO: Open QR Scanner
              },
            ),
          ],
        ),
      ),
    );
  }

  // Stat Card Widget
  Widget _statCard(
    String title,
    String value,
    IconData icon,
    Color color,
    Size size,
  ) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  // Action Button Widget
  Widget _actionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}
