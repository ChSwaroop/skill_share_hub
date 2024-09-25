import 'package:flutter/material.dart';
import 'package:skill_share_hub/colors.dart';

class ToDo extends StatefulWidget {
  const ToDo({super.key});

  @override
  State<ToDo> createState() => _ToDoState();
}

class _ToDoState extends State<ToDo> {
  List<String> todos = [
    "Meeting with Jon Dep (4: 00 PM)",
    "Meeting with Jon Dep (4: 00 PM)",
    "Meeting with Jon Dep (4: 00 PM)",
  ];

  Future<void> _showAddSkillDialog() async {
    String newSkill = '';
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add todo"),
          content: TextField(
            onChanged: (value) {
              newSkill = value;
            },
            style: const TextStyle(color: Colors.black),
            cursorColor: ColorsUtil.primaryclr,
            decoration: const InputDecoration(hintText: "Enter a Todo"),
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
                if (newSkill.isNotEmpty) {
                  setState(() {
                    todos.add(newSkill);
                  });
                }
                Navigator.of(context).pop();
              },
            ),
          ],
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
      backgroundColor: ColorsUtil.bgclr,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 31.0, vertical: 50),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back_ios),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "TO DO",
                    style: theme.textTheme.headlineMedium,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "4 AUGUST 2024",
                    style: theme.textTheme.headlineSmall!.copyWith(
                      color: const Color(0xFFC5C5C5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 34),
              ...List.generate(todos.length, (index) {
                return Container(
                  height: 75,
                  width: width,
                  margin: const EdgeInsets.only(bottom: 15, left: 5, right: 5),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15.0, vertical: 25.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                            offset: const Offset(1, 1),
                            spreadRadius: 1,
                            blurRadius: 7,
                            color: Colors.grey.shade300),
                      ],
                      color: Colors.white),
                  child: Row(
                    children: [
                      InkWell(
                        child: Container(
                          height: 23,
                          width: 23,
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFABABAB),
                              ),
                              // color: ColorsUtil.primaryclr,
                              shape: BoxShape.circle),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Text(
                        todos[index],
                        style: theme.textTheme.bodyLarge!
                            .copyWith(color: Colors.black),
                      )
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      _showAddSkillDialog();
                      setState(() {});
                    },
                    child: Container(
                      height: 43,
                      width: 43,
                      decoration: const BoxDecoration(
                          color: ColorsUtil.primaryclr, shape: BoxShape.circle),
                      child: const Center(
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "DONE",
                        style: theme.textTheme.bodyLarge,
                      )),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
