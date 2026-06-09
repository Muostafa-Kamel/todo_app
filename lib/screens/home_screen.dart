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
    if(_imagePath != null){
      setState(() {
        userBox.put("imagePath", _imagePath.path);
      });
    }
  }

  void getImageFromCamera() async {
    final _imagePath = await _picker.pickImage(source: ImageSource.camera);
    if(_imagePath != null){
      setState(() {
        userBox.put("imagePath", _imagePath.path);
      });
    }

  }

  void addTask(){
    if(_textEditingController.text.trim().isNotEmpty){
      tasksBox.add(_textEditingController.text.trim());
      _textEditingController.clear();
      Navigator.pop(context);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actionsPadding: EdgeInsets.all(10),
        backgroundColor: AppThemes.appBarColor,
        title: Text("Taskati 🚀", style: AppThemes.appBarTextStyle),
        actions: [
          GestureDetector(
            onTap: () {

            },
            child: CircleAvatar(
              radius: 20,

            ),
          ),
        ],
      ),
      body: Column(),
    );
  }
}
