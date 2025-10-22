import 'package:eduevent_hub/Service/authentication.dart';
import 'package:eduevent_hub/theme/theme_data.dart';
import 'package:flutter/material.dart';

import '../pages/Student/interaction_screen.dart';

class EventCard extends StatefulWidget {
  const EventCard({
    super.key,
    required this.eventData,
    required this.resourceImage,
    required this.resourceLogo,
    required this.resourceName,
    required this.startTime,
    required this.endTime,
  });

  final Map<String, dynamic> eventData;
  final String resourceImage;
  final String resourceLogo;
  final String resourceName;
  final String startTime;
  final String endTime;

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  String buttonName = '';
  final _supabase = SupabaseService.client;

void getText() async {
  final userId = _supabase.auth.currentUser?.id;
  if (userId == null) return;

  try {
    final res = await _supabase
        .from('followers')
        .select()
        .eq('student_id', userId)
        .eq('college_id', widget.eventData['college_id'])
        .maybeSingle(); // ✅ safer alternative to .single()

    print('followers: $res');

    setState(() {
      // if res is not null -> following
      buttonName = (res != null) ? 'Following' : 'Follow';
    });
  } catch (e) {
    print('Error fetching follow status: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getText();
  }

  void followButton() async {
    final userId = _supabase.auth.currentUser!.id;
    try {
      if (buttonName == 'Follow') {
        await _supabase.from('followers').insert({
          'student_id': userId,
          'college_id': widget.eventData['college_id'],
        });
        setState(() {
          buttonName = 'Following';
        });
      } else {
        await _supabase.from('followers').delete().eq('student_id', userId);
        setState(() {
          buttonName = 'Follow';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailsScreen(
              event: widget.eventData,
              eventUrl: widget.resourceImage,
            ),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    backgroundImage: NetworkImage(widget.resourceLogo),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.resourceName,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  InkWell(
                    onTap: followButton,
                    child: Container(
                      padding: EdgeInsets.all(5.0),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(22),
                      ),

                      child: Center(
                        child: Text(
                          '  $buttonName  ',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Event Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.resourceImage,
                width: double.infinity,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 8),
            // Event Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                widget.eventData["event_name"],
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 4),
            // Event Time and Location
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                ' Time ${widget.startTime} - ${widget.endTime} • ${widget.eventData["location"]}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
