import 'package:flutter/material.dart';
import 'package:flutter_project/data/model/bmi.dart';
import 'package:flutter_project/data/repo/bmi_repo.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_project/screens/card/bmi_input_card.dart';
import 'package:flutter_project/screens/card/bmi_result_card.dart';
import 'package:flutter_project/screens/card/bmi_history_card.dart';

class BmiPage extends StatefulWidget {
  const BmiPage({super.key});

  @override
  State<BmiPage> createState() => _BmiPageState();
}

class _BmiPageState extends State<BmiPage> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final BmiRepo _bmiRepo = BmiRepo();
  double _bmiResult = 0;
  String _bmiCategory = '';
  Color _indicatorColor = Colors.transparent;
  bool _isLoading = false;

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Color _getBmiColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  String _getBmiCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Future<void> _calculateBMI() async {
    double height = double.tryParse(_heightController.text) ?? 0;
    double weight = double.tryParse(_weightController.text) ?? 0;

    if (height > 0 && weight > 0) {
      setState(() => _isLoading = true);

      try {
        double heightInMeters = height / 100;
        double bmi = weight / (heightInMeters * heightInMeters);

        double result = double.parse(bmi.toStringAsFixed(1));
        String category = _getBmiCategory(result);
        Color color = _getBmiColor(result);

        // Save to Firestore
        await _bmiRepo.add(BMI(
          result: result.toString(),
          dateCreate: DateTime.now(),
        ));

        setState(() {
          _bmiResult = result;
          _bmiCategory = category;
          _indicatorColor = color;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.cyan, Colors.purple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BmiInputCard(
                  heightController: _heightController,
                  weightController: _weightController,
                  onCalculate: _calculateBMI,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 24),
                if (_bmiResult > 0) ...[
                  BmiResultCard(
                    bmiResult: _bmiResult,
                    bmiCategory: _bmiCategory,
                    indicatorColor: _indicatorColor,
                  ),
                  const SizedBox(height: 24),
                ],
                BmiHistoryCard(
                  bmiStream: _bmiRepo.getAllFoods(),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: SpinKitFoldingCube(
                  color: Colors.cyan,
                  size: 50.0,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
