import 'package:flutter/material.dart';
import 'package:flutter_project/data/model/food.dart';
import 'package:flutter_project/data/repo/food_repo.dart';
import 'package:flutter_project/screens/add/add.dart';
import 'package:flutter_project/screens/card/food_item_card.dart';
import 'package:flutter_project/screens/food/food_info.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Food> foods = [];
  final repo = FoodRepo();

  void _init() async {
    await for (var res in repo.getAllFoods()) {
      setState(() {
        foods = res.where((food) {
          return !food.state && food.expiredDate.isAfter(DateTime.now());
        }).toList();
      });
    }
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  void _add() async {
    await context.pushNamed(Add.routeName);
    _init();
  }

  void _delete(String id) async {
    await repo.deleteFood(id);
    _init();
  }

  void _foodInfo(Food food) async {
    await context.pushNamed(FoodInfo.routeName, extra: food);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _add,
            child: const Icon(Icons.add),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            onPressed: () => {},
            child: const Icon(Icons.sort_rounded),
          ),
        ],
      ),
      body: GridView.builder(
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
            onTap: () => _foodInfo(foods[index]),
          );
        },
      ),
    );
  }
}
