import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_project/data/model/food.dart';
import 'package:flutter_project/data/services/auth_service.dart';

class FoodRepo {
  final AuthService _authService = AuthService();

  CollectionReference getCollection() {
    final uid = _authService.getUid();
    if (uid == null) throw Exception("User doesn't exist!");
    return FirebaseFirestore.instance.collection('users/$uid/food_manage');
  }

  Stream<List<Food>> getAllFoods() {
    return getCollection().snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Food.fromMap(doc.data() as Map<String, dynamic>)
            .copy(id: doc.id);
      }).toList();
    });
  }

  Future<String?> addFood(Food food) async {
    final docRef = await getCollection().add(food.toMap());
    return docRef.id;
  }

  Future<void> deleteFood(String id) async {
    await getCollection().doc(id).delete();
  }

  Future<void> updateFood(Food food) async {
    if (food.id == null) {
      throw Exception("Food ID cannot be null for update operation");
    }
    await getCollection().doc(food.id).update(food.toMap());
  }

  Future<Food?> getFoodById(String id) async {
    final doc = await getCollection().doc(id).get();
    return doc.exists
        ? Food.fromMap(doc.data() as Map<String, dynamic>).copy(id: doc.id)
        : null;
  }

}
