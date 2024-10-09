import 'package:flutter/material.dart';

class BmiInputCard extends StatelessWidget {
  final TextEditingController heightController;
  final TextEditingController weightController;
  final VoidCallback onCalculate;
  final bool isLoading;

  const BmiInputCard({
    Key? key,
    required this.heightController,
    required this.weightController,
    required this.onCalculate,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Enter your details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: heightController,
              keyboardType: TextInputType.number,
              enabled: !isLoading,
              decoration: const InputDecoration(
                labelText: 'Height (cm)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.height),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              enabled: !isLoading,
              decoration: const InputDecoration(
                labelText: 'Weight (kg)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.line_weight),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isLoading ? null : onCalculate,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Calculate BMI'),
            ),
          ],
        ),
      ),
    );
  }
}