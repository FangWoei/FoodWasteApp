import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_project/data/model/food.dart';
import 'package:flutter_project/data/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FoodRepo {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Keep existing methods for UI context
  CollectionReference getCollection() {
    final uid = _authService.getUid();
    if (uid == null) throw Exception("User doesn't exist!");
    return _firestore.collection('users/$uid/food_manage');
  }

  Stream<List<Food>> getAllFoods() {
    return getCollection().snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Food.fromMap(doc.data() as Map<String, dynamic>)
            .copy(id: doc.id);
      }).toList();
    });
  }

  // Add new methods for background context
  Future<String?> getCachedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  Future<CollectionReference> getBackgroundCollection() async {
    final uid = await getCachedUserId();
    if (uid == null) throw Exception("No cached user ID found!");
    return _firestore.collection('users/$uid/food_manage');
  }

  Future<List<Food>> getAllFoodsAsList() async {
    try {
      final collection = await getBackgroundCollection();
      final snapshot = await collection.get();

      return snapshot.docs.map((doc) {
        return Food.fromMap(doc.data() as Map<String, dynamic>)
            .copy(id: doc.id);
      }).toList();
    } catch (e) {
      print("Error fetching foods in background: $e");
      return [];
    }
  }

  // Add method to cache user ID
  Future<void> cacheUserId() async {
    final uid = _authService.getUid();
    if (uid != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', uid);
    }
  }

  // Keep other existing methods
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
