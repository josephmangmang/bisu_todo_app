import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Task> todoList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text('TODO'))),
      body: todoList.isNotEmpty ? TodoListView(tasks: todoList) : EmptyTodoList(),
      floatingActionButton: Builder(
        builder: (context) {
          return FloatingActionButton(
            backgroundColor: Color(0xFF8687E7),
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
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return AddTaskSheet(
          onSave: (title, desc, dateTime) {
            _saveTask(title, desc, dateTime);
          },
        );
      },
    );
  }

  void _saveTask(String taskTitle, String? description, DateTime? selectedDateTime) {
    // finally create new task and add to the todo list
    final newTask = Task(title: taskTitle, description: description, timestamp: selectedDateTime);
    // add task to the list and reload widget to update the UI
    setState(() {
      todoList.add(newTask);
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Task added successfully')));
  }
}

class Task {
  String title;
  String? description;
  DateTime? timestamp;
  bool isCompleted;

  Task({required this.title, this.description, this.timestamp, this.isCompleted = false});
}

class EmptyTodoList extends StatelessWidget {
  const EmptyTodoList({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
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
    );
  }
}

class AddTaskSheet extends StatefulWidget {
  final Function(String, String?, DateTime?) onSave;

  const AddTaskSheet({super.key, required this.onSave});

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  String? taskTitle;
  String? description;
  DateTime? selectedDateTime;

  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
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
          if (_errorMessage != null) Text(_errorMessage!, style: TextStyle(color: Colors.red)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  ).then((pickedDate) {
                    if (pickedDate == null) return;
                    showTimePicker(context: context, initialTime: TimeOfDay.now()).then((
                      pickedTime,
                    ) {
                      if (pickedTime == null) return;
                      setState(() {
                        selectedDateTime = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                      });
                    });
                  });
                },
                icon: Row(
                  children: [
                    Icon(Icons.alarm),
                    const SizedBox(width: 8),
                    if (selectedDateTime != null)
                      Text(DateFormat('h:mm a dd/MM/yyyy').format(selectedDateTime!))
                    else
                      Text('Remind me'),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  _onSavePressed();
                },
                icon: Icon(Icons.send),
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onSavePressed() {
    // empty the error message
    setState(() {
      _errorMessage = null;
    });

    // Validate inputs
    if (taskTitle == null) {
      setState(() {
        _errorMessage = 'Task title cannot be empty';
      });
    } else {
      // close bottom sheet
      Navigator.of(context).pop();

      // call onSave callback to save the task
      widget.onSave(taskTitle!, description, selectedDateTime);
    }
  }
}

class TodoListView extends StatefulWidget {
  const TodoListView({super.key, required this.tasks});

  final List<Task> tasks;

  @override
  State<TodoListView> createState() => _TodoListViewState();
}

class _TodoListViewState extends State<TodoListView> {
  String _dateFilterValue = 'Today';
  String _completionFilterValue = 'Completed';

  // create a task list for completion filtered tasks
  List<Task> get _completedTasks => widget.tasks.where((task) {
    if (_completionFilterValue == 'Completed') {
      return task.isCompleted;
    } else {
      return !task.isCompleted;
    }
  }).toList();

  List<Task> _filteredTasks = [];
  String _query = '';

  @override
  void initState() {
    super.initState();
    _applyDateFilter();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search for your task...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                _query = value.toLowerCase();
                _applyDateFilter();
              },
            ),
            const SizedBox(height: 20),
            DropdownButtonHideUnderline(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.21),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton(
                  value: _dateFilterValue,
                  isDense: true,
                  padding: EdgeInsets.symmetric(vertical: 4),
                  style: TextStyle(fontSize: 12),
                  // convert the list of strings to dropdown menu items, by mapping each string to a DropdownMenuItem
                  items: [
                    'Yesterday',
                    'Today',
                    'Tomorrow',
                    'All',
                  ].map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                  onChanged: (value) {
                    _dateFilterValue = value!;
                    _applyDateFilter();
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            ListView.separated(
              itemBuilder: (_, index) {
                return TaskItem(
                  task: _filteredTasks[index],
                  onMarkComplete: (bool value) {
                    setState(() {
                      _filteredTasks[index].isCompleted = value;
                    });
                  },
                );
              },
              itemCount: _filteredTasks.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(height: 16);
              },
            ),

            const SizedBox(height: 20),
            DropdownButtonHideUnderline(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.21),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton(
                  value: _completionFilterValue,
                  isDense: true,
                  padding: EdgeInsets.symmetric(vertical: 4),
                  style: TextStyle(fontSize: 12),
                  // convert the list of strings to dropdown menu items, by mapping each string to a DropdownMenuItem
                  items: [
                    'Completed',
                    'Incomplete',
                  ].map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                  onChanged: (value) {
                    setState(() {
                      _completionFilterValue = value!;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            ListView.separated(
              itemBuilder: (_, index) {
                return TaskItem(
                  task: _completedTasks[index],
                  onMarkComplete: (bool value) {
                    setState(() {
                      _completedTasks[index].isCompleted = value;
                    });
                  },
                );
              },
              itemCount: _completedTasks.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(height: 16);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _applyDateFilter() {
    final now = DateTime.now();

    if (_dateFilterValue == 'Today') {
      _filteredTasks = widget.tasks.where((task) {
        final taskDate = task.timestamp;
        return taskDate != null &&
            taskDate.year == now.year &&
            taskDate.month == now.month &&
            taskDate.day == now.day;
      }).toList();
    } else if (_dateFilterValue == 'Yesterday') {
      _filteredTasks = widget.tasks.where((task) {
        final taskDate = task.timestamp;
        return taskDate != null &&
            taskDate.year == now.year &&
            taskDate.month == now.month &&
            taskDate.day == now.day - 1;
      }).toList();
    } else if (_dateFilterValue == 'Tomorrow') {
      _filteredTasks = widget.tasks.where((task) {
        final taskDate = task.timestamp;
        return taskDate != null &&
            taskDate.year == now.year &&
            taskDate.month == now.month &&
            taskDate.day == now.day + 1;
      }).toList();
    } else {
      _filteredTasks = widget.tasks;
    }

    setState(() {
      // apply search query filter
      if (_query.isNotEmpty) {
        _filteredTasks = _applySearchFilter(_filteredTasks, _query);
      }
    });
  }

  /// Apply search filter by using contains
  List<Task> _applySearchFilter(List<Task> tasks, String query) {
    return tasks.where((task) {
      final title = task.title.toLowerCase();
      final description = task.description?.toLowerCase() ?? '';
      return title.contains(query) || description.contains(query);
    }).toList();
  }
}

class TaskItem extends StatelessWidget {
  const TaskItem({super.key, required this.task, required this.onMarkComplete});

  final Task task;
  final ValueChanged<bool> onMarkComplete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: GestureDetector(
        child: Icon(task.isCompleted ? Icons.radio_button_checked : Icons.radio_button_unchecked),
        onTap: () {
          onMarkComplete(!task.isCompleted);
        },
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      tileColor: Colors.white.withValues(alpha: 0.21),
      title: Text(task.title, style: TextStyle(fontSize: 16)),
      subtitle: task.timestamp != null
          ? Text(
              DateFormat(_relativeTime(task.timestamp)).format(task.timestamp!),
              style: TextStyle(fontSize: 14, color: Color(0xFFAFAFAF)),
            )
          : null,
    );
  }

  String? _relativeTime(DateTime? timestamp) {
    if (timestamp == null) return null;
    final now = DateTime.now();
    if (timestamp.year == now.year && timestamp.month == now.month && timestamp.day == now.day) {
      return 'h:mm a';
    } else if (timestamp.year == now.year &&
        timestamp.month == now.month &&
        timestamp.day == now.day - 1) {
      return "'Yesterday' h:mm a";
    } else if (timestamp.year == now.year &&
        timestamp.month == now.month &&
        timestamp.day == now.day + 1) {
      return "'Tomorrow' h:mm a";
    } else {
      return 'dd/MM/yyyy h:mm a';
    }
  }
}
