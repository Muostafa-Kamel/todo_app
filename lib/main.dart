import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:todo_app/screens/home_screen.dart';

void main() async {
  //طالما خليت ال main async يبقى لازم اكتب سطر الكود دا
  WidgetsFlutterBinding.ensureInitialized();
  //دا لازم ابدأ بيه عند التعامل مع هايف علشان يبدا يجبلي كل ال محتاجه التطبيق علشان اتعامل مع هايف
  await Hive.initFlutter();

  await Hive.openBox("tasks");
  await Hive.openBox("doneTasks");
  await Hive.openBox("imagePath");

  runApp(MaterialApp(home: HomeScreen()));
}
