import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_project/data/model/post.dart';

class PostRepo {
  CollectionReference getCollection() {
    return FirebaseFirestore.instance.collection('post');
  }

  Stream<List<Post>> getAllPosts() {
    return getCollection().snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Post.fromMap(doc.data() as Map<String, dynamic>)
            .copy(postId: doc.id);
      }).toList();
    });
  }

  Future<String?> add(Post post, String currentUserId) async {
    final postWithAuthor = post.copy(authorId: currentUserId);
    final docRef = await getCollection().add(postWithAuthor.toMap());
    return docRef.id;
  }

  Future<void> delete(String id) async {
    await getCollection().doc(id).delete();
  }
}
