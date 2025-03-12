import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

const String keyApplicationId = 'D6IdSaFT9cgT83kJqt5mWIbxA3hejqJC8ylKjNlz';
const String keyClientKey = 'ES8sXdtiujMnmVhebuTB7LOBzNXnDm2ncjrdGW7N';
const String keyParseServerUrl = 'https://parseapi.back4app.com';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Parse().initialize(keyApplicationId, keyParseServerUrl,
      clientKey: keyClientKey, debug: true);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TaskScreen(),
    );
  }
}

class TaskScreen extends StatefulWidget {
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final TextEditingController _taskController = TextEditingController();
  List<ParseObject> _tasks = [];

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    final queryBuilder = QueryBuilder<ParseObject>(ParseObject('Task'));
    final response = await queryBuilder.query();
    if (response.success && response.results != null) {
      setState(() {
        _tasks = response.results as List<ParseObject>;
      });
    }
  }

  Future<void> _saveTask() async {
    if (_taskController.text.isEmpty) return;
    final task = ParseObject('Task')..set('title', _taskController.text);
    final response = await task.save();
    if (response.success) {
      _fetchTasks();
    }
  }

  Future<void> _deleteTask(String objectId) async {
    final task = ParseObject('Task')..objectId = objectId;
    final response = await task.delete();
    if (response.success) {
      setState(() {
        _tasks.removeWhere((t) => t.objectId == objectId);
      });
    }
  }

  Future<void> _editTask(ParseObject task) async {
    TextEditingController editController =
        TextEditingController(text: task.get<String>('title'));
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar Tarefa'),
          content: TextField(
            controller: editController,
            decoration: InputDecoration(labelText: 'Título'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                task.set('title', editController.text);
                final response = await task.save();
                if (response.success) {
                  _fetchTasks();
                  Navigator.pop(context);
                }
              },
              child: Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lista de Tarefas')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _taskController,
              decoration: InputDecoration(labelText: 'Nova Tarefa'),
            ),
            SizedBox(height: 10),
            ElevatedButton(onPressed: _saveTask, child: Text('Salvar Tarefa')),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  var task = _tasks[index];
                  return Card(
                    elevation: 4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          task.get<String>('title') ?? '',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editTask(task),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteTask(task.objectId!),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
