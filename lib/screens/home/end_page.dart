import 'package:flutter/material.dart';
import 'package:flutter_project/data/model/food.dart';
import 'package:flutter_project/data/repo/food_repo.dart';
import 'package:flutter_project/screens/card/food_item_card.dart';

class EndPage extends StatefulWidget {
  const EndPage({super.key});

  @override
  State<EndPage> createState() => _EndPageState();
}

class _EndPageState extends State<EndPage> {
  List<Food> foods = [];
  final repo = FoodRepo();

  void _init() async {
    await for (var res in repo.getAllFoods()) {
      setState(() {
        foods = res.where((food) {
          return food.state || food.expiredDate.isBefore(DateTime.now());
        }).toList();
      });
    }
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  void _delete(String id) async {
    await repo.deleteFood(id);
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/end.jpg',
              fit: BoxFit.cover, // Ensures the image covers the entire screen
            ),
          ),
          // Foreground content
          foods.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.no_food,
                        size: 150,
                        color: Colors.white,
                      ),
                      Text(
                        'No foods yet',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: foods.length,
                  itemBuilder: (context, index) {
                    return FoodItemCard(
                      food: foods[index],
                      onDelete: () => _delete(foods[index].id ?? ''),
                      onTap: () => {},
                    );
                  },
                ),
        ],
      ),
    );
  }
}
