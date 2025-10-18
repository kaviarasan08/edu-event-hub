import 'package:eduevent_hub/Service/authentication.dart';
import 'package:eduevent_hub/Service/college_activity.dart';
import 'package:eduevent_hub/Service/student_activity.dart';
import 'package:eduevent_hub/components/button.dart';
import 'package:eduevent_hub/components/dropdown_field.dart';
import 'package:eduevent_hub/components/text_field.dart';
import 'package:eduevent_hub/models/college.dart';
import 'package:eduevent_hub/models/student.dart';
import 'package:eduevent_hub/pages/Student/home_screen.dart';
import 'package:eduevent_hub/pages/profile_screen.dart';
import 'package:flutter/material.dart';

import '../../theme/theme_data.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({
    super.key,
    required this.roleType,
    required this.isForUpdate,
    this.studentData,
    this.collegeData,
  });
  final String roleType;
  final bool isForUpdate;
  final Student? studentData;
  final College? collegeData;

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final Authentication supabaseAuth = Authentication();
  bool processing = false;

  List<Map<String, String>> allColleges = [];

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController websiteUrlController = TextEditingController();

  void getAllCollegesList() async {
    final res = await CollegeActivity().getAllColleges();
    setState(() {
      processing = true;
      allColleges = res.map((college) {
        return {
          "id": college['id'].toString(), // convert to String
          "name": college['college_name'].toString(),
        };
      }).toList();
      if (widget.isForUpdate && widget.studentData != null) {
        emailController.text = widget.studentData!.email;
        nameController.text = widget.studentData!.name;
        phoneController.text = widget.studentData!.phone;
        selectedYear = widget.studentData!.year;
        selectedDepartment = widget.studentData!.department;

        final matchedCollege = allColleges.firstWhere(
          (college) => college["id"] == widget.studentData!.collegeId,
          orElse: () => {},
        );
        if (matchedCollege.isNotEmpty) {
          selectedCollege = matchedCollege["name"];
          selectedCollegeId = matchedCollege["id"];
        }
      }
      if (widget.isForUpdate && widget.collegeData != null) {
        print('yes heree...!');
        emailController.text = widget.collegeData!.email;
        nameController.text = widget.collegeData!.collegeName;
        phoneController.text = widget.collegeData!.phone;
        locationController.text = widget.collegeData!.location;
        websiteUrlController.text = widget.collegeData!.websiteUrl;
      }
      processing = false;
    });
  }

  void clear(String type) {
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    passwordController.clear();
    if (type == 'College') {
      confirmPasswordController.clear();
      locationController.clear();
      websiteUrlController.clear();
    } else {
      selectedCollege = null;
      selectedDepartment = null;
      selectedYear = null;
      selectedCollegeId = null;
    }
  }

  String? selectedCollege;
  String? selectedCollegeId;
  String? selectedDepartment;
  String? selectedYear;

  @override
  void initState() {
    super.initState();
    getAllCollegesList();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    Widget content;

    Widget studentRegistration() {
      List<String> departments = ['IT', 'ECE', 'CSE', 'EEE', 'AIDS'];
      List<String> years = ['1st Year', '2nd Year', '3rd Year', '4th Year'];
      bool res;

      void studentRegister() async {
        setState(() {
          processing = true;
        });
        if (widget.isForUpdate == false) {
          final userId = await supabaseAuth.signUp(
            emailController.text.trim(),
            passwordController.text.trim(),
          );
          // create role
          print(widget.roleType);
          await supabaseAuth.roles(userId, widget.roleType);
          // add Student
          res = await StudentActivity().addStudents(
            Student(
              userId: userId,
              name: nameController.text,
              email: emailController.text,
              phone: phoneController.text,
              collegeId: selectedCollegeId!,
              department: selectedDepartment!,
              year: selectedYear!,
            ),
          );
          setState(() {
            processing = false;
          });
        } else {
          // update Student
          res = await StudentActivity().updateStudents(
            Student(
              userId: widget.studentData!.userId,
              name: nameController.text,
              email: emailController.text,
              phone: phoneController.text,
              collegeId: selectedCollegeId ?? ' ',
              department: selectedDepartment ?? ' ',
              year: selectedYear!,
              profileImageUrl: widget.studentData!.profileImageUrl,
              profileUpdated: true,
            ),
          );
          setState(() {
            processing = false;
          });
        }
        if (res) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => (widget.isForUpdate)
                  ? ProfileScreen(
                      userId: widget.studentData!.userId,
                      role: 'Student',
                    )
                  : HomeScreen(),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Something went wrong try again later')),
          );
          clear(widget.roleType);
        }
      }

      return (processing == false)
          ? Container(
              padding: const EdgeInsets.all(25.0),
              height: size.height,
              width: size.width,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: ListView(
                children: [
                  Text(
                    (widget.isForUpdate)
                        ? 'Update Student Record'
                        : 'Student Registration',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineLarge!.copyWith(color: Colors.white),
                  ),
                  SizedBox(height: 25),
                  // myTextfield(nameController, 'Name', false, 1),
                  CustomTextField(
                    label: 'Name',
                    // icon: Icons.person,
                    controller: nameController,
                  ),
                  SizedBox(height: 20),
                  // myTextfield(emailController, 'Email', false, 1),
                  CustomTextField(
                    label: 'Email',
                    // icon: Icons.mail,
                    controller: emailController,
                  ),
                  SizedBox(height: 20),
                  // myTextfield(phoneController, 'Phone', false, 1),
                  CustomTextField(
                    label: 'Phone',
                    // icon: Icons.call,
                    controller: phoneController,
                  ),
                  SizedBox(height: 20),
                  InputDecorator(
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppTheme.primaryColor),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        hint: Text('select the college'),
                        value: selectedCollege,
                        isExpanded: true,
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: AppTheme.primaryColor,
                        ),
                        items: allColleges.map((college) {
                          return DropdownMenuItem(
                            value: college['name'],
                            child: Text(college['name'] as String),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCollege = value!;
                            selectedCollegeId = allColleges.firstWhere(
                              (college) => college["name"] == value,
                            )["id"];
                          });
                          print('clg: $selectedCollege');
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  CustomDropdownField(
                    label: 'Select Your Department',
                    items: departments,
                    value: selectedDepartment,
                    onChanged: (value) {
                      setState(() {
                        selectedDepartment = value!;
                      });
                      print('dep : $selectedDepartment');
                    },
                  ),
                  SizedBox(height: 20),
                  CustomDropdownField(
                    label: 'select your year',
                    items: years,
                    value: selectedYear,
                    onChanged: (value) {
                      setState(() {
                        selectedYear = value!;
                      });
                      print(selectedYear);
                    },
                  ),
                  SizedBox(height: 20),
                  // myTextfield(passwordController, 'Password', true, 1),
                  if (widget.isForUpdate != true)
                    CustomTextField(
                      label: 'Password',
                      // icon: Icons.password,
                      controller: passwordController,
                      isPassword: true,
                    ),
                  SizedBox(height: 25),
                  // ElevatedButton(onPressed: studentRegister, child: Text('Submit')),
                  CustomButton(
                    text: (widget.isForUpdate) ? 'Update' : 'Submit',
                    onPressed: studentRegister,
                  ),
                ],
              ),
            )
          : Center(child: CircularProgressIndicator());
    }

    Widget collegeRegistration(BuildContext context) {
      void collegeRegister() async {
        setState(() {
          processing = true;
        });
        bool res;
        if (widget.isForUpdate == false) {
          final userId = await supabaseAuth.signUp(
            emailController.text.trim(),
            passwordController.text.trim(),
          );
          // create role
          await supabaseAuth.roles(userId, widget.roleType);

          // add college
          res = await supabaseAuth.addColleges(
            College(
              userId: userId,
              collegeName: nameController.text,
              email: emailController.text,
              location: locationController.text,
              phone: phoneController.text,
            ),
          );
          setState(() {
            processing = false;
          });
        } else {
          res = await CollegeActivity().updateColleges(
            College(
              userId: widget.collegeData!.userId,
              collegeName: nameController.text,
              email: emailController.text,
              location: locationController.text,
              phone: phoneController.text,
              logoUrl: widget.collegeData!.logoUrl,
              profileUpdated: true,
              websiteUrl: websiteUrlController.text,
            ),
          );
          setState(() {
            processing = false;
          });
        }
        if (res) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => (widget.isForUpdate)
                  ? ProfileScreen(
                      userId: widget.collegeData!.userId,
                      role: 'College',
                    )
                  : HomeScreen(),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Something went wrong, try again later')),
          );
          clear(widget.roleType);
        }
      }

      return (processing == false)
          ? Container(
              padding: const EdgeInsets.all(25.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: ListView(
                children: [
                  Text(
                    (widget.isForUpdate)
                        ? 'Update College Record'
                        : 'College Registration',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineLarge!.copyWith(color: Colors.white),
                  ),
                  SizedBox(height: 25),
                  CustomTextField(
                    label: 'College Name',
                    // icon: Icons.school,
                    controller: nameController,
                  ),
                  SizedBox(height: 20),
                  CustomTextField(
                    label: 'Email',
                    // icon: Icons.mail,
                    controller: emailController,
                  ),
                  SizedBox(height: 20),
                  CustomTextField(
                    label: 'Phone',
                    // icon: Icons.call,
                    controller: phoneController,
                  ),
                  SizedBox(height: 20),
                  CustomTextField(
                    label: 'Location',
                    // icon: Icons.location_on,
                    controller: locationController,
                    maxLines: 3,
                  ),
                  SizedBox(height: 20),
                  CustomTextField(
                    label: 'Website Url',
                    // icon: Icons.format_underline_outlined,
                    controller: websiteUrlController,
                  ),
                  SizedBox(height: 20),
                  if (widget.isForUpdate != true)
                    CustomTextField(
                      label: 'Password',
                      // icon: Icons.password,
                      controller: passwordController,
                      isPassword: true,
                    ),
                  if (widget.isForUpdate != true) SizedBox(height: 20),
                  if (widget.isForUpdate != true)
                    CustomTextField(
                      label: 'Confirm Password',
                      // icon: Icons.password_outlined,
                      controller: confirmPasswordController,
                      isPassword: true,
                    ),
                  if (widget.isForUpdate != true) SizedBox(height: 25),
                  CustomButton(
                    text: (widget.isForUpdate) ? 'Update' : 'Submit',
                    onPressed: collegeRegister,
                  ),
                ],
              ),
            )
          : Center(child: CircularProgressIndicator());
    }

    content = (widget.roleType == 'Student')
        ? studentRegistration()
        : collegeRegistration(context);

    return Scaffold(body: content);
  }

  // TextField myTextfield(
  //   TextEditingController nameController,
  //   String placeholderText,
  //   bool isPassword,
  //   int minLines,
  // ) {
  //   return TextField(
  //     controller: nameController,
  //     obscureText: isPassword,
  //     maxLines: minLines,
  //     decoration: InputDecoration(hintText: placeholderText),
  //   );
  // }
}
