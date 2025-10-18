import 'package:eduevent_hub/Service/authentication.dart';
import 'package:flutter/material.dart';

class SamsungBox extends StatefulWidget {
  const SamsungBox({
    super.key,
    required this.data,
    required this.role,
    required this.userId,
  });

  final List<dynamic> data;
  final String role;
  final String userId;

  @override
  State<SamsungBox> createState() => _SamsungBoxState();
}

class _SamsungBoxState extends State<SamsungBox> {
  final _supabase = SupabaseService.client;
  late Map<String, dynamic> records = {};
  late String college;

  @override
  void initState() {
    super.initState();
    getRecords();
  }

  void getRecords() async {
    if (widget.role == 'Student') {
      final res = await _supabase
          .from('students')
          .select('name, email, phone, department, year, profile_image_url')
          .eq('user_id', widget.userId)
          .single();
      final clgId = await _supabase
          .from('students')
          .select('college_id')
          .eq('user_id', widget.userId)
          .single();
      final clg = await _supabase
          .from('colleges')
          .select('college_name')
          .eq('id', clgId['college_id'])
          .single();
      if (!mounted) return;
      setState(() {
        records = res;
        college = clg['college_name'];
      });
      print('records : $records , college : $college');
    } else if (widget.role == 'College') {
      print('userId : ${widget.userId}');
      final res = await _supabase
          .from('colleges')
          .select('college_name, email, phone, location, website_url')
          .eq('user_id', widget.userId)
          .maybeSingle();
      if (!mounted) return;

      if (res != null) {
        setState(() {
          records = res;
        });
      }
    }
  }

  List<String> studentTitle = [
    'name',
    'email',
    'phone',
    'college',
    'department',
    'year',
  ];
  List<String> collegeTitle = [
    'college_name',
    'email',
    'phone',
    'location',
    'website_url',
  ];

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty && widget.role != 'role') {
      return CircularProgressIndicator();
    }
    return Card(
      child: (widget.role == 'role')
          ? ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.data.length,
              itemBuilder: (_, index) {
                // data = widget.data as List<String>;
                // print('index : $index');
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: (index == 3) ? 15.0 : 0.0,
                    top: 10.0,
                  ),
                  child: InkWell(
                    onTap: () {
                      // print('You are God damn right');
                    },
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18.0,
                            vertical: 8.0,
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.settings),
                              SizedBox(width: 25.0),
                              Text(widget.data[index]),
                              Spacer(),
                              Icon(Icons.arrow_forward_ios),
                            ],
                          ),
                        ),
                        if (index != 3)
                          Divider(
                            color: Colors.grey[300],
                            height: 5,
                            indent: 12,
                            endIndent: 14,
                          ),
                      ],
                    ),
                  ),
                );
              },
            )
          : (widget.role == 'Student')
          ? ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: records.length,
              itemBuilder: (_, index) {
                // final Map<String, dynamic> data =
                //     widget.data as Map<String, dynamic>;
                // print('index : $index');
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: (index == 5) ? 15.0 : 0.0,
                    top: 5.0,
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18.0,
                          vertical: 8.0,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.person),
                            SizedBox(width: 25.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 5.0,
                              children: [
                                Text(studentTitle[index]),
                                if (index == 3)
                                  SizedBox(
                                    // color: Colors.amber,
                                    width:
                                        MediaQuery.of(context).size.width - 175,
                                    child: Text(
                                      college,
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                      // style: TextStyle(color: Colors.white),
                                      maxLines: 3,
                                    ),
                                  ),
                                if (index != 3)
                                  Text(records[studentTitle[index]]),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (index != 5)
                        Divider(
                          color: Colors.grey[300],
                          height: 5,
                          indent: 12,
                          endIndent: 14,
                        ),
                    ],
                  ),
                );
              },
            )
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: records.length,
              itemBuilder: (_, index) {
                // final Map<String, dynamic> data =
                //     widget.data as Map<String, dynamic>;
                // print('index : $index');
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: (index == 4) ? 15.0 : 0.0,
                    top: 5.0,
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18.0,
                          vertical: 8.0,
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.person),
                            SizedBox(width: 25.0),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 5.0,
                              children: [
                                Text(collegeTitle[index]),
                                SizedBox(
                                  // color: Colors.amber,
                                  width:
                                      MediaQuery.of(context).size.width - 175,
                                  child: Text(
                                    records[collegeTitle[index]] ?? 'null',
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                    // style: TextStyle(color: Colors.white),
                                    maxLines: 3,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (index != 4)
                        Divider(
                          color: Colors.grey[300],
                          height: 5,
                          indent: 12,
                          endIndent: 14,
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
