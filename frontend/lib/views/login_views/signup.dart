import 'package:flutter/material.dart';
import 'package:skill_share_hub/colors.dart';
import 'package:skill_share_hub/views/home_views/home.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  int pageNumber = 0;
  List<String> skills = [
    'Web Development',
    'UI / UX',
    'Html / CSS',
    'JavaScript',
    'React Native'
  ];
  List<String> certifications = [
    'Web Development',
    'UI / UX',
    'Html / CSS',
    'JavaScript',
    'React Native'
  ];

  // Function to show dialog and get input from user
  Future<void> _showAddSkillDialog(int flag) async {
    String newSkill = '';
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text((flag == 0) ? "Add Skill" : "Add certification"),
          content: TextField(
            onChanged: (value) {
              newSkill = value;
            },
            style: const TextStyle(color: Colors.black),
            cursorColor: ColorsUtil.primaryclr,
            decoration: InputDecoration(
                hintText:
                    (flag == 0) ? "Enter a skill" : "Enter a certification"),
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
                    if (flag == 0) {
                      skills.add(newSkill);
                    } else {
                      certifications.add(newSkill);
                    }
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
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    List<Widget> screens = [
      Details_one(width, theme),
      Details_two(theme),
      Details_three(width, theme),
      Details_four(theme, width, context)
    ];

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 40.0,
          vertical: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (pageNumber > 0) {
                        setState(() {
                          pageNumber--;
                        });
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(Icons.arrow_back_ios),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              Container(
                height: 10,
                width: width / 2,
                decoration: BoxDecoration(
                  color: ColorsUtil.barclr,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 10,
                      width: (pageNumber + 1) * ((width / 2) / 4),
                      decoration: BoxDecoration(
                        color: ColorsUtil.primaryclr,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 37),
              Text(
                "SignUp",
                style: theme.textTheme.headlineMedium,
              ),
              Text(
                "PERSONAL INFO",
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 55),
              screens[pageNumber]
              // Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Column Details_four(ThemeData theme, double width, BuildContext context) {
    return Column(
      children: [
        // Stack(
        //   alignment: Alignment(-0.8, -1.1),
        //   children: [
        //     Container(
        //       height: 30,
        //       width: 100,
        //       decoration: BoxDecoration(color: Colors.white),
        //       child: Container(
        //         height: 30,
        //         width: 50,
        //         decoration: BoxDecoration(
        //           color: Colors.white,
        //         ),
        //         child: Text("skills"),
        //       ),
        //     ),
        //     Container(
        //       height: height / 5,
        //       width: width,
        //       decoration: BoxDecoration(
        //           borderRadius: BorderRadius.circular(25),
        //           border: Border.all(color: ColorsUtil.borderclr)),
        //     ),
        //   ],
        // ),
        // SizedBox(height: 20),
        Row(
          children: [
            Text(
              "skills",
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
        Container(
          // height: height / 4,
          width: width,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: ColorsUtil.borderclr)),
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Wrap(
                spacing: 8.0, // gap between adjacent chips
                runSpacing: 4.0, // gap between lines
                children: skills.map((skill) {
                  return Chip(
                    side: const BorderSide(color: Colors.transparent),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    label: Text(skill),
                    deleteIcon: Container(
                      height: 15,
                      width: 15,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.5)),
                      child: const Icon(
                        Icons.close,
                        size: 10,
                        color: ColorsUtil.btntxtclr,
                      ),
                    ),
                    onDeleted: () {
                      setState(() {
                        skills.remove(skill);
                      });
                    },
                    backgroundColor: ColorsUtil.cardclr,
                    labelStyle: const TextStyle(color: Colors.white),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () async {
                      await _showAddSkillDialog(0);
                    },
                    child: Text(
                      "+ Add skill",
                      style: theme.textTheme.bodyMedium!
                          .copyWith(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Text(
              "certifications",
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
        Container(
          // height: height / 4,
          width: width,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: ColorsUtil.borderclr)),
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Wrap(
                spacing: 8.0, // gap between adjacent chips
                runSpacing: 4.0, // gap between lines
                children: certifications.map((skill) {
                  return Chip(
                    side: const BorderSide(color: Colors.transparent),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    label: Text(skill),
                    deleteIcon: Container(
                      height: 15,
                      width: 15,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.5)),
                      child: const Icon(
                        Icons.close,
                        size: 10,
                        color: ColorsUtil.btntxtclr,
                      ),
                    ),
                    onDeleted: () {
                      setState(() {
                        certifications.remove(skill);
                      });
                    },
                    backgroundColor: ColorsUtil.cardclr,
                    labelStyle: const TextStyle(color: Colors.white),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () async {
                      await _showAddSkillDialog(1);
                    },
                    child: Text(
                      "+ Add certification",
                      style: theme.textTheme.bodyMedium!
                          .copyWith(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        TextFormField(
          style: theme.textTheme.bodyLarge!.copyWith(color: Colors.black),
          cursorColor: ColorsUtil.primaryclr,
          decoration: const InputDecoration(
            label: Text("Portifolio website"),
          ),
        ),
        const SizedBox(height: 35),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => const HomeScreen()));
          },
          child: Text(
            "Next",
            style: theme.textTheme.bodyMedium!
                .copyWith(color: ColorsUtil.btntxtclr),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Column Details_three(double width, ThemeData theme) {
    return Column(
      children: [
        TextFormField(style: theme.textTheme.bodyLarge!.copyWith(color: Colors.black),
          cursorColor: ColorsUtil.primaryclr,
          decoration: const InputDecoration(
            label: Text("Occupation"),
          ),
        ),
        const SizedBox(height: 20),
        TextFormField(
          style: theme.textTheme.bodyLarge!.copyWith(color: Colors.black),
          cursorColor: ColorsUtil.primaryclr,
          decoration: const InputDecoration(
            label: Text("Company"),
          ),
        ),
        const SizedBox(height: 20),
        TextFormField(
          style: theme.textTheme.bodyLarge!.copyWith(color: Colors.black),
          cursorColor: ColorsUtil.primaryclr,
          decoration: const InputDecoration(
            label: Text("Education"),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              width: width / 4,
              child: TextFormField(
                decoration: const InputDecoration(
                  hintText: "Start year",
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: width / 4,
              child: TextFormField(
                style: theme.textTheme.bodyLarge!.copyWith(color: Colors.black),
          cursorColor: ColorsUtil.primaryclr,
                decoration: const InputDecoration(
                  label: Text("End year"),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        TextFormField(
          style: theme.textTheme.bodyLarge!.copyWith(color: Colors.black),
          cursorColor: ColorsUtil.primaryclr,
          decoration: const InputDecoration(
            label: Text("Work experience"),
          ),
        ),
        const SizedBox(height: 20),
        TextFormField(
          style: theme.textTheme.bodyLarge!.copyWith(color: Colors.black),
          cursorColor: ColorsUtil.primaryclr,
          decoration: const InputDecoration(
            label: Text("Internship experience"),
          ),
        ),
        const SizedBox(height: 50),
        ElevatedButton(
          onPressed: () {
            setState(() {
              pageNumber++;
            });
          },
          child: Text(
            "Next",
            style: theme.textTheme.bodyMedium!
                .copyWith(color: ColorsUtil.btntxtclr),
          ),
        ),
      ],
    );
  }

  Column Details_two(ThemeData theme) {
    return Column(
      children: [
        TextFormField(
          style: theme.textTheme.bodyLarge!.copyWith(color: Colors.black),
          cursorColor: ColorsUtil.primaryclr,
          decoration: const InputDecoration(
            label: Text("Email"),
          ),
        ),
        const SizedBox(height: 20),
        TextFormField(
          style: theme.textTheme.bodyLarge!.copyWith(color: Colors.black),
          cursorColor: ColorsUtil.primaryclr,
          decoration: const InputDecoration(
            label: Text("Phone Number"),
          ),
        ),
        const SizedBox(height: 20),
        TextFormField(
          style: theme.textTheme.bodyLarge!.copyWith(color: Colors.black),
          cursorColor: ColorsUtil.primaryclr,
          decoration: const InputDecoration(
            label: Text("New Password"),
          ),
        ),
        const SizedBox(height: 20),
        TextFormField(
          style: theme.textTheme.bodyLarge!.copyWith(color: Colors.black),
          cursorColor: ColorsUtil.primaryclr,
          decoration: const InputDecoration(
            label: Text("Confirm password"),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Already have an account? ",
              style: theme.textTheme.bodyMedium,
            ),
            Text(
              "Login",
              style: theme.textTheme.bodyMedium!
                  .copyWith(color: ColorsUtil.primaryclr),
            )
          ],
        ),
        const SizedBox(height: 50),
        ElevatedButton(
          onPressed: () {
            setState(() {
              pageNumber++;
            });
          },
          child: Text(
            "Next",
            style: theme.textTheme.bodyMedium!
                .copyWith(color: ColorsUtil.btntxtclr),
          ),
        ),
      ],
    );
  }

  Column Details_one(double width, ThemeData theme) {
    return Column(
      children: [
        TextFormField(
          style: theme.textTheme.bodyLarge!.copyWith(color: Colors.black),
          cursorColor: ColorsUtil.primaryclr,
          decoration: const InputDecoration(
            label: Text("First name"),
          ),
        ),
        const SizedBox(height: 30),
        TextFormField(
          style: theme.textTheme.bodyLarge!.copyWith(color: Colors.black),
          cursorColor: ColorsUtil.primaryclr,
          decoration: const InputDecoration(
            label: Text("Last Name"),
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: width / 4,
                child: TextFormField(
                  style: theme.textTheme.bodyLarge!.copyWith(color: Colors.black),
          cursorColor: ColorsUtil.primaryclr,
                  decoration: const InputDecoration(
                    label: Text("DD"),
                  ),
                ),
              ),
              SizedBox(
                width: width / 4,
                child: TextFormField(
                  style:
                      theme.textTheme.bodyLarge!.copyWith(color: Colors.black),
                  cursorColor: ColorsUtil.primaryclr,
                  decoration: const InputDecoration(label: Text("MM")),
                ),
              ),
              SizedBox(
                width: width / 4,
                child: TextFormField(
                  style: theme.textTheme.bodyLarge!.copyWith(color: Colors.black),
          cursorColor: ColorsUtil.primaryclr,
                  decoration: const InputDecoration(label: Text("YYYY")),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 50,
              width: 100,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  color: ColorsUtil.primaryclr),
              child: Center(
                child: Text(
                  "Male",
                  style: theme.textTheme.bodyMedium!
                      .copyWith(color: ColorsUtil.btntxtclr),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              height: 50,
              width: 100,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  // color: ColorsUtil.tra
                  border: Border.all(color: ColorsUtil.borderclr)),
              child: Center(
                child: Text("Female", style: theme.textTheme.bodyMedium),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Already have an account? ",
              style: theme.textTheme.bodyMedium,
            ),
            Text(
              "Login",
              style: theme.textTheme.bodyMedium!
                  .copyWith(color: ColorsUtil.primaryclr),
            )
          ],
        ),
        // Spacer(),
        const SizedBox(height: 50),
        ElevatedButton(
          onPressed: () {
            setState(() {
              pageNumber++;
            });
          },
          child: Text(
            "Next",
            style: theme.textTheme.bodyMedium!
                .copyWith(color: ColorsUtil.btntxtclr),
          ),
        ),
      ],
    );
  }
}
