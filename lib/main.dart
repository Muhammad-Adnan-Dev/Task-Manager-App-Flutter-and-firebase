import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart'; // Needed to check if running on Web

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- INITIALIZATION LOGIC ---
  if (kIsWeb) {
    // IF RUNNING ON CHROME (WEB) -> Use the keys you provided
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyC8KvslOKoOKY1tHQDLNLNQitOWvzJ8bvw",
        appId: "1:440427324855:web:19081d43c3714871e43432",
        messagingSenderId: "440427324855",
        projectId: "task-manager-app-using-flutter",
        storageBucket: "task-manager-app-using-flutter.firebasestorage.app",
      ),
    );
  } else {
    // IF RUNNING ON ANDROID/EMULATOR -> Use the google-services.json file
    await Firebase.initializeApp();
  }

  runApp(const MaterialApp(home: TaskListScreen()));
}

// --- SCREEN 1: THE HOME PAGE (LIST) ---
class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Task Manager Assignment")),

      // StreamBuilder listens to the database live
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('tasks').snapshots(),
        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // 2. Error State
          if (snapshot.hasError) return const Center(child: Text("Error loading tasks"));

          // 3. Get Data
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No Tasks Added Yet"));
          }

          var tasks = snapshot.data!.docs;

          // 4. Build List
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              var task = tasks[index];
              var data = task.data() as Map<String, dynamic>;
              String id = task.id;

              bool isDone = data['isCompleted'] ?? false;

              return Card(
                color: isDone ? Colors.green[50] : Colors.white,
                child: ListTile(
                  title: Text(data['title'] ?? "No Title",
                      style: TextStyle(decoration: isDone ? TextDecoration.lineThrough : null)),
                  subtitle: Text("${data['desc'] ?? ""}\nDue: ${data['date'] ?? "No Date"}"),
                  isThreeLine: true,

                  // CHECKBOX (Mark as Done)
                  leading: Checkbox(
                    value: isDone,
                    onChanged: (val) {
                      FirebaseFirestore.instance.collection('tasks').doc(id).update({'isCompleted': val});
                    },
                  ),

                  // EDIT & DELETE BUTTONS
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (_) => AddEditTaskScreen(docId: id, existingData: data)
                          ));
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          FirebaseFirestore.instance.collection('tasks').doc(id).delete();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),

      // ADD BUTTON
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditTaskScreen()));
        },
      ),
    );
  }
}

// --- SCREEN 2: ADD / EDIT PAGE ---
class AddEditTaskScreen extends StatefulWidget {
  final String? docId;
  final Map<String, dynamic>? existingData;

  const AddEditTaskScreen({super.key, this.docId, this.existingData});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // If editing, pre-fill the boxes
    if (widget.existingData != null) {
      _titleController.text = widget.existingData!['title'];
      _descController.text = widget.existingData!['desc'];
      _dateController.text = widget.existingData!['date'];
    }
  }

  void saveTask() {
    if (_titleController.text.isEmpty) return;

    var data = {
      'title': _titleController.text,
      'desc': _descController.text,
      'date': _dateController.text.isEmpty
          ? DateFormat('yyyy-MM-dd').format(DateTime.now())
          : _dateController.text,
      'isCompleted': widget.existingData?['isCompleted'] ?? false,
    };

    if (widget.docId == null) {
      // ADD NEW
      FirebaseFirestore.instance.collection('tasks').add(data);
    } else {
      // UPDATE EXISTING
      FirebaseFirestore.instance.collection('tasks').doc(widget.docId).update(data);
    }
    Navigator.pop(context); // Go back home
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.docId == null ? "Add Task" : "Edit Task")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: "Title")),
            TextField(controller: _descController, decoration: const InputDecoration(labelText: "Description")),
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(labelText: "Due Date (YYYY-MM-DD)"),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100)
                );
                if (picked != null) {
                  _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
                }
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: saveTask, child: const Text("Save Task"))
          ],
        ),
      ),
    );
  }
}