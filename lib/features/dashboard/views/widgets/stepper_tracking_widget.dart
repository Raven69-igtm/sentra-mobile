import 'package:flutter/material.dart';

class MiniStepperTracking extends StatefulWidget {
  final String status;

  const MiniStepperTracking({super.key, required this.status});

  @override
  _MiniStepperState createState() => _MiniStepperState();
}

class _MiniStepperState extends State<MiniStepperTracking> {
  static const List<String> _stepLabels = [
    'Dikirim',
    'Diterima',
    'Diproses',
    'Selesai',
  ];

  static const List<Color> _stepColors = <Color>[
    Colors.blue,
    Colors.orange,
    Colors.deepOrange,
    Colors.green,
  ];

  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _currentStep = _mapStatusToStep(widget.status);
  }

  @override
  void didUpdateWidget(covariant MiniStepperTracking oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status != widget.status) {
      setState(() {
        _currentStep = _mapStatusToStep(widget.status);
      });
    }
  }

  int _mapStatusToStep(String status) {
    final String normalized = status.trim().toLowerCase();
    final int stepIndex = _stepLabels.indexWhere(
      (label) => label.toLowerCase() == normalized,
    );
    return stepIndex < 0 ? 0 : stepIndex;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double circleDiameter = 28;
        final double connectorHeight = 4;
        final Duration animDuration = const Duration(milliseconds: 300);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: List.generate(_stepLabels.length * 2 - 1, (int i) {
                if (i.isOdd) {
                  final int leftStep = (i - 1) ~/ 2;
                  final bool isFilled = _currentStep > leftStep;
                  return Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LayoutBuilder(
                        builder: (context, connectorConstraints) {
                          final double maxW = connectorConstraints.maxWidth;
                          final double targetW = isFilled ? maxW : 0;
                          return Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              Container(
                                height: connectorHeight,
                                width: maxW,
                                color: Colors.grey.shade300,
                              ),
                              AnimatedContainer(
                                duration: animDuration,
                                curve: Curves.easeInOut,
                                height: connectorHeight,
                                width: targetW,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      _colorForStep(leftStep).withOpacity(0.9),
                                      _colorForStep(
                                        leftStep + 1,
                                      ).withOpacity(0.9),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  );
                } else {
                  final int stepIndex = i ~/ 2;
                  return _StepCircle(
                    diameter: circleDiameter,
                    color: _colorForStep(stepIndex),
                    state: _stateForIndex(stepIndex),
                    duration: animDuration,
                  );
                }
              }),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_stepLabels.length, (int index) {
                return Expanded(
                  child: Align(
                    alignment:
                        index == 0
                            ? Alignment.centerLeft
                            : index == _stepLabels.length - 1
                            ? Alignment.centerRight
                            : Alignment.center,
                    child: Text(
                      _stepLabels[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Mulish',
                        fontSize: 11,
                        fontWeight:
                            index <= _currentStep
                                ? FontWeight.w700
                                : FontWeight.w500,
                        color:
                            index <= _currentStep
                                ? Colors.black87
                                : Colors.black54,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }

  Color _colorForStep(int index) {
    if (index < 0) return _stepColors.first;
    if (index >= _stepColors.length) return _stepColors.last;
    return _stepColors[index];
  }

  _StepState _stateForIndex(int index) {
    if (index < _currentStep) return _StepState.completed;
    if (index == _currentStep) return _StepState.active;
    return _StepState.inactive;
  }
}

enum _StepState { inactive, active, completed }

class _StepCircle extends StatelessWidget {
  final double diameter;
  final Color color;
  final _StepState state;
  final Duration duration;

  const _StepCircle({
    required this.diameter,
    required this.color,
    required this.state,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = state == _StepState.active;
    final bool isCompleted = state == _StepState.completed;

    return SizedBox(
      width: diameter,
      height: diameter,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedContainer(
            duration: duration,
            width: diameter,
            height: diameter,
            decoration: BoxDecoration(
              color: isCompleted ? color : Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color:
                    isCompleted
                        ? color
                        : (isActive ? color : Colors.grey.shade300),
                width: isCompleted ? 0 : 2,
              ),
              boxShadow:
                  isActive
                      ? [
                        BoxShadow(
                          color: color.withOpacity(0.35),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ]
                      : [],
            ),
            child: AnimatedSwitcher(
              duration: duration,
              child:
                  isCompleted
                      ? Icon(
                        Icons.check_rounded,
                        key: const ValueKey('check'),
                        size: diameter * 0.6,
                        color: Colors.white,
                      )
                      : isActive
                      ? _ActiveInnerDot(
                        key: const ValueKey('active'),
                        color: color,
                        diameter: diameter,
                      )
                      : const SizedBox.shrink(key: ValueKey('empty')),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveInnerDot extends StatefulWidget {
  final Color color;
  final double diameter;

  const _ActiveInnerDot({
    super.key,
    required this.color,
    required this.diameter,
  });

  @override
  State<_ActiveInnerDot> createState() => _ActiveInnerDotState();
}

class _ActiveInnerDotState extends State<_ActiveInnerDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scale = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double inner = widget.diameter * 0.5;

    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: inner,
        height: inner,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}
