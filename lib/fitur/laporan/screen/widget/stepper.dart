import 'package:flutter/material.dart';

class MiniStepper extends StatefulWidget {
  final int currentStep;

  const MiniStepper({
    Key? key,
    required this.currentStep,
  }) : super(key: key);

  @override
  _MiniStepperState createState() => _MiniStepperState();
}

class _MiniStepperState extends State<MiniStepper> {
  final List<String> _steps = ["Form 1", "Form 2", "Form 3", "Form 4","Form 5"];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_steps.length, (index) {
            bool isActive = index <= widget.currentStep;
            return Column(
              children: [
                CircleAvatar(
                  radius: 10,
                  backgroundColor: isActive ? Colors.green : Colors.grey[300],
                  child:
                      isActive
                          ? Icon(Icons.check, size: 14, color: Colors.white)
                          : null,
                ),
                SizedBox(height: 4),
                Text(
                  _steps[index],
                  style: TextStyle(fontSize: 10, fontFamily: "Mulish"),
                ),
              ],
            );
          }),
        ),
        SizedBox(height: 8),
      ],
    );
  }
}
