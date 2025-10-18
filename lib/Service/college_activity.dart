import 'package:eduevent_hub/Service/authentication.dart';
import 'package:eduevent_hub/models/college.dart';

class CollegeActivity {
  final _supabase = SupabaseService.client;

  // get all colleges

  Future<List<Map<String, dynamic>>> getAllColleges() async {
    final res = await _supabase.from('colleges').select();
    print('All Colleges : $res');
    return res;
  }

  // get specifi colleges
  Future<Map<String, dynamic>> getCollege(String uid) async {
    final res = await _supabase.from('colleges').select().eq('user_id', uid).single();
    return res;
  }

    // update college
  Future<bool> updateColleges(College college) async {
    final res = await _supabase
        .from('colleges')
        .update(college.toJson())
        .eq('user_id', college.userId)
        .select()
        .single();
    print('College: $res');
    return res.isNotEmpty;
  }

}
