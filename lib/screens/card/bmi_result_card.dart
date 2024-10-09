import 'package:flutter/material.dart';
import 'dart:math';

class BmiResultCard extends StatelessWidget {
  final double bmiResult;
  final String bmiCategory;
  final Color indicatorColor;

  const BmiResultCard({
    Key? key,
    required this.bmiResult,
    required this.bmiCategory,
    required this.indicatorColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Your BMI Result',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(200, 200),
                    painter: BMIGaugePainter(bmiResult),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        bmiResult.toString(),
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      Text(
                        bmiCategory,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: indicatorColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BMIGaugePainter extends CustomPainter {
  final double bmiValue;

  BMIGaugePainter(this.bmiValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;

    void drawArc(double startAngle, double sweepAngle, Color color) {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }

    drawArc(pi, 0.85, Colors.red);
    drawArc(2.29, 0.85, Colors.green);
    drawArc(1.44, 0.85, Colors.orange);
    drawArc(0.59, 0.85, Colors.pink);

    final needleAngle = pi - (bmiValue - 20) * (2.55 / 20);
    final needlePaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final needleLength = radius - 10;
    final needleEnd = Offset(
      center.dx + needleLength * cos(needleAngle),
      center.dy + needleLength * sin(needleAngle),
    );

    canvas.drawLine(center, needleEnd, needlePaint);

    final centerPointPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 5, centerPointPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}