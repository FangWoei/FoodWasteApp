import 'dart:io';
import 'package:flutter_project/data/model/post.dart';
import 'package:flutter_project/data/repo/user_repo.dart';
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/data/repo/post_repo.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AddPost extends StatefulWidget {
  const AddPost({super.key});
  static const routeName = "add_post";

  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  final repo = PostRepo();
  final userRepo = UserRepo();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  String? titleError;
  String? descError;
  bool isLoading = false;

  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<String> _uploadImage(File image) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${path.basename(image.path)}';
    final destination = 'posts/$fileName';

    try {
      final ref = FirebaseStorage.instance.ref(destination);
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      throw Exception('Failed to upload image');
    }
  }

  Future<void> _add() async {
    final title = titleController.text.trim();
    final desc = descController.text.trim();

    // Validate inputs
    setState(() {
      titleError = title.isEmpty ? 'Please enter a title' : null;
      descError = desc.isEmpty ? 'Please enter a description' : null;
    });

    if (title.isEmpty || desc.isEmpty) {
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      // Get current user ID
      final currentUserId = await userRepo.getCurrentUserId();
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }

      // Upload image if selected
      String imageUrl = '';
      if (_image != null) {
        imageUrl = await _uploadImage(_image!);
      }

      // Create and add post
      final newPost = Post(
        title: title,
        desc: desc,
        postImageUrl: imageUrl,
        authorId: currentUserId,
      );

      await repo.add(newPost, currentUserId);

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Post"),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: isLoading
                          ? null
                          : () {
                              showModalBottomSheet(
                                context: context,
                                builder: (BuildContext context) {
                                  return SafeArea(
                                    child: Wrap(
                                      children: <Widget>[
                                        ListTile(
                                          leading:
                                              const Icon(Icons.photo_library),
                                          title: const Text('Photo Library'),
                                          onTap: () {
                                            _pickImage(ImageSource.gallery);
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                      child: Container(
                        width: 300,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(color: Colors.grey),
                        ),
                        child: _image != null
                            ? Image.file(_image!, fit: BoxFit.cover)
                            : const Icon(Icons.add_a_photo, size: 50),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 300,
                    child: TextField(
                      controller: titleController,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        labelText: "Title",
                        errorText: titleError,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 300,
                    child: TextField(
                      controller: descController,
                      enabled: !isLoading,
                      maxLines: null,
                      decoration: InputDecoration(
                        labelText: "Description",
                        errorText: descError,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: isLoading ? null : _add,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 50),
                    ),
                    child: const Text('Add Post'),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: SpinKitFoldingCube(
                  color: Colors.cyan,
                  size: 50.0,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
