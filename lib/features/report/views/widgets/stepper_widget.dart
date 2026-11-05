import 'package:flutter/material.dart';

class MiniStepper extends StatefulWidget {
  final int currentStep;
  final List<String>? steps;

  const MiniStepper({
    super.key,
    required this.currentStep,
    this.steps,
  });

  @override
  _MiniStepperState createState() => _MiniStepperState();
}

class _MiniStepperState extends State<MiniStepper> {
  @override
  Widget build(BuildContext context) {
    final stepList = widget.steps ?? ["Data Diri", "Kronologi", "Waktu & Lokasi"];
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(stepList.length, (index) {
            bool isActive = index <= widget.currentStep;
            return Column(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: isActive ? Colors.green : Colors.grey[300],
                  child:
                      isActive
                          ? Icon(Icons.check, size: 14, color: Colors.white)
                          : Text(
                              "${index + 1}",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                ),
                SizedBox(height: 4),
                Text(
                  stepList[index],
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: "Mulish",
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    color: isActive ? Colors.green.shade800 : Colors.grey[600],
                  ),
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
