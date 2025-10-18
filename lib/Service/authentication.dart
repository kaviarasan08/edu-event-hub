import 'dart:io';

import 'package:eduevent_hub/models/college.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../pages/main_screen.dart';

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;
}

class Authentication {
  final _supabase = SupabaseService.client;

  // login
  Future<void> login(String email, String password, BuildContext ctxt) async {
    final res = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (res.session != null) {
      Navigator.of(
        ctxt,
      ).pushReplacement(MaterialPageRoute(builder: (_) => MainScreen()));
    } else {
      ScaffoldMessenger.of(
        ctxt,
      ).showSnackBar(SnackBar(content: Text('Login Failed')));
    }
  }

  // signup
  Future<String> signUp(String email, String password) async {
    print('Email: $email, Password: $password');
    final res = await _supabase.auth.signUp(
      email: email.trim(),
      password: password.trim(),
    );
    final userId = res.user!.id;
    print('User: $userId');
    return userId;
  }

  // roles
  Future<void> roles(String userId, String roleType) async {
    final response = await _supabase.from('roles').insert({
      'user_id': userId,
      'role_type': roleType,
    });
    print('roles: $response');
  }

  // add colleges
  Future<bool> addColleges(College college) async {
    final res = await _supabase
        .from('colleges')
        .insert(college.toJson())
        .select()
        .single();
    print('College: $res');
    return res.isNotEmpty;
  }

  // get roletype
  Future<String> getRole(String uid) async {
    print('uid : $uid');
    final res = await _supabase
        .from('roles')
        .select('id, user_id, role_type')
        .eq('user_id', uid)
        .maybeSingle();
    print('roleType : $res');
    return res!['role_type'];
  }

  // upload file and get public url

  Future<String> uploadFile(
    String uid,
    String imagePath,
    bool updatedFile,
  ) async {
    final collegeId = uid; // fetched from colleges table
    final filePath = 'colleges/logos/$collegeId/logo.png';

    final res = await _supabase.storage
        .from('college_assets')
        .upload(
          filePath,
          File(imagePath),
          fileOptions: const FileOptions(
            upsert: true,
          ), // 👈 overwrite if exists
        );

    print('image-upload : $res');

    final publicUrl = _supabase.storage
        .from('college_assets')
        .getPublicUrl(filePath);

    print('public-url: $publicUrl');
    return publicUrl;
  }
}
