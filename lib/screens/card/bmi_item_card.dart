import 'package:flutter/material.dart';
import 'package:flutter_project/data/model/bmi.dart';
import 'package:intl/intl.dart';

class BmiItemCard extends StatelessWidget {
  final BMI bmi;
  final VoidCallback? onDelete;

  const BmiItemCard({
    super.key,
    required this.bmi,
    this.onDelete,
  });

  Color _getBmiColor(double bmiValue) {
    if (bmiValue < 18.5) return Colors.blue;
    if (bmiValue < 25) return Colors.green;
    if (bmiValue < 30) return Colors.orange;
    return Colors.red;
  }

  String _getBmiCategory(double bmiValue) {
    if (bmiValue < 18.5) return 'Underweight';
    if (bmiValue < 25) return 'Normal';
    if (bmiValue < 30) return 'Overweight';
    return 'Obese';
  }

  @override
  Widget build(BuildContext context) {
    final bmiValue = double.tryParse(bmi.result) ?? 0.0;
    final color = _getBmiColor(bmiValue);
    final category = _getBmiCategory(bmiValue);

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BMI Score',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          bmi.result,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: color,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: onDelete,
                    color: Colors.grey,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              category,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('MMMM dd, yyyy - HH:mm').format(bmi.dateCreate),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
