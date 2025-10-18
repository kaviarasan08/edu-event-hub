import 'package:eduevent_hub/Service/authentication.dart';

import '../models/student.dart';

class StudentActivity {
  final _supabase = SupabaseService.client;

  // get student
  Future<Map<String, dynamic>> getStudent(String uid) async {
    final student = await _supabase
        .from('students')
        .select()
        .eq('user_id', uid)
        .single();
    return student;
  }

  // add student
  Future<bool> addStudents(Student student) async {
    final res = await _supabase
        .from('students')
        .insert(student.toJson())
        .select()
        .single();
    print('Student: $res');
    return res.isNotEmpty;
  }

  // update student
  Future<bool> updateStudents(Student student) async {
    final res = await _supabase
        .from('students')
        .update(student.toJson())
        .eq('user_id', student.userId)
        .select()
        .single();
    print('Student: $res');
    return res.isNotEmpty;
  }
}
