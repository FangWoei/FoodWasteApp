import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/data/model/food.dart';
import 'package:flutter_project/data/repo/food_repo.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
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

  // Image
  File? _image;
  final ImagePicker _picker = ImagePicker();

  // Quantity
  int _quantity = 1; // Initialize quantity to 1

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
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
    final fileName = path.basename(image.path);
    final destination = 'food_images/$fileName';

    try {
      final ref = FirebaseStorage.instance.ref(destination);
      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    }
  }

  void _add() async {
    final name = nameController.text;
    final date = _dateController.text;
    final desc = descController.text;

    setState(() {
      nameError = name.isEmpty ? 'Please enter your name' : null;
      categoryError =
          _selectedCategory == null ? 'Please select your category' : null;
      dateError = date.isEmpty ? 'Please enter your things expired date' : null;
    });

    if (nameError == null && categoryError == null && dateError == null) {
      DateTime expiredDate = DateFormat('yyyy-MM-dd').parse(date);

      String imageUrl = '';
      if (_image != null) {
        imageUrl = await _uploadImage(_image!);
      }

      Food newFood = Food(
        name: name,
        category: _selectedCategory!,
        expiredDate: expiredDate,
        desc: desc,
        imageUrl: imageUrl,
        quantity: _quantity, // Add quantity to Food object
      );

      await repo.addFood(newFood);
      Navigator.of(context).pop();
    }
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image Input
              Center(
                child: GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return SafeArea(
                          child: Wrap(
                            children: <Widget>[
                              ListTile(
                                leading: const Icon(Icons.photo_library),
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
                  maxLines: null,
                  decoration: const InputDecoration(
                    labelText: "Desc",
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
                  onChanged: (String? newValue) {
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
                  decoration: InputDecoration(
                    labelText: "Select Date",
                    errorText: dateError,
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context),
                    ),
                  ),
                  readOnly: true,
                ),
              ),
              const SizedBox(height: 16),

              // Quantity Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _decrementQuantity,
                    icon: const Icon(Icons.remove),
                    color: Colors.red,
                  ),
                  Text(
                    '$_quantity',
                    style: const TextStyle(fontSize: 18),
                  ),
                  IconButton(
                    onPressed: _incrementQuantity,
                    icon: const Icon(Icons.add),
                    color: Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: _add,
                child: const Text('Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
