import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/task_list_viewmodel.dart';
import '../widgets/empty_view.dart';
import 'task_detail_screen.dart';
import 'add_new_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskListViewModel>().loadTasks();
    });
  }

  final List<Color> _cardColors = [
    const Color(0xFFBFE3FF),
    const Color(0xFFF2C7CF),
    const Color(0xFFDCE6B5),
    const Color(0xFFE7C3D7),
  ];

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.grey[100],

    // ✅ AppBar chuẩn (không ảnh hưởng Navigator)
    appBar: AppBar(
      backgroundColor: Colors.blue[100],
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'Task List',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.add, color: Colors.red),
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddNewScreen()),
            );
            if (result == true) {
              Provider.of<TaskListViewModel>(context, listen: false).loadTasks();
            }
          },
        )
      ],
    ),

    body: Consumer<TaskListViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  viewModel.error!,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: viewModel.loadTasks,
                  child: const Text('Retry'),
                )
              ],
            ),
          );
        }

        if (viewModel.tasks.isEmpty) {
          return const EmptyView();
        }

        final tasks = viewModel.tasks;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            final cardColor = _cardColors[index % _cardColors.length];

            return Card(
              margin: const EdgeInsets.only(bottom: 14),
              color: cardColor,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TaskDetailScreen(id: task.id),
                    ),
                  );
                  if (result == 'deleted') {
                    viewModel.loadTasks();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: task.isCompleted ?? false,
                        onChanged: null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (task.description.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                task.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                            if (task.date != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                '📅 ${task.date}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ]
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ),

    // ✅ Bottom bar giữ nguyên Navigator
    bottomNavigationBar: BottomAppBar(
      height: 70,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {},
          ),
          FloatingActionButton(
            backgroundColor: Colors.blue,
            child: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddNewScreen()),
              );
              if (result == true) {
                Provider.of<TaskListViewModel>(context, listen: false)
                    .loadTasks();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
    ),
  );
}
}
