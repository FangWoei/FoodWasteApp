import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/data/model/food.dart';
import 'package:flutter_project/data/repo/food_repo.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class Add extends StatefulWidget {
  const Add({super.key});
  static const routeName = "add";

  @override
  State<Add> createState() => _AddState();
}

class _AddState extends State<Add> {
  final repo = FoodRepo();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  String? nameError;
  String? categoryError;
  String? dateError;
  bool isLoading = false;

  String? _selectedCategory;
  final List<String> _categories = [
    'Vegetables',
    'Fruits',
    'Grains, legumes, nuts and seeds',
    'Meat and poultry',
    'Fish and seafood',
    'Eggs',
    'Others'
  ];

  File? _image;
  final ImagePicker _picker = ImagePicker();
  int _quantity = 1;

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    if (isLoading) return;

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<String> _uploadImage(File image) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${path.basename(image.path)}';
    final destination = 'food_images/$fileName';

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
    final name = nameController.text.trim();
    final date = _dateController.text;
    final desc = descController.text.trim();

    setState(() {
      nameError = name.isEmpty ? 'Please enter the food name' : null;
      categoryError =
          _selectedCategory == null ? 'Please select a category' : null;
      dateError = date.isEmpty ? 'Please select an expiry date' : null;
    });

    if (name.isEmpty || _selectedCategory == null || date.isEmpty) {
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      String imageUrl = '';
      if (_image != null) {
        imageUrl = await _uploadImage(_image!);
      }

      DateTime expiredDate = DateFormat('yyyy-MM-dd').parse(date);

      Food newFood = Food(
        name: name,
        category: _selectedCategory!,
        expiredDate: expiredDate,
        desc: desc,
        imageUrl: imageUrl,
        quantity: _quantity,
      );

      await repo.addFood(newFood);

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

  void _incrementQuantity() {
    if (!isLoading) {
      setState(() {
        _quantity++;
      });
    }
  }

  void _decrementQuantity() {
    if (!isLoading && _quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Food Item"),
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
                      controller: nameController,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        labelText: "Name",
                        errorText: nameError,
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
                      decoration: const InputDecoration(
                        labelText: "Description",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 300,
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: "Category",
                        errorText: categoryError,
                        border: const OutlineInputBorder(),
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: isLoading
                          ? null
                          : (String? newValue) {
                              setState(() {
                                _selectedCategory = newValue!;
                              });
                            },
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 300,
                    child: TextField(
                      controller: _dateController,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        labelText: "Expiry Date",
                        errorText: dateError,
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed:
                              isLoading ? null : () => _selectDate(context),
                        ),
                      ),
                      readOnly: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: isLoading ? null : _decrementQuantity,
                        icon: const Icon(Icons.remove),
                        color: Colors.red,
                      ),
                      Text(
                        '$_quantity',
                        style: const TextStyle(fontSize: 18),
                      ),
                      IconButton(
                        onPressed: isLoading ? null : _incrementQuantity,
                        icon: const Icon(Icons.add),
                        color: Colors.red,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: isLoading ? null : _add,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 50),
                    ),
                    child: const Text('Add Food Item'),
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
