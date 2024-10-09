import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String? postId;
  final String authorId;
  final String title;
  final String desc;
  final String postImageUrl;
  final Timestamp? createdAt;

  Post({
    this.postId,
    required this.authorId,
    required this.title,
    required this.desc,
    required this.postImageUrl,
    this.createdAt,
  });

  Post copy({
    String? postId,
    String? authorId,
    String? title,
    String? desc,
    String? postImageUrl,
    Timestamp? createdAt,
  }) {
    return Post(
      postId: postId ?? this.postId,
      authorId: authorId ?? this.authorId,
      title: title ?? this.title,
      desc: desc ?? this.desc,
      postImageUrl: postImageUrl ?? this.postImageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return "Post($postId, $authorId, $title, $desc, $postImageUrl, $createdAt)";
  }

  Map<String, dynamic> toMap() {
    return {
      "authorId": authorId,
      "title": title,
      "desc": desc,
      "postImageUrl": postImageUrl,
    };
  }

  static Post fromMap(Map<String, dynamic> map, String docId) {
    return Post(
      postId: docId,
      authorId: map["authorId"] ?? '',
      title: map["title"] ?? '',
      desc: map["desc"] ?? '',
      postImageUrl: map["postImageUrl"] ?? '',
      createdAt: map["createdAt"] as Timestamp?,
    );
  }
}
