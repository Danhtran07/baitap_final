import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/task_list_screen.dart';
import 'sqflite_init/sqflite_init.dart';
import 'viewmodels/task_list_viewmodel.dart';
import 'viewmodels/add_task_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  initSqflite();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskListViewModel()),
        ChangeNotifierProvider(create: (_) => AddTaskViewModel()),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: TaskListScreen(),
      ),
    );
  }
}
