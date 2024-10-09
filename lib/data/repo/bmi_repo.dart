import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_project/data/model/bmi.dart';
import 'package:flutter_project/data/services/auth_service.dart';

class BmiRepo {
  final AuthService _authService = AuthService();

  CollectionReference getCollection() {
    final uid = _authService.getUid();
    if (uid == null) throw Exception("User doesn't exist!");
    return FirebaseFirestore.instance.collection('users/$uid/bmi_result');
  }

  Stream<List<BMI>> getAllFoods() {
    return getCollection().snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return BMI
            .fromMap(doc.data() as Map<String, dynamic>)
            .copy(bmiId: doc.id);
      }).toList();
    });
  }

  Future<String?> add(BMI bmi) async {
    final docRef = await getCollection().add(bmi.toMap());
    return docRef.id;
  }

  Future<void> delete(String id) async {
    await getCollection().doc(id).delete();
  }
}
