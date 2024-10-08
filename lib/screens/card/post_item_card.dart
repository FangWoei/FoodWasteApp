import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/data/model/post.dart';

class PostItemCard extends StatelessWidget {
  final Post post;
  final VoidCallback onDelete;
  final String currentUserId;

  const PostItemCard({
    Key? key,
    required this.post,
    required this.onDelete,
    required this.currentUserId,
  }) : super(key: key);

  bool get canDeletePost => currentUserId == post.authorId;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(
          child: post.postImageUrl.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: post.postImageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                )
              : Icon(Icons.image, size: 50, color: Colors.grey[600]),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 20.0),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                post.desc,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              if (canDeletePost)
                GestureDetector(
                  onTap: onDelete,
                  child: const Icon(Icons.delete, color: Colors.red, size: 20),
                )
            ],
          ),
        ),
      ]),
    );
  }
}