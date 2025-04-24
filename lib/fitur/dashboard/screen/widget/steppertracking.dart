import 'package:flutter/material.dart';

class MiniStepperTracking extends StatefulWidget {
  @override
  _MiniStepperState createState() => _MiniStepperState();
}

class _MiniStepperState extends State<MiniStepperTracking> {
  int _currentStep = 0;
  final List<String> _steps = ["Dikirim", "Diterima", "Diproses", "Selesai"];
  final List<Color> _circleColors = [
    Colors.blue,
    Colors.orange,
    Colors.deepOrange,
    Colors.green,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_steps.length, (index) {
            bool isActive = index <= _currentStep;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _currentStep = index;
                });
              },
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: _circleColors[index],
                    child:
                        isActive
                            ? Icon(
                              Icons.flag_circle_rounded,
                              size: 16,
                              color: const Color.fromARGB(255, 255, 255, 255),
                            )
                            : Icon(Icons.circle, size: 14, color: Colors.white),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _steps[index],
                    style: TextStyle(fontSize: 10, fontFamily: "Mulish"),
                  ),
                ],
              ),
            );
          }),
        ),
        // SizedBox(height: 8),
      ],
    );
  }
}
