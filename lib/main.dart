import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(theme: ThemeData.dark(), home: HomePage());
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text('TODO'))),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/checklist.png'),
            Text('What do you want to do today?'),
            SizedBox(height: 10),
            Text('Tap + to add your tasks'),
          ],
        ),
      ),
      floatingActionButton: Builder(
        builder: (context) {
          return FloatingActionButton(
            onPressed: () {
              // Show bottom sheet Add Task
              _showAddTaskSheet(context);
            },
            shape: CircleBorder(),
            child: Icon(Icons.add),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(height: 100, color: Color(0xFF363636)),
    );
  }

  /// Show Add Task Bottom Sheet
  void _showAddTaskSheet(BuildContext context) {
    String? taskTitle;
    String? description;

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Container(
          padding: EdgeInsets.all(25),
          height: 340,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Task', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 14),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Title',
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                ),
                onChanged: (value) {
                  taskTitle = value;
                },
              ),
              const SizedBox(height: 8),
              TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Description',
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                ),
                onChanged: (value) {
                  description = value;
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(onPressed: () {}, icon: Icon(Icons.alarm)),
                  IconButton(
                    onPressed: () {
                      _saveTask(taskTitle, description);
                      Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.send),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _saveTask(String? taskTitle, String? description) {
    // TODO: Implement saving task logic
    print('Saving task: $taskTitle, Description: $description');
  }
}
