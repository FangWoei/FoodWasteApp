import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_project/data/services/auth_service.dart';
import 'package:flutter_project/data/model/user.dart' as model;

class UserRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  String _getUid() {
    final uid = _authService.getUid();
    if (uid == null) {
      throw Exception("User doesn't exist");
    }
    return uid;
  }

  CollectionReference _getCollection() {
    return _firestore.collection('users');
  }

  Future<void> createUser(model.User user) async {
    await _getCollection().doc(_getUid()).set(user.toMap());
  }

  Future<model.User?> getUser() async {
    final res = await _getCollection().doc(_getUid()).get();
    if (res.data() != null) {
      return model.User.fromMap(res.data()! as Map<String, dynamic>);
    }
    return null;
  }
}