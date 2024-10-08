class Post {
  final String? postId;
  final String title;
  final String desc;
  final String postImageUrl;

  Post(
      {this.postId,
      required this.title,
      required this.desc,
      required this.postImageUrl});

  Post copy({
    String? postId,
    String? title,
    String? desc,
    String? postImageUrl,
  }) {
    return Post(
      postId: postId ?? this.postId,
      title: title ?? this.title,
      desc: desc ?? this.desc,
      postImageUrl: postImageUrl ?? this.postImageUrl,
    );
  }

  @override
  String toString() {
    return "Food($postId, $title, $desc, $postImageUrl)";
  }

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "desc": desc,
      "postImageUrl": postImageUrl,
    };
  }

  static Post fromMap(Map<String, dynamic> map) {
    return Post(
      postId: map["postId"],
      title: map["title"],
      desc: map["desc"],
      postImageUrl: map["postImageUrl"],
    );
  }
}
