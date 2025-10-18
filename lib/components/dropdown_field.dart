import 'package:flutter/material.dart';

class CustomDropdownField<T> extends StatefulWidget {
  final String label;
  final List<T> items;
  final T? value;
  final void Function(T?) onChanged;
  final bool isDict;

  const CustomDropdownField({
    super.key,
    required this.label,
    required this.items,
    required this.value,
    required this.onChanged,
    this.isDict = false,
  });

  @override
  State<CustomDropdownField<T>> createState() => _CustomDropdownFieldState<T>();
}

class _CustomDropdownFieldState<T> extends State<CustomDropdownField<T>> {
  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return InputDecorator(
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: widget.value,
          hint: Text(widget.label),
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: primaryColor),
          items: widget.items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(item.toString()),
            );
          }).toList(),
          onChanged: widget.onChanged,
        ),
      ),
    );
  }
}
