import 'package:flutter/material.dart';
import 'package:flutter_project/data/model/bmi.dart';
import 'package:flutter_project/data/repo/bmi_repo.dart';
import 'package:flutter_project/screens/card/bmi_item_card.dart';

class BmiHistoryCard extends StatefulWidget {
  final Stream<List<BMI>> bmiStream;

  const BmiHistoryCard({
    Key? key,
    required this.bmiStream,
  }) : super(key: key);

  @override
  State<BmiHistoryCard> createState() => _BmiHistoryCardState();
}

class _BmiHistoryCardState extends State<BmiHistoryCard> {
  final BmiRepo _bmiRepo = BmiRepo();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'History',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        StreamBuilder<List<BMI>>(
          stream: widget.bmiStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final bmiRecords = snapshot.data!;

            if (bmiRecords.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'No BMI records yet',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: bmiRecords.length,
              itemBuilder: (context, index) {
                final bmi = bmiRecords[index];
                return BmiItemCard(
                  bmi: bmi,
                  onDelete: bmi.bmiId != null
                      ? () => _bmiRepo.delete(bmi.bmiId!)
                      : null,
                );
              },
            );
          },
        ),
      ],
    );
  }
}
