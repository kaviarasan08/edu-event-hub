import 'package:eduevent_hub/pages/College/my_events.dart';
import 'package:eduevent_hub/pages/Student/home_screen.dart';
import 'package:eduevent_hub/pages/Student/my_registration.dart';
import 'package:eduevent_hub/pages/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../Service/authentication.dart';
import 'College/organizer_dashboard.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // late final PersistentTabController _controller;
  final _supabase = SupabaseService.client;
  int _selectedIndex = 0;

  User? user;
  String? roleType;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // _controller = PersistentTabController(initialIndex: 0);

    _initUserAndRole();
  }

  Future<void> _initUserAndRole() async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser != null) {
      final role = await Authentication().getRole(currentUser.id);
      setState(() {
        user = currentUser;
        roleType = role;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // If user is null, handle gracefully
    if (user == null || roleType == null) {
      return const Scaffold(body: Center(child: Text("No user found")));
    } else {
      // Now it's safe to create pages
      final List<Widget> _pages = [
        (roleType == 'Student')
            ? HomeScreen()
            : OrganizerDashboard(organizerId: user!.id),
        (roleType == 'Student')
            ? MyRegistrationsPage()
            : MyEvents(collegeId: user!.id),
        ProfileScreen(userId: user!.id, role: roleType!), // safe now
        NotificationsPage(),
      ];

      return Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: (roleType == 'Student') ? 'Home' : 'Dashboard',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Events'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Notification',
            ),
          ],
        ),
      );
    }
  }
}

// class RegistrationsPage extends StatelessWidget {
//   final List<Map<String, String>> registrations = [
//     {
//       "eventName": "AI Workshop",
//       "date": "2025-09-20 10:00 AM",
//       "status": "Registered",
//     },
//     {
//       "eventName": "Flutter Meetup",
//       "date": "2025-09-25 02:00 PM",
//       "status": "Attended",
//     },
//     {
//       "eventName": "Data Science Bootcamp",
//       "date": "2025-09-18 09:00 AM",
//       "status": "Registered",
//     },
//   ];

//   @override
//   Widget build(BuildContext context) {
//     // final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');
//     return Scaffold(
//       appBar: AppBar(title: Text("My Registrations")),
//       body: ListView.builder(
//         itemCount: registrations.length,
//         itemBuilder: (context, index) {
//           final reg = registrations[index];
//           return Card(
//             margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//             child: ListTile(
//               title: Text(
//                 reg["eventName"]!,
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//               subtitle: Text(reg["date"]!),
//               trailing: Chip(
//                 label: Text(
//                   reg["status"]!,
//                   style: TextStyle(color: Colors.white),
//                 ),
//                 backgroundColor: reg["status"] == "Attended"
//                     ? Colors.green
//                     : Colors.orange,
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

class NotificationsPage extends StatelessWidget {
  final List<Map<String, String>> notifications = [
    {
      "title": "Event Reminder",
      "message": "Don't forget to attend the AI Workshop tomorrow at 10 AM.",
    },
    {
      "title": "New Event",
      "message": "A new event 'Flutter Meetup' is now live. Check it out!",
    },
    {
      "title": "Attendance Marked",
      "message":
          "Your attendance for 'Data Science Bootcamp' has been confirmed.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notifications")),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notif = notifications[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: ListTile(
              leading: Icon(Icons.notifications, color: Colors.blue),
              title: Text(notif["title"]!),
              subtitle: Text(notif["message"]!),
            ),
          );
        },
      ),
    );
  }
}
