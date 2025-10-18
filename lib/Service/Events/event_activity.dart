// import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/Events/events.dart';
import '../../models/Events/symposium_events.dart';

class EventActivity {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Add event (workshop or symposium)
  Future<String> addEvent(Event event) async {
    final response = await _supabase
        .from('Events')
        .insert(event.toJson())
        .select()
        .single();

    return response['event_id'].toString();
  }

  // Upload single image for the event

  // Add symposium workshops after event is created
  Future<void> addSymposiumWorkshops(
    String eventId,
    List<SymposiumEvent> workshops,
  ) async {
    for (var workshop in workshops) {
      workshop.eventId = eventId;
      await _supabase.from('SymposiumEvents').insert(workshop.toJson());
    }
  }

  // get events
  // Future<List<Map<String, dynamic>>> getEvents() async {
  //   final res = await _supabase.from('events').select();
  //   print(res);
  //   return res;

  // }

  Future<List<Map<String, dynamic>>> getEvents() async {
    final supabase = Supabase.instance.client;
    final now = DateTime.now();

    try {
      // Step 1: Fetch all events from Supabase
      final response = await supabase.from('events').select();

      if (response.isEmpty) {
        print("No events found.");
        return [];
      }

      List<Map<String, dynamic>> events = List<Map<String, dynamic>>.from(
        response,
      );

      List<Map<String, dynamic>> activeEvents = [];
      List<String> finishedEventIds = [];

      // Step 2: Loop through each event and process
      for (var event in events) {
        final String date = event['start_date']; // "2025-10-14"
        final String startTime = event['start_time']; // "10:00"
        final String endTime = event['end_time']; // "12:00"

        // ✅ Parse safely
        final DateTime dateOnly = DateTime.parse(date);

        List<String> startParts = startTime.split(':');
        List<String> endParts = endTime.split(':');

        DateTime startDateTime = DateTime(
          dateOnly.year,
          dateOnly.month,
          dateOnly.day,
          int.parse(startParts[0]),
          int.parse(startParts[1]),
        );

        DateTime endDateTime = DateTime(
          dateOnly.year,
          dateOnly.month,
          dateOnly.day,
          int.parse(endParts[0]),
          int.parse(endParts[1]),
        );

        // ✅ Compare end time with current time
        if (endDateTime.isAfter(now)) {
          activeEvents.add(event); // Keep ongoing/upcoming events
        } else {
          finishedEventIds.add(event['event_id']); // Mark for deletion
        }
      }

      // Step 3: Delete finished events from Supabase
      // if (finishedEventIds.isNotEmpty) {
      //   await supabase
      //       .from('events')
      //       .delete()
      //       .in_('event_id', finishedEventIds);

      //   print("Deleted ${finishedEventIds.length} finished events ✅");
      // }

      // Step 4: Return or print active events
      print("Active Events Count: ${activeEvents.length}");
      for (var e in activeEvents) {
        print(
          "➡️ ${e['event_name']} (${e['date']} ${e['startTime']} - ${e['endTime']})",
        );
      }
      return activeEvents;
    } catch (e) {
      print("❌ Error: $e");
      return [];
    }
  }
}

// check the today date
