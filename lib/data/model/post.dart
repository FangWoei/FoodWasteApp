class Post {
  final String? postId;
  final String authorId;
  final String title;
  final String desc;
  final String postImageUrl;

  Post(
      {this.postId,
      required this.authorId,
      required this.title,
      required this.desc,
      required this.postImageUrl});

  Post copy({
    String? postId,
    String? authorId,
    String? title,
    String? desc,
    String? postImageUrl,
  }) {
    return Post(
      postId: postId ?? this.postId,
      authorId: authorId ?? this.authorId,
      title: title ?? this.title,
      desc: desc ?? this.desc,
      postImageUrl: postImageUrl ?? this.postImageUrl,
    );
  }

  @override
  String toString() {
    return "Post($postId, $authorId, $title, $desc, $postImageUrl)";
  }

  Map<String, dynamic> toMap() {
    return {
      "authorId": authorId,
      "title": title,
      "desc": desc,
      "postImageUrl": postImageUrl,
    };
  }

  static Post fromMap(Map<String, dynamic> map) {
    return Post(
      postId: map["postId"],
      authorId: map["authorId"],
      title: map["title"],
      desc: map["desc"],
      postImageUrl: map["postImageUrl"],
    );
  }
}
