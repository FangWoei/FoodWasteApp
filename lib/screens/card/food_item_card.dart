import 'package:flutter/material.dart';
import 'package:flutter_project/data/model/food.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FoodItemCard extends StatelessWidget {
  final Food food;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const FoodItemCard({
    Key? key,
    required this.food,
    required this.onDelete,
    required this.onTap,
  }) : super(key: key);

  String getItemStatus(DateTime expiredDate) {
    if (food.state) return 'Finish';
    
    final currentDate = DateTime.now();
    if (expiredDate.isBefore(currentDate)) return 'Expired';
    
    final difference = expiredDate.difference(currentDate).inDays;
    return difference <= 7 ? 'Expiring Soon' : 'Good';
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Finish':
        return Colors.blue;
      case 'Expired':
        return Colors.red;
      case 'Expiring Soon':
        return Colors.yellow;
      case 'Good':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = getItemStatus(food.expiredDate);
    final statusColor = getStatusColor(status);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                ),
                child: food.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: food.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      )
                    : Center(
                        child: Icon(Icons.image,
                            size: 50, color: Colors.grey[600])),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          food.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: onDelete,
                        child: const Icon(Icons.delete, color: Colors.red, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Qty: ${food.quantity}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    food.category,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        DateFormat('yyyy-MM-dd').format(food.expiredDate),
                        style: const TextStyle(fontSize: 10),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          status,
                          style: const TextStyle(fontSize: 10, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}