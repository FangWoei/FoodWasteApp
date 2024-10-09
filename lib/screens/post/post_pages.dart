import 'package:flutter/material.dart';
import 'package:flutter_project/data/model/post.dart';
import 'package:flutter_project/data/repo/post_repo.dart';
import 'package:flutter_project/data/repo/user_repo.dart';
import 'package:flutter_project/screens/card/post_item_card.dart';
import 'package:flutter_project/screens/post/add_post.dart';
import 'package:go_router/go_router.dart';

class PostPages extends StatefulWidget {
  const PostPages({super.key});

  @override
  State<PostPages> createState() => _PostPagesState();
}

class _PostPagesState extends State<PostPages> {
  List<Post> posts = [];
  final repo = PostRepo();
  final UserRepo _userRepo = UserRepo();
  String? _currentUserId;

  void _init() async {
    await for (var res in repo.getAllPosts()) {
      setState(() {
        posts = res;
      });
    }
  }

  Future<void> _getCurrentUserId() async {
    final user = await _userRepo.getUser();
    if (user != null) {
      setState(() {
        _currentUserId = user.userId;
      });
    }
  }

  @override
  void initState() {
    _init();
    super.initState();
    _getCurrentUserId();
  }

  void _add() async {
    await context.pushNamed(AddPost.routeName);
    _init();
  }

  void _delete(String id) async {
    await repo.delete(id);
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _add,
        child: const Icon(Icons.post_add),
      ),
      body: Stack(children: [
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.cyan, Colors.green],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            childAspectRatio: 0.9,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
          ),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return PostItemCard(
              post: posts[index],
              onDelete: () => _delete(posts[index].postId ?? ''),
              currentUserId: _currentUserId ?? '',
            );
          },
        ),
      ]),
    );
  }
}
