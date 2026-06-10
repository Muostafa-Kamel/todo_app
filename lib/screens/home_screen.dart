import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todo_app/core/theme/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Box tasksBox = Hive.box("tasks");
  final Box doneTasksBox = Hive.box("doneTasks");
  final Box userBox = Hive.box("imagePath");

  late final ImagePicker _picker;

  final TextEditingController _textEditingController = TextEditingController();

  void getImageFromGallery() async {
    var _imagePath = await _picker.pickImage(source: ImageSource.gallery);
    if (_imagePath != null) {
      setState(() {
        userBox.put("imagePath", _imagePath.path);
      });
    }
  }

  void getImageFromCamera() async {
    final _imagePath = await _picker.pickImage(source: ImageSource.camera);
    if (_imagePath != null) {
      setState(() {
        userBox.put("imagePath", _imagePath.path);
      });
    }
  }

  void addTask() {
    if (_textEditingController.text.trim().isNotEmpty) {
      tasksBox.add(_textEditingController.text.trim());
      _textEditingController.clear();
      Navigator.pop(context);
    }
  }

  void doneTasks(int index, String taskTitle) {
    doneTasksBox.add(taskTitle);
    tasksBox.delete(index);
  }

  @override
  Widget build(BuildContext context) {
    //Reading image path
    String? path = userBox.get("imagePath");
    return Scaffold(
      backgroundColor: AppThemes.appPrimaryColor,
      appBar: AppBar(
        actionsPadding: EdgeInsets.all(10),
        backgroundColor: AppThemes.appBarColor,
        title: Text("Taskati 🚀", style: AppThemes.appBarTextStyle),
        actions: [
          GestureDetector(
            onTap: getImageFromCamera,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: AppThemes.bottonColor,
              backgroundImage: path != null ? FileImage(File(path)) : null,
              child: path == null
                  ? Icon(Icons.add_a_photo, size: 18, color: Colors.white)
                  : null,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            backgroundColor: AppThemes.bottomSheetColor,
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: .vertical(top: .circular(20)),
            ),
            builder: (context) => Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Column(
                mainAxisSize: .min,
                children: [
                  TextFormField(
                    controller: _textEditingController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: .circular(20)),
                      hintText: "What do you need to do?",
                    ),
                  )
                ],
              ),
            ),
          );
        },
        backgroundColor: AppThemes.bottonColor,
        child: Icon(Icons.add, size: 30, color: AppThemes.appBarHeadLineColor),
      ),
      body: Column(),
    );
  }
}
