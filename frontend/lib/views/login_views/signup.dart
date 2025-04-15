import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:skill_share_hub/colors.dart';
import 'package:skill_share_hub/providers/user_provider.dart';
import 'package:skill_share_hub/repo/auth.dart';
import 'package:skill_share_hub/views/home_views/home.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  int pageNumber = 0;
  bool isLoading = false;
  // List<String> skills = [
  //   'Web Development',
  //   'UI / UX',
  //   'Html / CSS',
  //   'JavaScript',
  //   'React Native'
  // ];
  // List<String> certifications = [
  //   'Web Development',
  //   'UI / UX',
  //   'Html / CSS',
  //   'JavaScript',
  //   'React Native'
  // ];
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final userNameController = TextEditingController();
  final dayController = TextEditingController();
  final monthController = TextEditingController();
  final yearController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();
  final TextEditingController _startYearController = TextEditingController();
  final TextEditingController _endYearController = TextEditingController();
  final TextEditingController _workExpController = TextEditingController();
  final TextEditingController _internshipExpController =
      TextEditingController();
  final TextEditingController _portfolioController = TextEditingController();
  List<String> skills = [];
  List<String> certifications = [];
  final apiRepo = AuthRepo();

  Future<void> _showAddItemDialog(int type) async {
    TextEditingController controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(type == 0 ? "Add Skill" : "Add Certification"),
        content: TextField(
          controller: controller,
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(color: Colors.black),
          cursorColor: ColorsUtil.primaryclr,
          decoration: InputDecoration(
            label: Text(type == 0 ? "Skill" : "Certification"),
            errorMaxLines: 1,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(color: ColorsUtil.textclr),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                if (controller.text.isNotEmpty) {
                  type == 0
                      ? skills.add(controller.text)
                      : certifications.add(controller.text);
                }
              });
              Navigator.pop(context);
            },
            child: const Text(
              "Add",
              style: TextStyle(color: ColorsUtil.primaryclr),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _occupationController.dispose();
    _companyController.dispose();
    _educationController.dispose();
    _startYearController.dispose();
    _endYearController.dispose();
    _workExpController.dispose();
    _internshipExpController.dispose();
    _portfolioController.dispose();
    super.dispose();
  }

  // Gender selection state
  bool isMale = true;
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
      body: Form(
        key: _formKey,
        child: Padding(
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
      ),
    );
  }

  Column Details_four(ThemeData theme, double width, BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text("Skills", style: theme.textTheme.bodyMedium),
          ],
        ),
        Container(
          width: width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: ColorsUtil.borderclr),
          ),
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: skills
                    .map((skill) => Chip(
                          label: Text(skill),
                          onDeleted: () => setState(() => skills.remove(skill)),
                          backgroundColor: ColorsUtil.cardclr,
                          labelStyle: const TextStyle(color: Colors.white),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _showAddItemDialog(0),
                  child: Text("+ Add skill",
                      style: theme.textTheme.bodyMedium!
                          .copyWith(color: Colors.black)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Text("Certifications", style: theme.textTheme.bodyMedium),
          ],
        ),
        Container(
          width: width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: ColorsUtil.borderclr),
          ),
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: certifications
                    .map((cert) => Chip(
                          label: Text(cert),
                          onDeleted: () =>
                              setState(() => certifications.remove(cert)),
                          backgroundColor: ColorsUtil.cardclr,
                          labelStyle: const TextStyle(color: Colors.white),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _showAddItemDialog(1),
                  child: Text("+ Add certification",
                      style: theme.textTheme.bodyMedium!
                          .copyWith(color: Colors.black)),
                ),
              ),
            ],
          ),
        ),
        // const SizedBox(height: 20),
        // TextFormField(
        //   controller: _portfolioController,
        //   style: theme.textTheme.bodyLarge!.copyWith(color: Colors.black),
        //   cursorColor: ColorsUtil.primaryclr,
        //   decoration: const InputDecoration(labelText: "Portfolio website"),
        //   // validator: (value) => value == null || value.isEmpty
        //   //     ? 'Portfolio website is required'
        //   //     : null,
        // ),
        const SizedBox(height: 35),
        ElevatedButton(
          onPressed: isLoading
              ? null
              : () async {
                  setState(() {
                    isLoading = true;
                  });
                  if (_formKey.currentState!.validate()) {
                    try {
                      final response = await apiRepo.registerUser(
                        firstName: firstNameController.text.trim(),
                        lastName: lastNameController.text.trim(),
                        userName: userNameController.text.trim(),
                        dateOfBirth: DateTime(
                                int.parse(yearController.text.trim()),
                                int.parse(monthController.text.trim()),
                                int.parse(dayController.text.trim()))
                            .toIso8601String(), // Converts to a proper ISO 8601 format
                        gender: isMale
                            ? "Male"
                            : "Female", // Adjust based on actual gender selection
                        email: emailController.text.trim(),
                        phoneNumber: phoneController.text.trim(),
                        occupation: _occupationController.text.trim(),
                        company: _companyController.text.trim(),
                        education: _educationController.text.trim(),
                        workExperience: _workExpController.text.trim(),
                        internshipExperience:
                            _internshipExpController.text.trim(),
                        skills: List.from(skills),
                        certifications: List.from(certifications),
                        password: passwordController.text.trim(),
                        startYear: _startYearController.text.trim(),
                        endYear: _endYearController.text.trim(),
                      );

                      if (response != null) {
                        // Get the UserProvider instance
                        final userProvider =
                            Provider.of<UserProvider>(context, listen: false);

                        // Save the token securely
                        await userProvider.setToken(response.token!);
                        await userProvider.setUser(response.user!);
                        // If successful, navigate to home screen
                        if (mounted) {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HomeScreen()));
                        }
                      } else {
                        throw Exception('registration failed');
                      }
                    } catch (e) {
                      // Show error message
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('registration failed: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } finally {
                      if (mounted) {
                        setState(() {
                          isLoading = false;
                        });
                      }
                    }
                  }
                },
          child: (isLoading)
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  "Register",
                  style: theme.textTheme.bodyMedium!
                      .copyWith(color: ColorsUtil.btntxtclr),
                ),
        ),
        const SizedBox(height: 20),
      ],
    );
    // );
  }

  Column Details_three(double width, ThemeData theme) {
    return Column(
      children: [
        // TextFormField(
        //   controller: _occupationController,
        //   style: theme.textTheme.bodyLarge!.copyWith(color: Colors.black),
        //   cursorColor: ColorsUtil.primaryclr,
        //   decoration: const InputDecoration(labelText: "Occupation"),
        //   validator: (value) =>
        //       value == null || value.isEmpty ? 'Occupation is required' : null,
        // ),
        // const SizedBox(height: 20),
        TextFormField(
          controller: _companyController,
          style: theme.textTheme.bodyLarge!.copyWith(color: Colors.black),
          cursorColor: ColorsUtil.primaryclr,
          decoration: const InputDecoration(labelText: "Company"),
          // validator: (value) => value == null || value.isEmpty
          //     ? 'Company name is required'
          //     : null,
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _educationController,
          style: theme.textTheme.bodyLarge!.copyWith(color: Colors.black),
          cursorColor: ColorsUtil.primaryclr,
          decoration: const InputDecoration(labelText: "Education"),
          validator: (value) =>
              value == null || value.isEmpty ? 'Education is required' : null,
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              width: width / 4,
              child: TextFormField(
                controller: _startYearController,
                keyboardType: TextInputType.number,
                style: theme.textTheme.bodyLarge!.copyWith(color: Colors.black),
                decoration: const InputDecoration(hintText: "Start year"),
                cursorColor: ColorsUtil.primaryclr,
                validator: (value) => value == null || value.isEmpty
                    ? 'Start year required'
                    : null,
              ),
            ),
            SizedBox(
              width: width / 4,
              child: TextFormField(
                controller: _endYearController,
                keyboardType: TextInputType.number,
                style: theme.textTheme.bodyLarge!.copyWith(color: Colors.black),
                cursorColor: ColorsUtil.primaryclr,
                decoration: const InputDecoration(labelText: "End year"),
                validator: (value) =>
                    value == null || value.isEmpty ? 'End year required' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _workExpController,
          style: theme.textTheme.bodyLarge!.copyWith(color: Colors.black),
          cursorColor: ColorsUtil.primaryclr,
          decoration: const InputDecoration(labelText: "Work experience"),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _internshipExpController,
          style: theme.textTheme.bodyLarge!.copyWith(color: Colors.black),
          cursorColor: ColorsUtil.primaryclr,
          decoration: const InputDecoration(labelText: "Internship experience"),
        ),
        const SizedBox(height: 50),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              setState(() {
                pageNumber++;
              });
            }
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
    // Controllers for form fields
    // final emailController = TextEditingController();
    // final phoneController = TextEditingController();
    // final passwordController = TextEditingController();
    // final confirmPasswordController = TextEditingController();

    // // Form key for validation
    // final _formKey = GlobalKey<FormState>();

    return Column(
      children: [
        Column(
          children: [
            TextFormField(
              controller: emailController,
              style: theme.textTheme.bodyLarge!.copyWith(color: Colors.black),
              cursorColor: ColorsUtil.primaryclr,
              decoration: const InputDecoration(
                label: Text("Email"),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                // Email format validation using regex
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: phoneController,
              style: theme.textTheme.bodyLarge!.copyWith(color: Colors.black),
              cursorColor: ColorsUtil.primaryclr,
              decoration: const InputDecoration(
                label: Text("Phone Number"),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                // Basic phone number validation
                final phoneRegex = RegExp(r'^\d{10,15}$');
                if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'\D'), ''))) {
                  return 'Please enter a valid phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: passwordController,
              style: theme.textTheme.bodyLarge!.copyWith(color: Colors.black),
              cursorColor: ColorsUtil.primaryclr,
              decoration: const InputDecoration(
                label: Text("New Password"),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password';
                }
                if (value.length < 8) {
                  return 'Password must be at least 8 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: confirmPasswordController,
              style: theme.textTheme.bodyLarge!.copyWith(color: Colors.black),
              cursorColor: ColorsUtil.primaryclr,
              decoration: const InputDecoration(
                label: Text("Confirm password"),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
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
            GestureDetector(
              onTap: () {
                // Navigate to login page
                // Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
              },
              child: Text(
                "Login",
                style: theme.textTheme.bodyMedium!
                    .copyWith(color: ColorsUtil.primaryclr),
              ),
            ),
          ],
        ),
        const SizedBox(height: 50),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // All form fields are valid, proceed to next page
              setState(() {
                pageNumber++;
              });
            }
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

  Widget Details_one(double width, ThemeData theme) {
    // Form key for validation
    // final _formKey = GlobalKey<FormState>();

    // // Controllers for text fields
    // final firstNameController = TextEditingController();
    // final lastNameController = TextEditingController();
    // final dayController = TextEditingController();
    // final monthController = TextEditingController();
    // final yearController = TextEditingController();

    // Gender selection state

    // bool isMale = true;

    // Validators
    String? validateName(String? value) {
      if (value == null || value.isEmpty) {
        return 'This field is required';
      }
      // Check if name contains only letters
      if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
        return 'Please enter valid name';
      }
      return null;
    }

    String? validateDay(String? value) {
      if (value == null || value.isEmpty) {
        return 'Required';
      }
      final day = int.tryParse(value);
      if (day == null || day < 1 || day > 31) {
        return 'Invalid';
      }
      return null;
    }

    String? validateMonth(String? value) {
      if (value == null || value.isEmpty) {
        return 'Required';
      }
      final month = int.tryParse(value);
      if (month == null || month < 1 || month > 12) {
        return 'Invalid';
      }
      return null;
    }

    String? validateYear(String? value) {
      if (value == null || value.isEmpty) {
        return 'Required';
      }
      final year = int.tryParse(value);
      final currentYear = DateTime.now().year;
      if (year == null || year < 1900 || year > currentYear) {
        return 'Invalid';
      }
      return null;
    }

    return Column(
      children: [
        TextFormField(
          controller: firstNameController,
          validator: validateName,
          style: theme.textTheme.bodyLarge!.copyWith(color: Colors.black),
          cursorColor: ColorsUtil.primaryclr,
          decoration: const InputDecoration(
            label: Text("First name"),
            errorMaxLines: 1,
          ),
        ),
        const SizedBox(height: 30),
        TextFormField(
          controller: lastNameController,
          validator: validateName,
          style: theme.textTheme.bodyLarge!.copyWith(color: Colors.black),
          cursorColor: ColorsUtil.primaryclr,
          decoration: const InputDecoration(
            label: Text("Last Name"),
            errorMaxLines: 1,
          ),
        ),
        const SizedBox(height: 30),
        TextFormField(
          controller: userNameController,
          validator: validateName,
          style: theme.textTheme.bodyLarge!.copyWith(color: Colors.black),
          cursorColor: ColorsUtil.primaryclr,
          decoration: const InputDecoration(
            label: Text("user Name"),
            errorMaxLines: 1,
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
                  controller: dayController,
                  validator: validateDay,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                  style:
                      theme.textTheme.bodyLarge!.copyWith(color: Colors.black),
                  cursorColor: ColorsUtil.primaryclr,
                  decoration: const InputDecoration(
                    label: Text("DD"),
                    errorMaxLines: 1,
                  ),
                ),
              ),
              SizedBox(
                width: width / 4,
                child: TextFormField(
                  controller: monthController,
                  validator: validateMonth,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                  style:
                      theme.textTheme.bodyLarge!.copyWith(color: Colors.black),
                  cursorColor: ColorsUtil.primaryclr,
                  decoration: const InputDecoration(
                    label: Text("MM"),
                    errorMaxLines: 1,
                  ),
                ),
              ),
              SizedBox(
                width: width / 4,
                child: TextFormField(
                  controller: yearController,
                  validator: validateYear,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  style:
                      theme.textTheme.bodyLarge!.copyWith(color: Colors.black),
                  cursorColor: ColorsUtil.primaryclr,
                  decoration: const InputDecoration(
                    label: Text("YYYY"),
                    errorMaxLines: 1,
                  ),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  isMale = true;
                });
              },
              child: Container(
                height: 50,
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  color: isMale ? ColorsUtil.primaryclr : Colors.transparent,
                  border:
                      isMale ? null : Border.all(color: ColorsUtil.borderclr),
                ),
                child: Center(
                  child: Text(
                    "Male",
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: isMale
                          ? ColorsUtil.btntxtclr
                          : theme.textTheme.bodyMedium!.color,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                setState(() {
                  isMale = false;
                });
              },
              child: Container(
                height: 50,
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  color: !isMale ? ColorsUtil.primaryclr : Colors.transparent,
                  border:
                      !isMale ? null : Border.all(color: ColorsUtil.borderclr),
                ),
                child: Center(
                  child: Text(
                    "Female",
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: !isMale
                          ? ColorsUtil.btntxtclr
                          : theme.textTheme.bodyMedium!.color,
                    ),
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
            Text(
              "Already have an account? ",
              style: theme.textTheme.bodyMedium,
            ),
            GestureDetector(
              onTap: () {
                // Navigate to login screen
                // Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
              },
              child: Text(
                "Login",
                style: theme.textTheme.bodyMedium!
                    .copyWith(color: ColorsUtil.primaryclr),
              ),
            )
          ],
        ),
        const SizedBox(height: 50),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // Form is valid, proceed with data
              debugPrint("male: " + isMale.toString());
              final userData = {
                'firstName': firstNameController.text,
                'lastName': lastNameController.text,
                'day': dayController.text,
                'month': monthController.text,
                'year': yearController.text,
                'gender': isMale ? 'Male' : 'Female',
              };

              // You can process userData here
              print(userData);

              setState(() {
                pageNumber++;
              });
            }
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
