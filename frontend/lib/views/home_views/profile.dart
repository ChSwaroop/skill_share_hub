// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:skill_share_hub/colors.dart';
// import 'package:skill_share_hub/providers/user_provider.dart';
// import 'package:skill_share_hub/views/settings.dart';
// import 'package:skill_share_hub/views/util/custom_card.dart';

// class Profile extends StatefulWidget {
//   const Profile({super.key});

//   @override
//   State<Profile> createState() => _ProfileState();
// }

// class _ProfileState extends State<Profile> {
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     double height = MediaQuery.of(context).size.height;
//     double width = MediaQuery.of(context).size.width;
//     List<String> skills = [
//       "Web development",
//       "Java Script",
//       "Green sock library",
//     ];
//     List<String> certifications = [
//       "Web certification",
//       "java in udemy",
//       "coursera ( python )"
//     ];

//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 40),
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   IconButton(
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                     icon: const Icon(Icons.arrow_back_ios),
//                   ),
//                   Row(
//                     children: [
//                       InkWell(
//                         onTap: () {
//                           Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) => Settings()));
//                         },
//                         child: Image.asset("assets/images/settings.png"),
//                       ),
//                       const SizedBox(width: 7),
//                       OutlinedButton(
//                         onPressed: () {},
//                         child: Text(
//                           "edit",
//                           style: theme.textTheme.bodySmall!
//                               .copyWith(color: ColorsUtil.primaryclr),
//                         ),
//                       ),
//                       IconButton(
//                         onPressed: () async {
//                           // Call logout function
//                           debugPrint("called logout");
//                           final userProvider =
//                               Provider.of<UserProvider>(context, listen: false);
//                           await userProvider.logout();
//                         },
//                         icon: Icon(Icons.logout),
//                       ),
//                     ],
//                   )
//                 ],
//               ),
//               Container(
//                 height: 115,
//                 width: 115,
//                 child: Image.asset(
//                   "assets/images/userprofile.png",
//                   fit: BoxFit.cover,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 "Veda",
//                 style: theme.textTheme.headlineSmall!.copyWith(
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               Text(
//                 "Mumbai, India",
//                 style: theme.textTheme.bodySmall,
//               ),
//               const SizedBox(height: 20),
//               Container(
//                 height: 23,
//                 width: 39,
//                 decoration: BoxDecoration(
//                   border: Border.all(color: ColorsUtil.borderclr),
//                   borderRadius: BorderRadius.circular(360),
//                 ),
//                 padding: const EdgeInsets.all(3),
//                 child: Center(
//                   child: Row(
//                     children: [
//                       const Icon(
//                         Icons.star,
//                         color: Colors.yellow,
//                         size: 15,
//                       ),
//                       Text(
//                         "4.2",
//                         style: theme.textTheme.bodySmall!.copyWith(
//                           fontSize: 9,
//                           color: Colors.black,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               const Divider(
//                 color: ColorsUtil.borderclr,
//               ),
//               const SizedBox(height: 25),
//               Text(
//                 "creative problem-solver with a passion for blending design and technology. Experienced in developing user-friendly apps and commited to enchancing digital experiences with a focus on community impact.",
//                 style: theme.textTheme.bodySmall!.copyWith(
//                   color: const Color(0xFF1E1E1E),
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 25),
//               Container(
//                 height: 35,
//                 width: 142,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(17.5),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     socialmedia("assets/images/twitter.png", () {}),
//                     socialmedia("assets/images/instagram.png", () {}),
//                     socialmedia("assets/images/linkedin.png", () {}),
//                     socialmedia("assets/images/whatsapp.png", () {}),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 30),
//               Row(
//                 children: [
//                   Image.asset("assets/images/call.png"),
//                   const SizedBox(width: 8),
//                   Text(
//                     "rhyanronalds@email.com",
//                     style: theme.textTheme.bodySmall!
//                         .copyWith(color: ColorsUtil.thirdtxtclr),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               Row(
//                 children: [
//                   Image.asset("assets/images/mail.png"),
//                   const SizedBox(width: 8),
//                   Text(
//                     "+91 9834928502",
//                     style: theme.textTheme.bodySmall!
//                         .copyWith(color: ColorsUtil.thirdtxtclr),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 24),
//               const Divider(
//                 color: ColorsUtil.borderclr,
//               ),
//               const SizedBox(height: 32),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   custombtn(width, theme, "Portifolio website", () {}),
//                   custombtn(width, theme, "Resume", () {}),
//                 ],
//               ),
//               const SizedBox(
//                 height: 27,
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   card_custom(
//                       theme: theme, heading: "Skills shared", txt: "12"),
//                   const SizedBox(width: 16),
//                   card_custom(
//                       theme: theme, heading: "Skills learned", txt: "12"),
//                 ],
//               ),
//               const SizedBox(height: 24),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "Skills",
//                         style: theme.textTheme.bodySmall!.copyWith(
//                             color: ColorsUtil.thirdtxtclr,
//                             fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(height: 5),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: List.generate(
//                           skills.length,
//                           (index) {
//                             return Row(
//                               children: [
//                                 Container(
//                                   height: 3,
//                                   width: 3,
//                                   decoration: const BoxDecoration(
//                                     shape: BoxShape.circle,
//                                     color: ColorsUtil.thirdtxtclr,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 5),
//                                 Text(
//                                   skills[index],
//                                   style: theme.textTheme.bodySmall!
//                                       .copyWith(color: ColorsUtil.thirdtxtclr),
//                                 )
//                               ],
//                             );
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(width: 15),
//                   Container(
//                     height: 80,
//                     width: 2,
//                     decoration:
//                         const BoxDecoration(color: ColorsUtil.borderclr),
//                   ),
//                   const SizedBox(width: 15),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         "Certifications",
//                         style: theme.textTheme.bodySmall!.copyWith(
//                             color: ColorsUtil.thirdtxtclr,
//                             fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(height: 5),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: List.generate(
//                           skills.length,
//                           (index) {
//                             return Column(
//                               children: [
//                                 Row(
//                                   children: [
//                                     Container(
//                                       height: 3,
//                                       width: 3,
//                                       decoration: const BoxDecoration(
//                                         shape: BoxShape.circle,
//                                         color: ColorsUtil.thirdtxtclr,
//                                       ),
//                                     ),
//                                     const SizedBox(width: 5),
//                                     Text(
//                                       certifications[index],
//                                       style: theme.textTheme.bodySmall!
//                                           .copyWith(
//                                               color: ColorsUtil.thirdtxtclr),
//                                     )
//                                   ],
//                                 ),
//                                 const SizedBox(height: 3),
//                               ],
//                             );
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   InkWell custombtn(double width, ThemeData theme, String txt, callback) {
//     return InkWell(
//       onTap: callback,
//       child: Container(
//         height: 40,
//         width: (width - 100) / 2,
//         // padding: EdgeInsets.all(10),
//         decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(17.5),
//             color: Colors.white,
//             boxShadow: [
//               BoxShadow(
//                   offset: const Offset(1, 1),
//                   spreadRadius: 2,
//                   blurRadius: 7,
//                   color: Colors.grey.shade300),
//             ]),
//         child: Center(
//           child: Text(
//             txt,
//             style: theme.textTheme.titleMedium!
//                 .copyWith(color: ColorsUtil.primaryclr),
//           ),
//         ),
//       ),
//     );
//   }

//   InkWell socialmedia(String path, callback) {
//     return InkWell(
//       onTap: callback,
//       child: Image.asset(path),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:skill_share_hub/colors.dart';
import 'package:skill_share_hub/providers/todo_provider.dart';
import 'package:skill_share_hub/providers/user_provider.dart';
import 'package:skill_share_hub/views/feedback.dart';
import 'package:skill_share_hub/views/home_views/editProfile.dart';
import 'package:skill_share_hub/views/login_views/login.dart';
import 'package:skill_share_hub/views/settings.dart';
import 'package:skill_share_hub/views/util/custom_card.dart';
// import 'package:skill_share_hub/views/edit_profile.dart'; // New import for edit profile

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  int connectionsCount = 0;
  int todoCount = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      isLoading = true;
      setState(() {});

      Provider.of<UserProvider>(context, listen: false).getConnectionsCount();
      Provider.of<TodoProvider>(context, listen: false).fetchTodos();

      setState(() {
        // todoCount = todoCountResponse ?? 0;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    //Filter the todosCount for those who have completed field is true
    int completedTodosCount = Provider.of<TodoProvider>(context)
        .todos
        .where((todo) => todo.completed == false)
        .toList()
        .length;

    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    // Use user skills if available, otherwise use static data
    List<String> skills = user?.skills ??
        [
          "Web development",
          "Java Script",
          "Green sock library",
        ];

    // Use user certifications if available, otherwise use static data
    List<String> certifications =
        user?.certifications?.map((cert) => cert.toString()).toList() ??
            ["Web certification", "java in udemy", "coursera ( python )"];

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 40),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back_ios),
                  ),
                  Row(
                    children: [
                      // InkWell(
                      //   onTap: () {
                      //     Navigator.push(
                      //         context,
                      //         MaterialPageRoute(
                      //             builder: (context) => Settings()));
                      //   },
                      //   child: Image.asset("assets/images/settings.png"),
                      // ),
                      const SizedBox(width: 7),
                      // OutlinedButton(
                      //   onPressed: () {
                      //     // Navigate to Edit Profile screen
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //         builder: (context) => EditProfile(),
                      //       ),
                      //     );
                      //   },
                      //   child: Text(
                      //     "edit",
                      //     style: theme.textTheme.bodySmall!
                      //         .copyWith(color: ColorsUtil.primaryclr),
                      //   ),
                      // ),
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FeedbackPage(),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.featured_play_list_outlined,
                          color: ColorsUtil.primaryclr,
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          // Call logout function
                          await userProvider.logout();

                          // Assuming you have a navigation setup to redirect to login screen
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) =>
                                  Login(), // Replace with your actual login screen widget
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.logout,
                          color: ColorsUtil.primaryclr,
                        ),
                      ),
                    ],
                  )
                ],
              ),
              Container(
                height: 115,
                width: 115,
                child: (user?.profilePicture != null &&
                        user!.profilePicture!.isNotEmpty)
                    ? Image.network(user!.profilePicture!, fit: BoxFit.cover)
                    : Image.network(
                        "https://img.freepik.com/premium-vector/conceptual-illustration-person-crossing-finish-line-with-determination_1263357-35011.jpg?ga=GA1.1.1483351532.1733847503&semt=ais_hybrid",
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(height: 8),
              Text(
                "${user?.firstName ?? 'Veda'} ${user?.lastName ?? ''}".trim(),
                style: theme.textTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                user?.email ?? "Mumbai, India",
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 20),
              Container(
                height: 23,
                width: 39,
                decoration: BoxDecoration(
                  border: Border.all(color: ColorsUtil.borderclr),
                  borderRadius: BorderRadius.circular(360),
                ),
                padding: const EdgeInsets.all(3),
                child: Center(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.yellow,
                        size: 15,
                      ),
                      Text(
                        "4.2",
                        style: theme.textTheme.bodySmall!.copyWith(
                          fontSize: 9,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(
                color: ColorsUtil.borderclr,
              ),
              const SizedBox(height: 25),
              Text(
                user?.bio ??
                    "Creative problem-solver with a passion for blending design and technology. Experienced in developing user-friendly apps and committed to enhancing digital experiences with a focus on community impact.",
                style: theme.textTheme.bodySmall!.copyWith(
                  color: const Color(0xFF1E1E1E),
                ),
                textAlign: TextAlign.center,
              ),
              // const SizedBox(height: 25),
              // Container(
              //   height: 35,
              //   width: 142,
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(17.5),
              //   ),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //     children: [
              //       socialmedia("assets/images/twitter.png", () {}),
              //       socialmedia("assets/images/instagram.png", () {}),
              //       socialmedia("assets/images/linkedin.png", () {}),
              //       socialmedia("assets/images/whatsapp.png", () {}),
              //     ],
              //   ),
              // ),
              // const SizedBox(height: 30),
              Row(
                children: [
                  Image.asset("assets/images/mail.png"),
                  const SizedBox(width: 8),
                  Text(
                    user?.email ?? "rhyanronalds@email.com",
                    style: theme.textTheme.bodySmall!
                        .copyWith(color: ColorsUtil.thirdtxtclr),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Image.asset("assets/images/call.png"),
                  const SizedBox(width: 8),
                  Text(
                    user?.phoneNumber ?? "+91 9834928502",
                    style: theme.textTheme.bodySmall!
                        .copyWith(color: ColorsUtil.thirdtxtclr),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(
                color: ColorsUtil.borderclr,
              ),
              // const SizedBox(height: 32),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //   children: [
              //     custombtn(width, theme, "Portfolio website", () {}),
              //     custombtn(width, theme, "Resume", () {}),
              //   ],
              // ),
              const SizedBox(
                height: 27,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  card_custom(
                    theme: theme,
                    heading: "Connections",
                    txt: Provider.of<UserProvider>(context)
                        .connectionsCount
                        .toString(),
                  ),
                  const SizedBox(width: 15),
                  Container(
                    width: 130,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: const Color(0xFFFFECA7),
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(1, 1),
                          spreadRadius: 1,
                          blurRadius: 10,
                          color: Colors.grey.shade200,
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Pending Tasks",
                          style: theme.textTheme.bodySmall!
                              .copyWith(color: ColorsUtil.textclr),
                        ),
                        Text(
                          completedTodosCount.toString() ?? '0',
                          style: theme.textTheme.headlineMedium!.copyWith(
                              fontSize: 35, color: ColorsUtil.textclr),
                        )
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Skills",
                        style: theme.textTheme.bodySmall!.copyWith(
                            color: ColorsUtil.thirdtxtclr,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(
                          skills.length,
                          (index) {
                            return Row(
                              children: [
                                Container(
                                  height: 3,
                                  width: 3,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: ColorsUtil.thirdtxtclr,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  skills[index],
                                  style: theme.textTheme.bodySmall!
                                      .copyWith(color: ColorsUtil.thirdtxtclr),
                                )
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  // const SizedBox(width: 15),
                  // Container(
                  //   height: 80,
                  //   width: 2,
                  //   decoration:
                  //       const BoxDecoration(color: ColorsUtil.borderclr),
                  // ),
                  // const SizedBox(width: 15),
                  // Column(
                  //   crossAxisAlignment: CrossAxisAlignment.start,
                  //   children: [
                  //     Text(
                  //       "Certifications",
                  //       style: theme.textTheme.bodySmall!.copyWith(
                  //           color: ColorsUtil.thirdtxtclr,
                  //           fontWeight: FontWeight.bold),
                  //     ),
                  //     const SizedBox(height: 5),
                  //     Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: List.generate(
                  //         certifications.length,
                  //         (index) {
                  //           return Column(
                  //             children: [
                  //               Row(
                  //                 children: [
                  //                   Container(
                  //                     height: 3,
                  //                     width: 3,
                  //                     decoration: const BoxDecoration(
                  //                       shape: BoxShape.circle,
                  //                       color: ColorsUtil.thirdtxtclr,
                  //                     ),
                  //                   ),
                  //                   const SizedBox(width: 5),
                  //                   Text(
                  //                     certifications[index],
                  //                     style: theme.textTheme.bodySmall!
                  //                         .copyWith(
                  //                             color: ColorsUtil.thirdtxtclr),
                  //                   )
                  //                 ],
                  //               ),
                  //               const SizedBox(height: 3),
                  //             ],
                  //           );
                  //         },
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  InkWell custombtn(double width, ThemeData theme, String txt, callback) {
    return InkWell(
      onTap: callback,
      child: Container(
        height: 40,
        width: (width - 100) / 2,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17.5),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  offset: const Offset(1, 1),
                  spreadRadius: 2,
                  blurRadius: 7,
                  color: Colors.grey.shade300),
            ]),
        child: Center(
          child: Text(
            txt,
            style: theme.textTheme.titleMedium!
                .copyWith(color: ColorsUtil.primaryclr),
          ),
        ),
      ),
    );
  }

  InkWell socialmedia(String path, callback) {
    return InkWell(
      onTap: callback,
      child: Image.asset(path),
    );
  }
}
