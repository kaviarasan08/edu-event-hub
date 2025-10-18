import 'package:eduevent_hub/Service/authentication.dart';
import 'package:flutter/material.dart';

class MyEvents extends StatefulWidget {
  const MyEvents({super.key, required this.collegeId});

  final String collegeId;

  @override
  State<MyEvents> createState() => _MyEventsState();
}

class _MyEventsState extends State<MyEvents> {
  final _supabase = SupabaseService.client;
  List<Map<String, dynamic>> myEvents = [];

  void getData() async {
    try {
      final res = await _supabase
          .from('events')
          .select()
          .eq('college_id', widget.collegeId);
      print(res);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error Occured')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Events')),

      body: Center(child: Text('No Events Data \n It is Under Progress')),
    );
  }
}
