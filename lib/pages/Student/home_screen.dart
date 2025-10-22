import 'package:eduevent_hub/Service/Events/event_activity.dart';
import 'package:eduevent_hub/Service/authentication.dart';
import 'package:eduevent_hub/pages/Auth%20Screens/loginorsignup.dart';
import 'package:eduevent_hub/pages/Events%20Screen/event_stepper.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'interaction_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _supabase = SupabaseService.client;

  User? user;
  String roleType = 'processing....';
  Position? userLocation;
  bool isLatLongNull = true;
  List<Map<String, dynamic>> data = [];

  void navigate() {
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LoginOrSignup()),
      (route) => false,
    );
  }

  Future<Position?> getUserLocation() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      final isLocationEnabled = await Geolocator.isLocationServiceEnabled();
      if (isLocationEnabled) {
        return await Geolocator.getCurrentPosition();
      } else {
        final res = await Geolocator.openLocationSettings();
        if (res) {
          return await Geolocator.getCurrentPosition();
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location should be enabled for the app purpose'),
        ),
      );
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    user = _supabase.auth.currentUser; // ✅ initialize here
    getRoleType();
    // getLocation();
  }

  EventActivity myEvents = EventActivity();

  void getRoleType() async {
    final res = await Authentication().getRole(user!.id);
    if (!mounted) return;
    if (user != null) {
      setState(() {
        roleType = res;
      });
    }
    final result = await isLatLonNull();
    setState(() {
      isLatLongNull = result;
    });

    // get all events
    final dat = await myEvents.getEvents();

    setState(() {
      data = dat;
    });
  }

  Future<bool> isLatLonNull() async {
    final table = roleType == 'College' ? 'colleges' : 'students';
    final res = await _supabase
        .from(table)
        .select('latitude, longitude')
        .eq('user_id', user!.id)
        .single();
    print('lat : ${res['latitude']} , lon ${res['longitude']}');
    if (res['latitude'] == null && res['longitude'] == null) {
      return true;
    }
    return false;
  }

  // void getLocation() async {
  //   if (isLatLongNull) {
  //     final res = await getUserLocation();
  //     setState(() {
  //       userLocation = res;
  //     });
  //     if (userLocation != null) {
  //       final table = (roleType == 'College') ? 'colleges' : 'students';
  //       await _supabase
  //           .from(table)
  //           .update({
  //             'latitude': userLocation!.latitude,
  //             'longitude': userLocation!.longitude,
  //           })
  //           .eq('user_id', user!.id);
  //     }
  //   }
  // }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  // final List<Map<String, dynamic>> events = [
  //   {
  //     "organizerName": "ABC College",
  //     "organizerLogo":
  //         "https://media.istockphoto.com/id/1450340623/photo/portrait-of-successful-mature-boss-senior-businessman-in-glasses-asian-looking-at-camera-and.jpg?s=612x612&w=0&k=20&c=f0EqWiUuID5VB_NxBUEDn92W2HLENR15CFFPzr-I4XE=", // replace with real image URL
  //     "eventTitle": "Flutter Workshop",
  //     "eventImage":
  //         "https://images.unsplash.com/photo-1492684223066-81342ee5ff30?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
  //     "startTime": DateTime.now().add(Duration(days: 1, hours: 4, minutes: 30)),
  //     "location": "Online",
  //     "totalSeats": 150,
  //     "availableSeats": 45,
  //     "description":
  //         "Join us for an in-depth symposium on AI trends, networking opportunities, and hands-on workshops.",
  //   },
  //   {
  //     "organizerName": "XYZ University",
  //     "organizerLogo":
  //         "https://media.istockphoto.com/id/1394363006/photo/young-african-businessman-standing-in-an-office-at-work.jpg?s=612x612&w=0&k=20&c=l74vu5cpkWz6nCnD7Jrh6cmrprdPLRXKlPj5mNiF1nM=",
  //     "eventTitle": "AI Symposium",
  //     "eventImage":
  //         "https://images.unsplash.com/photo-1531058020387-3be344556be6?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
  //     "startTime": DateTime.now().add(Duration(days: 1, hours: 4, minutes: 30)),
  //     "location": "Main Campus Hall",
  //     "totalSeats": 150,
  //     "availableSeats": 45,
  //     "description":
  //         "Join us for an in-depth symposium on AI trends, networking opportunities, and hands-on workshops.",
  //   },
  //   {
  //     "organizerName": "ABC College",
  //     "organizerLogo":
  //         "https://media.istockphoto.com/id/1450340623/photo/portrait-of-successful-mature-boss-senior-businessman-in-glasses-asian-looking-at-camera-and.jpg?s=612x612&w=0&k=20&c=f0EqWiUuID5VB_NxBUEDn92W2HLENR15CFFPzr-I4XE=", // replace with real image URL
  //     "eventTitle": "Flutter Workshop",
  //     "eventImage":
  //         "https://images.unsplash.com/photo-1492684223066-81342ee5ff30?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
  //     "startTime": DateTime.now().add(Duration(days: 1, hours: 4, minutes: 30)),
  //     "location": "Online",
  //     "totalSeats": 150,
  //     "availableSeats": 45,
  //     "description":
  //         "Join us for an in-depth symposium on AI trends, networking opportunities, and hands-on workshops.",
  //   },
  //   {
  //     "organizerName": "XYZ University",
  //     "organizerLogo":
  //         "https://media.istockphoto.com/id/1394363006/photo/young-african-businessman-standing-in-an-office-at-work.jpg?s=612x612&w=0&k=20&c=l74vu5cpkWz6nCnD7Jrh6cmrprdPLRXKlPj5mNiF1nM=",
  //     "eventTitle": "AI Symposium",
  //     "eventImage":
  //         "https://images.unsplash.com/photo-1531058020387-3be344556be6?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
  //     "startTime": DateTime.now().add(Duration(days: 1, hours: 4, minutes: 30)),
  //     "location": "Main Campus Hall",
  //     "totalSeats": 150,
  //     "availableSeats": 45,
  //     "description":
  //         "Join us for an in-depth symposium on AI trends, networking opportunities, and hands-on workshops.",
  //   },
  // ];

  Future<String> getCollegeDetails(String id, String tableName) async {
    final res = await _supabase
        .from('colleges')
        .select(tableName)
        .eq('user_id', id)
        .single();
    return res[tableName];
  }

  Future<String> getEventImage(String id) async {
    final res = await _supabase
        .from('event_images')
        .select('image_url')
        .eq('event_id', id)
        .single();
    return res['image_url'];
  }

  @override
  Widget build(BuildContext context) {
    // final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');

    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          spacing: 15,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search events...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    // Handle filter click
                  },
                  icon: Icon(Icons.filter_list),
                  label: Text('Filter'),
                ),
              ],
            ),
            // SizedBox(height: 20),
            // Event List
            Expanded(
              child: ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final eventData = data[index];

                  return FutureBuilder(
                    future: Future.wait([
                      getCollegeDetails(
                        eventData['college_id'],
                        'college_name',
                      ),
                      getCollegeDetails(eventData['college_id'], 'logo_url'),
                      getEventImage(eventData['event_id']),
                    ]),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Column(
                          children: [
                            SizedBox(height: 250),
                            CircularProgressIndicator(),
                          ],
                        );
                      }

                      final results = snapshot.data as List;
                      final resourceName = results[0] as String;
                      final resourceLogo = results[1] as String;
                      final resourceImage = results[2] as String;
                      final dt = DateFormat(
                        "HH:mm:ss",
                      ).parse(eventData["start_time"]);
                      // Format into 12-hour format with AM/PM
                      final startTime = DateFormat("hh:mm a").format(dt);
                      final dte = DateFormat(
                        "HH:mm:ss",
                      ).parse(eventData["end_time"]);
                      // Format into 12-hour format with AM/PM
                      final endTime = DateFormat("hh:mm a").format(dte);

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EventDetailsScreen(
                                event: eventData,
                                eventUrl: resourceImage,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Organizer Row
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        resourceLogo,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        resourceName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        // Handle follow/unfollow
                                      },
                                      child: Text('Follow'),
                                    ),
                                  ],
                                ),
                              ),
                              // Event Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  resourceImage,
                                  width: double.infinity,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(height: 8),
                              // Event Title
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: Text(
                                  eventData["event_name"],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: 4),
                              // Event Time and Location
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: Text(
                                  ' Time $startTime - $endTime • ${eventData["location"]}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                              SizedBox(height: 8),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: (roleType == 'College')
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => EventStepperPage(collegeId: user!.id),
                  ),
                );
              },
              child: Icon(LucideIcons.plus),
            )
          : null,
    );
  }
}
