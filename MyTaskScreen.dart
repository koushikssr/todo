import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import '../DataBase.dart';

class MyTask extends StatefulWidget {
  String email;

  MyTask(this.email);
  @override
  State<MyTask> createState() => _MyTaskState();
}

class _MyTaskState extends State<MyTask> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  final DateFormat _formatter = DateFormat('dd-MM-yyyy');
  String email;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    email = widget.email;
  }
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
                    if (taskName.isNotEmpty || startDate != null || endDate != null || description.isNotEmpty) {
                      if (task != null) {
                        await _databaseHelper.updateTask({
                          'id': task['id'],
                          'name': taskName,
                          'startDate': startDate != null ? _formatter.format(startDate) : null,
                          'endDate': endDate != null ? _formatter.format(endDate) : null,
                          'description': description,
                          'userEmail': email,
                        });
                      } else {
                        await _databaseHelper.insertTask({
                          'name': taskName,
                          'startDate': startDate != null ? _formatter.format(startDate) : null,
                          'endDate': endDate != null ? _formatter.format(endDate) : null,
                          'description': description,
                          'userEmail': email,
                        });
                      }
                      _refreshTasks();
                    }
                    Navigator.pop(context);
                               }
              },
              child: Text(task != null ? 'Save' : 'Add'),
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
        title: Text('My Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(height: 16.0),
            GestureDetector(
              onTap: () => _showCreateTaskDialog(context),
              child: Container(
                width: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.blue,
                ),
                child: Center(
                  child: Container(
                    margin: EdgeInsets.all(10),
                    child: Text(
                      "Create Task",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _databaseHelper.retrieveTasks(email),
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
                            title: Text(task['name']),
                            subtitle: Text(task['description']),
                            leading: IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _showCreateTaskDialog(context, task: task),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                            IconButton(
                            icon: Icon(Icons.share),
                            onPressed: () async {
                              final List<Map<String, String>> emails = await getEmails();
                              if (emails.isEmpty) {
                                Fluttertoast.showToast(msg: "No email found!");

                                // Handle case where no emails are available
                                return;
                              }
                              showDialog(
                                context: context,
                                builder: (context) {
                                  String selectedEmail = emails.first['email'];
                                  return StatefulBuilder(
                                    builder: (context, setState) {
                                      return AlertDialog(
                                        title: Text('Share Task'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: emails.map((emailMap) {
                                            return RadioListTile(
                                              title: Text(emailMap['email']),
                                              value: emailMap['email'],
                                              groupValue: selectedEmail,
                                              onChanged: (value) {
                                                setState(() {
                                                  selectedEmail = value;
                                                });
                                              },
                                            );
                                          }).toList(),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () async {


                                              print(email);
                                              print(selectedEmail);
                                              await _databaseHelper.shareTask({
                                                'name': task['name'],
                                                'startDate': task['startDate'] != null ? task['startDate'] : null,
                                                'endDate': task['endDate'] != null ? task['endDate'] : null,
                                                'description': task['description'],
                                                'userEmail': selectedEmail,
                                              });

                                              String selectedPasword = emails.first['password'];

                                              final smtpServer = gmail(selectedEmail, "");

                                              final message = Message()
                                                ..from = Address(widget.email, selectedPasword)
                                                ..recipients.add(selectedEmail)
                                                ..subject = 'Task shared with you'
                                                ..text = 'Task details:\nName: ${task['name']}\nStart Date: ${task['startDate']}\nEnd Date: ${task['endDate']}\nDescription: ${task['description']}';
                                              final sendReport = await send(message, smtpServer);
                                              print('Message sent: ' + sendReport.toString());

                                              // await _databaseHelper.shareTask(task['id'], selectedEmail);
                                              Fluttertoast.showToast(msg: "Email send successfully!");

                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Share'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ),



                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () async {
                                    await _databaseHelper.deleteTask(task['id']);
                                    _refreshTasks();
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );

                }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future<List<Map<String, String>>> getEmails() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> result = await db.query('User');
    final List<Map<String, String>> allEmails = List<Map<String, String>>.from(result.map((user) => { 'email': user['email'].toString(), 'password': user['password'].toString() }));
    allEmails.removeWhere((element) => element['email'] == email); // Remove the current user's email
    return allEmails;
  }






}
