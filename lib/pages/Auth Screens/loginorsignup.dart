import 'package:eduevent_hub/Service/authentication.dart';
import 'package:eduevent_hub/components/button.dart';
import 'package:eduevent_hub/components/role_box.dart';
import 'package:eduevent_hub/components/text_field.dart';
import 'package:eduevent_hub/pages/Auth%20Screens/signup_screen.dart';
import 'package:eduevent_hub/theme/theme_data.dart';
import 'package:flutter/material.dart';

class LoginOrSignup extends StatefulWidget {
  const LoginOrSignup({super.key});

  @override
  State<LoginOrSignup> createState() => _LoginOrSignupState();
}

class _LoginOrSignupState extends State<LoginOrSignup> {
  // controllers should be class-level, not inside build()
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // keep track of which screen to show
  bool showRoleScreen = false;
  String? isSelected;
  // final _supabase = SupabaseService.client;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: showRoleScreen ? roleScreen() : loginScreen(context),
      ),
    );
  }

  // ---------------- Login Screen ----------------
  Widget loginScreen(BuildContext context) {
    void login() async {
      await Authentication().login(
        emailController.text.trim(),
        passwordController.text.trim(),
        context,
      );
    }

    return Center(
      child: Card(
        color: Colors.transparent,
        margin: const EdgeInsets.all(22.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 15.0,
          children: [
            Text('Login', style: Theme.of(context).textTheme.headlineLarge),
            SizedBox(height: 10),
            CustomTextField(
              label: 'Email',
              // icon: LucideIcons.mail,
              controller: emailController,
            ),
            CustomTextField(
              label: 'Password',
              // icon: LucideIcons.bookLock,
              controller: passwordController,
              isPassword: true,
            ),
            const SizedBox(height: 20),
            CustomButton(text: 'Login', onPressed: login),
            Divider(height: 40, color: Colors.grey[200]),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'New here? Create an Account',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      showRoleScreen = true;
                    });
                  },
                  child: const Text(
                    'SignUp',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- Role Screen ----------------
  Widget roleScreen() {
    return Card(
      color: Colors.transparent,
      margin: const EdgeInsets.all(22.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 15.0,
        children: [
          Text(
            'Select the Role',
            style: Theme.of(
              context,
            ).textTheme.headlineLarge!.copyWith(color: Colors.white),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              RoleBox(
                role: 'Student',
                icon: Icons.person,
                isSelected: isSelected == 'Student',
                onTap: () {
                  setState(() {
                    isSelected = 'Student';
                  });
                },
              ),
              RoleBox(
                role: 'College',
                icon: Icons.home,
                isSelected: isSelected == 'College',
                onTap: () {
                  setState(() {
                    isSelected = 'College';
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 15),
          CustomButton(
            text: 'next',
            onPressed: () {
              if (isSelected != null) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SignupScreen(roleType: isSelected!,isForUpdate: false),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  // ---------------- Role Box ----------------
  // GestureDetector roleBox(BuildContext context, String role) {
  //   return GestureDetector(
  //     onTap: () {
  //       Navigator.of(context).pushReplacement(
  //         MaterialPageRoute(builder: (ctx) => SignupScreen(roleType: role)),
  //       );
  //     },
  //     child: Container(
  //       height: 200,
  //       width: 150,
  //       alignment: Alignment.center,
  //       decoration: BoxDecoration(
  //         color: Theme.of(context).primaryColor,
  //         borderRadius: BorderRadius.circular(12),
  //       ),
  //       child: Text(
  //         role,
  //         style: const TextStyle(color: Colors.white, fontSize: 20),
  //       ),
  //     ),
  //   );
  // }
}
