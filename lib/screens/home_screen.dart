import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
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
  final Box dateBox = Hive.box("date");

  final ImagePicker _picker = ImagePicker();

  final TextEditingController _textEditingControllerTitle =
      TextEditingController();
  final TextEditingController _textEditingControllerDate =
      TextEditingController();

  void selectedDate() async {
    final DateTime? dateTimePicker = await showDatePicker(
      initialDate: DateTime.now(),
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
    );
    if (dateTimePicker != null) {
      setState(() {
        _textEditingControllerDate.text = dateTimePicker.toString().split(
          " ",
        )[0];
      });
    }
  }

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

  void showImagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppThemes.bottomSheetColor,
      builder: (context) {
        return SizedBox(
          height: 150,
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text(
                  'Camera',
                  style: TextStyle(color: AppThemes.appBarHeadLineColor),
                ),
                onTap: () {
                  Navigator.pop(context);
                  getImageFromCamera();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo),
                title: Text(
                  'Gallery',
                  style: TextStyle(color: AppThemes.appBarHeadLineColor),
                ),
                onTap: () {
                  Navigator.pop(context);
                  getImageFromGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void addTask() {
    if (_textEditingControllerTitle.text.trim().isNotEmpty &&
        _textEditingControllerDate.text.trim().isNotEmpty) {
      tasksBox.add(_textEditingControllerTitle.text.trim());
      _textEditingControllerTitle.clear();
      dateBox.add(_textEditingControllerDate.text.trim());
      _textEditingControllerDate.clear();
      Navigator.pop(context);
    }
  }

  void doneTasks(int index, String taskTitle, String taskDate) {
    doneTasksBox.add(taskTitle);
    dateBox.add(taskDate);
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
            onTap: showImagePicker,
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
                    controller: _textEditingControllerTitle,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppThemes.appBarHeadLineColor,
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: .circular(20)),
                      hintText: "What do you need to do?",
                    ),
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: _textEditingControllerDate,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppThemes.appBarHeadLineColor,
                    ),
                    decoration: InputDecoration(
                      fillColor: AppThemes.bottomSheetColor,
                      labelText: 'Date',
                      filled: true,
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(borderRadius: .circular(20)),
                      hintText: "Select a date to your task",
                    ),
                    readOnly: true,
                    onTap: selectedDate,
                  ),
                  SizedBox(height: 15),
                  SizedBox(
                    width: .infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppThemes.bottonColor,
                      ),
                      onPressed: addTask,
                      child: Text(
                        "Save Task",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: .bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        backgroundColor: AppThemes.bottonColor,
        child: Icon(Icons.add, size: 30, color: AppThemes.appBarHeadLineColor),
      ),
      body: ValueListenableBuilder(
        valueListenable: tasksBox.listenable(),
        builder: (context, Box box, child) {
          //شكل الشاشة لو مفيش تاسكات اضافت
          if (box.isEmpty && doneTasksBox.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: .center,
                children: [
                  Lottie.asset(
                    "assets/images/lottie.json",
                    height: 100,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.playlist_add_check,
                      size: 80,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "No Tasks Today! Add some.",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }
          //شكل الشاشة لو فيه تاسكات اضافات او تاسكات منتهية
          return ListView(
            padding: const EdgeInsets.all(15),
            children: [
              // ================= قسم المهام النشطة =================
              if (box.isNotEmpty) ...[
                const Text(
                  "Active Tasks 📝",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purpleAccent,
                  ),
                ),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: box.length,
                  itemBuilder: (context, index) {
                    final taskTitle = box.getAt(index).toString();
                    final taskDate = dateBox.getAt(index).toString();
                    return Card(
                      color: const Color(0xFF1D1D1D),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: IconButton(
                          icon: const Icon(
                            Icons.circle_outlined,
                            color: Colors.purpleAccent,
                          ),
                          onPressed: () => doneTasks(
                            index,
                            taskTitle,
                            taskDate,
                          ), // نقل للمخلصين عند الضغط
                        ),
                        title: Text(
                          taskTitle,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          taskDate,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white38,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                          ),
                          onPressed: () => box.deleteAt(index),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 25),
              ],

              // ================= قسم المهام المنتهية =================
              ValueListenableBuilder(
                valueListenable: doneTasksBox.listenable(),
                builder: (context, Box dBox, child) {
                  if (dBox.isEmpty && dateBox.isEmpty) return const SizedBox();
                  return kDoneSection(dBox,dateBox);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

// كود تصميم قسم المهام المنتهية (Done Tasks UI)
Widget kDoneSection(Box dBox,Box dateBox) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "Completed Tasks ✅",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      ),
      const SizedBox(height: 10),
      ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: dBox.length,
        itemBuilder: (context, index) {
          final taskTitle = dBox.getAt(index).toString();
          final taskDate = dateBox.getAt(index).toString();
          return Card(
            color: const Color(0xFF1A1A1A),
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: Text(
                taskTitle,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  decoration: TextDecoration.lineThrough,
                ), // خط في منتصف الكلام للاحترافية
              ),
              subtitle: Text(
                taskDate,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  decoration: TextDecoration.lineThrough,
                ), // خط في منتصف الكلام للاحترافية
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () => dBox.deleteAt(index),
              ),
            ),
          );
        },
      ),
    ],
  );
}
