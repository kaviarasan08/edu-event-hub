import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  // final IconData icon;
  final TextEditingController controller; // 👈 added controller
  final bool isPassword;
  final int maxLines;

  const CustomTextField({
    super.key,
    required this.label,
    // required this.icon,
    required this.controller,
    this.isPassword = false,
    this.maxLines = 1,
  });

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {}); // rebuild when focus changes
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  bool isVisible = false;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return TextField(
      controller: widget.controller, // 👈 bind controller
      focusNode: _focusNode,
      obscureText: isVisible,
      maxLines: widget.maxLines,
      decoration: InputDecoration(
        labelText: widget.label,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        hintText: 'Enter Your ${widget.label}',
        // prefix: Icon(widget.icon),
        suffixIcon: (widget.isPassword)
            ? IconButton(
                icon: (isVisible)
                    ? Icon(Icons.visibility_sharp)
                    : Icon(Icons.visibility_off_sharp),
                onPressed: () {
                  setState(() {
                    isVisible = !isVisible;
                  });
                },
                color: _focusNode.hasFocus
                    ? primaryColor
                    : Colors.grey, // 👈 focus color
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: primaryColor.withOpacity(0.5),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor, width: 2.5),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
