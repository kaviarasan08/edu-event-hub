import 'dart:io';

import 'package:eduevent_hub/Service/authentication.dart';
import 'package:eduevent_hub/components/samsung_box.dart';
import 'package:eduevent_hub/models/college.dart';
import 'package:eduevent_hub/pages/Auth%20Screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/student.dart';
import 'Auth Screens/loginorsignup.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.userId, required this.role});

  final String userId;
  final String role;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<String> settingsinfo = [
    'Notitfication Settings',
    'Themes',
    'Privacy Policy',
    'Terms & Service',
  ];
  String name = 'processing';
  final _supabase = SupabaseService.client;
  final ImagePicker _imagePicker = ImagePicker();
  File? _imageFile;
  String? imageUrl;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getName();
    if (widget.role == 'Student') {
      getFollowersCount();
    }
  }

  void getName() async {
    final table = (widget.role == 'Student') ? 'students' : 'colleges';
    final selectItem = (widget.role == 'Student') ? 'name' : 'college_name';
    final columnName = (widget.role == 'Student')
        ? 'profile_image_url'
        : 'logo_url';
    final res = await _supabase
        .from(table)
        .select('$selectItem, $columnName')
        .eq('user_id', widget.userId)
        .single();
    if (!mounted) return;
    setState(() {
      name = res[selectItem];
      imageUrl = res[columnName];
    });
    print('name : $name : image : ${res[columnName]}');
  }

  Future<bool> fromGallery(bool update) async {
    final table = (widget.role == 'Student') ? 'students' : 'colleges';
    final columnName = (widget.role == 'Student')
        ? 'profile_image_url'
        : 'logo_url';
    final pickedImage = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });

      final image_url = await Authentication().uploadFile(
        widget.userId,
        pickedImage.path,
        update,
      );
      await _supabase
          .from(table)
          .update({columnName: image_url})
          .eq('user_id', widget.userId);
      return true;
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Select the image...!!!')));
      return false;
    }
  }

  int followerCount = 0;

  void getFollowersCount() async {
    try {
      final res = await _supabase
          .from('followers')
          .select('*')
          .eq('student_id', widget.userId)
          .count(CountOption.exact);

      final count = res.count ?? 0; // ✅ safely get count

      print('Follower count: $count');

      setState(() {
        followerCount = count;
      });
    } catch (e) {
      print('Error fetching followers count: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading followers count')));
    }
  }

  Future<bool> fromCamera(bool update) async {
    final table = (widget.role == 'Student') ? 'students' : 'colleges';
    final columnName = (widget.role == 'Student')
        ? 'profile_image_url'
        : 'logo_url';
    final pickedImage = await _imagePicker.pickImage(
      source: ImageSource.camera,
    );
    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
      // Navigator.pop(context);

      final image_url = await Authentication().uploadFile(
        widget.userId,
        pickedImage.path,
        update,
      );
      await _supabase
          .from(table)
          .update({columnName: image_url})
          .eq('user_id', widget.userId);
      return true;
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Select the image...!!!')));
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        actions: [
          // IconButton(
          //   onPressed: () async {
          //     if (widget.role == 'Student') {
          //       final res = await _supabase
          //           .from('students')
          //           .select()
          //           .eq('user_id', widget.userId)
          //           .single();
          //       final Student student = Student.fromJson(res);
          //       Navigator.of(context).push(
          //         MaterialPageRoute(
          //           builder: (_) => SignupScreen(
          //             roleType: widget.role,
          //             isForUpdate: true,
          //             studentData: student,
          //           ),
          //         ),
          //       );
          //     } else {
          //       final res = await _supabase
          //           .from('colleges')
          //           .select()
          //           .eq('user_id', widget.userId)
          //           .single();
          //       print('clgupd: $res');
          //       final College college = College.fromJson(res);
          //       print('clg : ${college.userId}');
          //       Navigator.of(context).push(
          //         MaterialPageRoute(
          //           builder: (_) => SignupScreen(
          //             roleType: widget.role,
          //             isForUpdate: true,
          //             collegeData: college,
          //           ),
          //         ),
          //       );
          //     }
          //   },
          //   icon: Icon(LucideIcons.edit),
          // ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 15.0,
            children: [
              SizedBox(height: 20),
              //  logo + name
              logo(),

              // personal Info
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Personal Info',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Spacer(),
                  TextButton.icon(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    label: Text(
                      'edit',
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium!.copyWith(color: Colors.blue),
                    ),
                    onPressed: () async {
                      if (widget.role == 'Student') {
                        final res = await _supabase
                            .from('students')
                            .select()
                            .eq('user_id', widget.userId)
                            .single();
                        final Student student = Student.fromJson(res);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SignupScreen(
                              roleType: widget.role,
                              isForUpdate: true,
                              studentData: student,
                            ),
                          ),
                        );
                      } else {
                        final res = await _supabase
                            .from('colleges')
                            .select()
                            .eq('user_id', widget.userId)
                            .single();
                        print('clgupd: $res');
                        final College college = College.fromJson(res);
                        print('clg : ${college.userId}');
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SignupScreen(
                              roleType: widget.role,
                              isForUpdate: true,
                              collegeData: college,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
              SamsungBox(
                data: settingsinfo,
                role: widget.role,
                userId: widget.userId,
              ),

              // settings
              Text('Settings', style: Theme.of(context).textTheme.titleMedium),
              SamsungBox(
                data: settingsinfo,
                role: 'role',
                userId: widget.userId,
              ),

              TextButton.icon(
                icon: Icon(Icons.logout, color: Colors.red),
                onPressed: () async {
                  await _supabase.auth.signOut();
                  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => LoginOrSignup()),
                    (route) => false,
                  );
                },
                label: Text(
                  'Logout',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium!.copyWith(color: Colors.red),
                ),
              ),
              SizedBox(height: 25),
              // logout
            ],
          ),
        ),
      ),
    );
  }

  Widget logo() {
    void imagePicker(bool isUpdate) async {
      showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (_) {
          return Container(
            margin: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              spacing: 20,
              children: [
                Container(
                  height: 15,
                  width: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    color: Colors.grey,
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    final bool res = await fromGallery(isUpdate);
                    if (res) {
                      Navigator.pop(context);
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.browse_gallery),
                      Text('Pick from gallery'),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    final bool res = await fromCamera(isUpdate);
                    if (res) {
                      Navigator.pop(context);
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Icon(Icons.camera), Text('Pick from camera')],
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    return Row(
      spacing: 25.0,
      children: [
        (_imageFile == null && (imageUrl == null || imageUrl!.isEmpty))
            ? Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      imagePicker(false);
                    },
                    child: Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.blue,
                      ),
                      child: Center(
                        child: Row(
                          children: [
                            Text(
                              name[0],
                              style: Theme.of(context).textTheme.titleMedium!
                                  .copyWith(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    right: 0,
                    bottom: 2,
                    child: Icon(Icons.add, color: Colors.white),
                  ),
                ],
              )
            : (_imageFile != null)
            ? CircleAvatar(radius: 30, foregroundImage: FileImage(_imageFile!))
            : GestureDetector(
                onTap: () {
                  imagePicker(true);
                },
                child: CircleAvatar(
                  radius: 30,
                  foregroundImage: NetworkImage(imageUrl!),
                ),
              ),
        SizedBox(
          width: MediaQuery.of(context).size.width - 140,
          child: Text(
            name,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            maxLines: 3,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ],
    );
  }
}
