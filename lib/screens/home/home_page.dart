import 'package:flutter/material.dart';
import 'package:flutter_project/data/model/food.dart';
import 'package:flutter_project/data/repo/food_repo.dart';
import 'package:flutter_project/data/services/notification_services.dart';
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
  final NotificationService _notificationService = NotificationService();
  String? _selectedCategory;

  final List<String> _categories = [
    'All',
    'Vegetables',
    'Fruits',
    'Grains, legumes, nuts and seeds',
    'Meat and poultry',
    'Fish and seafood',
    'Eggs',
    'Others'
  ];

  void _init() async {
    await for (var res in repo.getAllFoods()) {
      setState(() {
        foods = res.where((food) {
          return !food.state && food.expiredDate.isAfter(DateTime.now());
        }).toList();

        _sortFoods();
        _notificationService.checkFoodExpiry(res);
      });
    }
  }

  @override
  void initState() {
    _init();
    super.initState();
    _initNotifications();
  }

  void _initNotifications() async {
    await _notificationService.initNotification();
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

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sort by Category'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _categories.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(_categories[index]),
                  onTap: () {
                    setState(() {
                      _selectedCategory = _categories[index] == 'All'
                          ? null
                          : _categories[index];
                    });
                    Navigator.of(context).pop();
                    _init();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _sortFoods() {
    if (_selectedCategory == null || _selectedCategory == 'All') {
      foods.sort((a, b) => a.expiredDate.compareTo(b.expiredDate));
    } else {
      foods =
          foods.where((food) => food.category == _selectedCategory).toList();
      foods.sort((a, b) => a.expiredDate.compareTo(b.expiredDate));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(_selectedCategory ?? ''),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _add,
            child: const Icon(Icons.add),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            onPressed: _showSortDialog,
            child: const Icon(Icons.sort_rounded),
          ),
        ],
      ),
      body: foods.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.no_food, size: 150),
                  Text(
                    'No foods yet',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                  onTap: () => _foodInfo(foods[index]),
                );
              },
            ),
    );
  }
}
