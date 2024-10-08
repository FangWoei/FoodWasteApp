import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_project/screens/post/post.dart';

class PostRepo {
  CollectionReference getCollection() {
    return FirebaseFirestore.instance.collection('post');
  }

  Stream<List<Post>> getAllPost() {
    return getCollection().snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Post.fromMap(doc.data() as Map<String, dynamic>)
            .copy(id: doc.id);
      }).toList();
    });
  }
}
