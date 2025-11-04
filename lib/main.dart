import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// The main entry point of the application
void main() {
  // runApp is a Flutter function that takes a widget and makes it the root of the widget tree.
  runApp(const MyApp());
}

// The root widget of the application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // build method describes the part of the user interface represented by the widget.
  @override
  Widget build(BuildContext context) {
    // MaterialApp is a widget that introduces many standard features of a Material Design app,
    // such as routing, themes, and more.
    return MaterialApp(
      // ThemeData.dark() provides a pre-configured dark theme.
      theme: ThemeData.dark(),
      // The home property sets the default route of the app.
      home: HomePage(),
    );
  }
}

// The main screen of the app, a StatefulWidget because its content can change.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  // createState creates the mutable state for this widget at a given location in the tree.
  @override
  State<HomePage> createState() => _HomePageState();
}

// The state for the HomePage widget.
class _HomePageState extends State<HomePage> {
  // A list to hold the tasks.
  final List<Task> todoList = [];

  // build method describes the part of the user interface represented by the widget.
  @override
  Widget build(BuildContext context) {
    // Scaffold implements the basic material design visual layout structure.
    return Scaffold(
      // AppBar is the top app bar.
      appBar: AppBar(title: Center(child: Text('TODO'))),
      // The body of the scaffold.
      // It shows the TodoListView if the list is not empty, otherwise it shows the EmptyTodoList widget.
      body: todoList.isNotEmpty ? TodoListView(tasks: todoList) : EmptyTodoList(),
      // A floating action button for adding new tasks.
      floatingActionButton: Builder(
        builder: (context) {
          return FloatingActionButton(
            backgroundColor: Color(0xFF8687E7),
            onPressed: () {
              // Show the bottom sheet to add a new task when the button is pressed.
              _showAddTaskSheet(context);
            },
            shape: CircleBorder(),
            child: Icon(Icons.add),
          );
        },
      ),
      // The location of the floating action button.
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // A bottom navigation bar.
      bottomNavigationBar: Container(height: 100, color: Color(0xFF363636)),
    );
  }

  /// Shows the Add Task Bottom Sheet.
  void _showAddTaskSheet(BuildContext context) {
    // showModalBottomSheet is a built-in Flutter function that shows a bottom sheet.
    showModalBottomSheet(
      context: context,
      builder: (_) {
        // Returns the AddTaskSheet widget.
        return AddTaskSheet(
          onSave: (title, desc, dateTime) {
            // The onSave callback is called when the user saves a new task.
            _saveTask(title, desc, dateTime);
          },
        );
      },
    );
  }

  /// Saves a new task to the todoList.
  void _saveTask(String taskTitle, String? description, DateTime? selectedDateTime) {
    // Create a new Task object.
    final newTask = Task(title: taskTitle, description: description, timestamp: selectedDateTime);
    // Add the new task to the list and call setState to rebuild the widget and update the UI.
    setState(() {
      todoList.add(newTask);
    });

    // Show a snackbar to confirm that the task was added.
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Task added successfully')));
  }
}

// Data model for a to-do item.
class Task {
  String title;
  String? description;
  DateTime? timestamp;
  bool isCompleted;

  Task({required this.title, this.description, this.timestamp, this.isCompleted = false});
}

/// A widget that is shown when the to-do list is empty.
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

/// A StatefulWidget for the "Add Task" bottom sheet.
class AddTaskSheet extends StatefulWidget {
  // A callback function that is called when the user saves a new task.
  final Function(String, String?, DateTime?) onSave;

  const AddTaskSheet({super.key, required this.onSave});

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

/// The state for the AddTaskSheet widget.
class _AddTaskSheetState extends State<AddTaskSheet> {
  // Variables to hold the new task's data.
  String? taskTitle;
  String? description;
  DateTime? selectedDateTime;

  // A variable to hold an error message.
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    // A container for the bottom sheet content.
    return Container(
      padding: EdgeInsets.all(25),
      height: 340,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add Task', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          // A text field for the task title.
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
          // A text field for the task description.
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
          // Show an error message if there is one.
          if (_errorMessage != null) Text(_errorMessage!, style: TextStyle(color: Colors.red)),
          const SizedBox(height: 20),
          // A row with buttons for setting a reminder and saving the task.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // A button to show the date and time pickers.
              IconButton(
                onPressed: () {
                  // Show the date picker.
                  showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  ).then((pickedDate) {
                    if (pickedDate == null) return;
                    // Show the time picker after a date has been picked.
                    showTimePicker(context: context, initialTime: TimeOfDay.now()).then((
                      pickedTime,
                    ) {
                      if (pickedTime == null) return;
                      // Set the selected date and time.
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
                    // Show the selected date and time or a "Remind me" text.
                    if (selectedDateTime != null)
                      Text(DateFormat('h:mm a dd/MM/yyyy').format(selectedDateTime!))
                    else
                      Text('Remind me'),
                  ],
                ),
              ),
              // A button to save the task.
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

  /// Called when the save button is pressed.
  void _onSavePressed() {
    // Clear any previous error message.
    setState(() {
      _errorMessage = null;
    });

    // Validate the inputs.
    if (taskTitle == null) {
      // Show an error message if the title is empty.
      setState(() {
        _errorMessage = 'Task title cannot be empty';
      });
    } else {
      // Close the bottom sheet.
      Navigator.of(context).pop();

      // Call the onSave callback to save the task.
      widget.onSave(taskTitle!, description, selectedDateTime);
    }
  }
}

/// A StatefulWidget that displays the list of tasks.
class TodoListView extends StatefulWidget {
  const TodoListView({super.key, required this.tasks});

  final List<Task> tasks;

  @override
  State<TodoListView> createState() => _TodoListViewState();
}

/// The state for the TodoListView widget.
class _TodoListViewState extends State<TodoListView> {
  // Variables for filtering and searching.
  String _dateFilterValue = 'Today';
  String _completionFilterValue = 'Completed';

  // A list of completed or incomplete tasks based on the filter.
  List<Task> get _completedTasks => widget.tasks.where((task) {
    if (_completionFilterValue == 'Completed') {
      return task.isCompleted;
    } else {
      return !task.isCompleted;
    }
  }).toList();

  // A list of tasks filtered by date and search query.
  List<Task> _filteredTasks = [];
  String _query = '';

  // initState is called when the widget is inserted into the widget tree.
  @override
  void initState() {
    super.initState();
    // Apply the initial date filter.
    _applyDateFilter();
  }

  @override
  Widget build(BuildContext context) {
    // A scrollable view.
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // A text field for searching tasks.
            TextField(
              decoration: InputDecoration(
                hintText: 'Search for your task...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                // Update the query and apply the filters.
                _query = value.toLowerCase();
                _applyDateFilter();
              },
            ),
            const SizedBox(height: 20),
            // A dropdown for filtering tasks by date.
            DropdownButtonHideUnderline(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.21),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton(
                  value: _dateFilterValue,
                  isDense: true,
                  padding: EdgeInsets.symmetric(vertical: 4),
                  style: TextStyle(fontSize: 12),
                  // The items of the dropdown.
                  items: [
                    'Yesterday',
                    'Today',
                    'Tomorrow',
                    'All',
                  ].map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                  onChanged: (value) {
                    // Update the date filter and apply it.
                    _dateFilterValue = value!;
                    _applyDateFilter();
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            // A list view of the filtered tasks.
            ListView.separated(
              itemBuilder: (_, index) {
                return TaskItem(
                  task: _filteredTasks[index],
                  onMarkComplete: (bool value) {
                    // Mark a task as complete or incomplete and update the UI.
                    setState(() {
                      _filteredTasks[index].isCompleted = value;
                    });
                  },
                  onDeleteTaskPressed: (Task task) {
                    setState(() {
                      widget.tasks.remove(task);
                      _applyDateFilter();
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
            // A dropdown for filtering tasks by completion status.
            DropdownButtonHideUnderline(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.21),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton(
                  value: _completionFilterValue,
                  isDense: true,
                  padding: EdgeInsets.symmetric(vertical: 4),
                  style: TextStyle(fontSize: 12),
                  // The items of the dropdown.
                  items: [
                    'Completed',
                    'Incomplete',
                  ].map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                  onChanged: (value) {
                    // Update the completion filter.
                    setState(() {
                      _completionFilterValue = value!;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            // A list view of the completed or incomplete tasks.
            ListView.separated(
              itemBuilder: (_, index) {
                return TaskItem(
                  task: _completedTasks[index],
                  onMarkComplete: (bool value) {
                    // Mark a task as complete or incomplete and update the UI.
                    setState(() {
                      _completedTasks[index].isCompleted = value;
                    });
                  },
                  onDeleteTaskPressed: (Task task) {
                    setState(() {
                      widget.tasks.remove(task);
                      _applyDateFilter();
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

  /// Applies the date filter to the task list.
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

    // Apply the search filter after the date filter.
    setState(() {
      if (_query.isNotEmpty) {
        _filteredTasks = _applySearchFilter(_filteredTasks, _query);
      }
    });
  }

  /// Applies the search filter to the task list.
  List<Task> _applySearchFilter(List<Task> tasks, String query) {
    return tasks.where((task) {
      final title = task.title.toLowerCase();
      final description = task.description?.toLowerCase() ?? '';
      return title.contains(query) || description.contains(query);
    }).toList();
  }
}

// A widget that represents a single item in the to-do list.
class TaskItem extends StatelessWidget {
  const TaskItem({
    super.key,
    required this.task,
    required this.onMarkComplete,
    required this.onDeleteTaskPressed,
  });

  final Task task;
  final Function(Task task) onDeleteTaskPressed;

  // A callback function that is called when the user marks a task as complete or incomplete.
  final ValueChanged<bool> onMarkComplete;

  @override
  Widget build(BuildContext context) {
    // A ListTile is a single fixed-height row that typically contains some text as well as a leading or trailing icon.
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TaskDetailsPage(task: task, onDeleteTaskPressed: onDeleteTaskPressed),
          ),
        );
      },
      child: ListTile(
        dense: true,
        // A gesture detector for the radio button.
        leading: GestureDetector(
          child: Icon(task.isCompleted ? Icons.radio_button_checked : Icons.radio_button_unchecked),
          onTap: () {
            // Call the onMarkComplete callback when the radio button is tapped.
            onMarkComplete(!task.isCompleted);
          },
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        tileColor: Colors.white.withOpacity(0.21),
        title: Text(task.title, style: TextStyle(fontSize: 16)),
        // Show the timestamp if it exists.
        subtitle: task.timestamp != null
            ? Text(
                // Format the timestamp to a relative time string.
                DateFormat(_relativeTime(task.timestamp)).format(task.timestamp!),
                style: TextStyle(fontSize: 14, color: Color(0xFFAFAFAF)),
              )
            : null,
      ),
    );
  }
}

class TaskDetailsPage extends StatelessWidget {
  const TaskDetailsPage({super.key, required this.task, required this.onDeleteTaskPressed});

  final Task task;
  final Function(Task task) onDeleteTaskPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton.filled(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.close),
          style: ButtonStyle(
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
            ),
            backgroundColor: WidgetStateProperty.all<Color>(Color(0xFF1D1D1D)),
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  child: Icon(
                    task.isCompleted ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  ),
                  onTap: () {},
                ),
                const SizedBox(width: 21),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(task.title, style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 14),
                      Text(task.description ?? '', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.edit),
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                    ),
                    backgroundColor: WidgetStateProperty.all<Color>(Color(0xFF1D1D1D)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // reminder time
            Row(
              children: [
                Icon(Icons.alarm),
                const SizedBox(width: 8),
                Text('Task time:'),
                const SizedBox(width: 8),
                Spacer(),
                if (task.timestamp != null)
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    color: Colors.white.withValues(alpha: 0.21),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        DateFormat('h:mm a dd/MM/yyyy').format(task.timestamp!),
                        style: TextStyle(fontSize: 14, color: Color(0xFFAFAFAF)),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 30),
            TextButton.icon(
              onPressed: () {
                onDeleteTaskPressed(task);
                Navigator.of(context).pop();
              },
              label: Text('Delete Task'),
              icon: Icon(Icons.delete),
              style: ButtonStyle(foregroundColor: WidgetStateProperty.all<Color>(Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Returns a relative time string for the given timestamp.
String? _relativeTime(DateTime? timestamp) {
  if (timestamp == null) return null;
  final now = DateTime.now();
  if (timestamp.year == now.year && timestamp.month == now.month && timestamp.day == now.day) {
    // If the task is today, show the time.
    return 'h:mm a';
  } else if (timestamp.year == now.year &&
      timestamp.month == now.month &&
      timestamp.day == now.day - 1) {
    // If the task was yesterday, show "Yesterday" and the time.
    return "'Yesterday' h:mm a";
  } else if (timestamp.year == now.year &&
      timestamp.month == now.month &&
      timestamp.day == now.day + 1) {
    // If the task is tomorrow, show "Tomorrow" and the time.
    return "'Tomorrow' h:mm a";
  } else {
    // Otherwise, show the full date and time.
    return 'dd/MM/yyyy h:mm a';
  }
}
