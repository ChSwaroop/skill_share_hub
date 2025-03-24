import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:skill_share_hub/colors.dart';
import 'package:skill_share_hub/providers/todo_provider.dart';

class ToDo extends StatefulWidget {
  const ToDo({super.key});

  @override
  State<ToDo> createState() => _ToDoState();
}

class _ToDoState extends State<ToDo> {
  @override
  void initState() {
    super.initState();
    // Fetch todos when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TodoProvider>(context, listen: false).fetchTodos();
    });
  }

  Future<void> _showAddSkillDialog() async {
    String newTask = '';
    String description = '';
    DateTime? dueDate;
    final _formKey = GlobalKey<FormState>();
    TextEditingController title = TextEditingController();
    TextEditingController description_controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);

        return StatefulBuilder(
          builder: (context, setDialogState) {
            // <--- Using StatefulBuilder
            return AlertDialog(
              title: const Text("Add Task"),
              content: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: title,
                      onChanged: (value) {
                        newTask = value;
                      },
                      validator: (value) => value == null || value.isEmpty
                          ? 'Task name is required'
                          : null,
                      style: const TextStyle(color: Colors.black),
                      cursorColor: ColorsUtil.primaryclr,
                      decoration: const InputDecoration(hintText: "Enter Task"),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: description_controller,
                      onChanged: (value) {
                        description = value;
                      },
                      validator: (value) => value == null || value.isEmpty
                          ? 'Description is required'
                          : null,
                      style: const TextStyle(color: Colors.black),
                      cursorColor: ColorsUtil.primaryclr,
                      decoration:
                          const InputDecoration(hintText: "Enter Description"),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setDialogState(() {
                            // <--- Using setDialogState to update dialog UI
                            dueDate = pickedDate;
                          });
                        }
                      },
                      child: Text(
                        "Pick Due Date",
                        style: theme.textTheme.bodyLarge!.copyWith(
                          color: ColorsUtil.textclr,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    (dueDate != null)
                        ? Text(
                            DateFormat('MMMM dd, yyyy – hh:mm a')
                                .format(dueDate!),
                            style: theme.textTheme.bodyMedium!
                                .copyWith(color: ColorsUtil.textclr),
                          )
                        : const SizedBox(),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text(
                    "Add",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate() && dueDate != null) {
                      setState(() {
                        // todos.add({'skill': newTask, 'description': description, 'dueDate': dueDate});
                        Provider.of<TodoProvider>(context, listen: false)
                            .addTodo(
                          title: title.text.trim(),
                          description: description_controller.text.trim(),
                          dueDate: dueDate,
                        );
                      });
                      Navigator.of(context).pop();
                    } else if (dueDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Due date is required")),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: Text(
          "TO DO",
          style: theme.textTheme.headlineSmall!.copyWith(
            color: ColorsUtil.primaryclr,
            fontSize: 25,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      backgroundColor: ColorsUtil.bgclr,
      body: Column(
        children: [
          // SizedBox(height: 10),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     Text(
          //       "4 AUGUST 2024",
          //       style: theme.textTheme.headlineSmall!.copyWith(
          //         color: const Color(0xFFC5C5C5),
          //       ),
          //     ),
          //   ],
          // ),
          Consumer<TodoProvider>(
            builder: (context, todoProvider, child) {
              if (todoProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (todoProvider.error != null) {
                return Center(
                  child: Text('Error: ${todoProvider.error}'),
                );
              }

              final todos = todoProvider.todos;

              if (todos.isEmpty) {
                return const Center(child: Text('No todos found'));
              }

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 31.0, vertical: 50),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // const SizedBox(height: 10),
                      ...List.generate(todos.length, (index) {
                        final todo = todos[index];

                        // Inside List.generate:
                        return Slidable(
                          key: ValueKey(
                              todo.id), // Ensure unique key for animation
                          endActionPane: ActionPane(
                            motion:
                                const DrawerMotion(), // You can use StretchMotion(), ScrollMotion(), etc.
                            children: [
                              SlidableAction(
                                onPressed: (context) {
                                  // Call delete function
                                  todoProvider.deleteTodo(todo.id!);
                                },
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                label: 'Delete',
                              ),
                            ],
                          ),
                          child: Container(
                            width: width,
                            margin: const EdgeInsets.only(
                                bottom: 15, left: 5, right: 5),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5.0, vertical: 5.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  offset: const Offset(1, 1),
                                  spreadRadius: 1,
                                  blurRadius: 7,
                                  color: Colors.grey.shade300,
                                ),
                              ],
                              color: Colors.white,
                            ),
                            child: ListTile(
                              title: Text(todo.title ?? 'No title'),
                              subtitle:
                                  Text(todo.description ?? 'No description'),
                              trailing: Checkbox(
                                activeColor: ColorsUtil.primaryclr,
                                value: todo.completed ?? false,
                                onChanged: (value) {
                                  if (value == true) {
                                    todoProvider.completeTodo(todo.id!);
                                  } else {
                                    todoProvider.updateTodo(
                                        id: todo.id!, completed: false);
                                  }
                                },
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [],
                      ),
                      const SizedBox(height: 20),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     ElevatedButton(
                      //         onPressed: () {
                      //           Navigator.pop(context);
                      //         },
                      //         child: Text(
                      //           "DONE",
                      //           style: theme.textTheme.bodyLarge,
                      //         )),
                      //   ],
                      // )
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorsUtil.primaryclr,
        onPressed: () {
          _showAddSkillDialog();
          setState(() {});
        },
        child: const Center(
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
