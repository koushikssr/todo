import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import '../DataBase.dart';

class TaskReceivedScreen extends StatefulWidget {
  String email;

  TaskReceivedScreen(this.email);

  @override
  State<TaskReceivedScreen> createState() => _TaskReceivedScreenState();
}

class _TaskReceivedScreenState extends State<TaskReceivedScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  final DateFormat _formatter = DateFormat('dd-MM-yyyy');
  String email;

  void _showCreateTaskDialog(BuildContext parentContext, {Map<String, dynamic> task}) {
    String taskName = task != null ? task['name'] : '';
    DateTime startDate = task != null && task['startDate'] != null ? _formatter.parse(task['startDate']) : null;
    DateTime endDate = task != null && task['endDate'] != null ? _formatter.parse(task['endDate']) : null;
    String description = task != null ? task['description'] : '';

    TextEditingController startDateController = TextEditingController(text: startDate != null ? _formatter.format(startDate) : '');
    TextEditingController endDateController = TextEditingController(text: endDate != null ? _formatter.format(endDate) : '');

    GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    showDialog(
      context: parentContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(task != null ? 'Edit Task' : 'Create Task'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Task Name'),
                    controller: TextEditingController(text: taskName),
                    onChanged: (value) => taskName = value,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter a task name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 8.0),
                  TextFormField(
                    enabled: false,
                    decoration: InputDecoration(labelText: 'Start Date'),
                    controller: startDateController,
                    onTap: () async {
                      DateTime pickedStartDate = await showDatePicker(
                        context: context,
                        initialDate: startDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedStartDate != null && pickedStartDate != startDate) {
                        setState(() {
                          startDate = pickedStartDate;
                          startDateController.text = _formatter.format(startDate);
                        });
                      }
                    },
                    validator: (value) {
                      if (startDate == null) {
                        return 'Please select a start date';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 8.0),
                  TextFormField(
                    enabled: false,

                    decoration: InputDecoration(labelText: 'End Date'),
                    controller: endDateController,
                    onTap: () async {
                      DateTime pickedEndDate = await showDatePicker(
                        context: context,
                        initialDate: endDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedEndDate != null && pickedEndDate != endDate) {
                        setState(() {
                          endDate = pickedEndDate;
                          endDateController.text = _formatter.format(endDate);
                        });
                      }
                    },
                    validator: (value) {
                      if (endDate == null) {
                        return 'Please select an end date';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 8.0),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Description'),
                    controller: TextEditingController(text: description),
                    maxLines: null, // Allow multiple lines
                    keyboardType: TextInputType.multiline,
                    onChanged: (value) => description = value,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter a Description';
                      }
                      return null;

                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState.validate()) {
                  // Update task details in the database
                  final updatedTask = {
                    'id': task['id'],
                    'name': taskName,
                    'startDate': _formatter.format(startDate),
                    'endDate': _formatter.format(endDate),
                    'description': description,
                    'userEmail': widget.email,
                  };
                  await _databaseHelper.shareUpdateTask(updatedTask);

                  // Update the shared task details
                  await _databaseHelper.updateTask({
                    'id': task['id'],
                    'name': taskName,
                    'startDate': startDate != null ? _formatter.format(startDate) : null,
                    'endDate': endDate != null ? _formatter.format(endDate) : null,
                    'description': description,
                    'userEmail': email,
                  });

                  Navigator.pop(context);
                  _refreshTasks();
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
  void _refreshTasks() {
    setState(() {});
    email = widget.email;

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Received Tasks'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _databaseHelper.retrieveReceivedTasks(widget.email),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final tasks = snapshot.data ?? [];
            return ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Card(
                  child: ListTile(
                    title: Text(task['name'] ?? 'No Name'),
                    subtitle: Text(task['description'] ?? 'No Description'),
                    onTap: () {
                      // Handle tap on task
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _showCreateTaskDialog(context, task: task),

                        ),
                        // IconButton(
                        //   icon: Icon(Icons.share),
                        //   onPressed: () {
                        //     // Implement share functionality
                        //   },
                        // ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}