import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/Events/symposium_events.dart';

class SymposiumActivity {
  final _supabase = Supabase.instance.client;

  // Add a symposium workshop
  Future<String> addSymposiumEvent(SymposiumEvent symEvent) async {
    final res = await _supabase
        .from('SymposiumEvents')
        .insert(symEvent.toJson())
        .select()
        .single();
    print('Symposium Event added: $res');
    return res['symposium_event_id'].toString();
  }

  // Get all symposium workshops for an event
  Future<List<SymposiumEvent>> getSymposiumEvents(String eventId) async {
    final res = await _supabase
        .from('SymposiumEvents')
        .select()
        .eq('event_id', eventId);
    print('Fetched symposium workshops: $res');
    return (res as List)
        .map((e) => SymposiumEvent.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
