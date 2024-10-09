import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_project/data/model/post.dart';

class PostRepo {
  CollectionReference getCollection() {
    return FirebaseFirestore.instance.collection('post');
  }

  Stream<List<Post>> getAllPosts() {
    return getCollection()
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Post.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<String?> add(Post post, String currentUserId) async {
    final postMap = post.toMap();
    postMap['authorId'] = currentUserId;
    postMap['createdAt'] = FieldValue.serverTimestamp();

    final docRef = await getCollection().add(postMap);
    return docRef.id;
  }

  Future<void> delete(String id) async {
    await getCollection().doc(id).delete();
  }
}
