import 'package:flutter/material.dart';

class MiniStepperTracking extends StatefulWidget {
  final String status;

  MiniStepperTracking({Key? key, required this.status}) : super(key: key);

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
  void initState() {
    super.initState();
    _currentStep = _steps.indexWhere(
      (step) => step.toLowerCase() == widget.status.toLowerCase(),
    );
    if (_currentStep == -1) {
      _currentStep = 0; 
    }
  }

  @override
  void didUpdateWidget(covariant MiniStepperTracking oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status != widget.status) {
      setState(() {
        _currentStep = _steps.indexWhere(
          (step) => step.toLowerCase() == widget.status.toLowerCase(),
        );
        if (_currentStep == -1) {
          _currentStep = 0;
        }
      });
    }
  }

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
                // setState(() {
                //   _currentStep = index;
                // });
              },
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 10,
                    backgroundColor: _circleColors[index],
                    child:
                        isActive
                            ? Stack(children:[Icon(
                                Icons.circle,
                                size: 16,
                                color: _circleColors[index],
                              ),Icon(Icons.location_on,size: 16,color: Colors.white,)])
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
      ],
    );
  }
}
