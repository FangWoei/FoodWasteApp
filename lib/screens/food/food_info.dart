import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/data/model/food.dart';
import 'package:flutter_project/data/repo/food_repo.dart';
import 'package:intl/intl.dart';

class FoodInfo extends StatefulWidget {
  final Food food;

  const FoodInfo({super.key, required this.food});
  static const routeName = "food_info";

  @override
  State<FoodInfo> createState() => _FoodInfoState();
}

class _FoodInfoState extends State<FoodInfo> {
  late int _quantity;
  final repo = FoodRepo();

  @override
  void initState() {
    super.initState();
    _quantity = widget.food.quantity;
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
      _updateFood();
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
        _updateFood();
      });
    }
  }

  void _updateFood() async {
    final updatedFood = widget.food.copy(quantity: _quantity);
    await repo.updateFood(updatedFood);
  }

  void _updateFoodState({newState}) async {
    final updatedFood = widget.food.copy(
      state: newState ?? widget.food.state,
    );
    await repo.updateFood(updatedFood);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Food Info"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            widget.food.imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: widget.food.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  )
                : const Card(
                    margin: EdgeInsets.all(10.0),
                    child: Icon(Icons.no_food, size: 100),
                  ),
            const SizedBox(height: 16),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.food.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.food.desc,
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Category: ${widget.food.category}",
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${DateFormat('yyyy-MM-dd').format(widget.food.expiredDate)}',
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _decrementQuantity,
                      icon: const Icon(Icons.remove),
                      color: Colors.red,
                    ),
                    Text('$_quantity', style: const TextStyle(fontSize: 18)),
                    IconButton(
                      onPressed: _incrementQuantity,
                      icon: const Icon(Icons.add),
                      color: Colors.red,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  "If you finish this Food, please click this button",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _updateFoodState(newState: true);
                    });
                  },
                  child: Text(widget.food.state ? 'Finished' : 'Finish'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
