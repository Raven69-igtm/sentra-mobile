import 'package:flutter/material.dart';

class NumberSpinner extends StatefulWidget {
  final int min;
  final int max;
  final int initialValue;
  final ValueChanged<int> onChanged;

  const NumberSpinner({
    super.key,
    this.min = 0,
    this.max = 100,
    this.initialValue = 0,
    required this.onChanged,
  });

  @override
  _NumberSpinnerState createState() => _NumberSpinnerState();
}

class _NumberSpinnerState extends State<NumberSpinner> {
  late int currentValue;

  @override
  void initState() {
    super.initState();
    currentValue = widget.initialValue;
  }

  void _increment() {
    setState(() {
      if (currentValue < widget.max) {
        currentValue++;
        widget.onChanged(currentValue);
      }
    });
  }

  void _decrement() {
    setState(() {
      if (currentValue > widget.min) {
        currentValue--;
        widget.onChanged(currentValue);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.remove_circle_outline),
          onPressed: _decrement,
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text('$currentValue', style: TextStyle(fontSize: 18)),
        ),
        IconButton(icon: Icon(Icons.add_circle_outline), onPressed: _increment),
      ],
    );
  }
}
