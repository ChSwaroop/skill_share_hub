import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skill_share_hub/colors.dart';
import 'package:skill_share_hub/models/connection_model.dart';
import 'package:skill_share_hub/providers/user_provider.dart';
import 'package:skill_share_hub/views/analysis_graphs/analysis.dart';
import 'package:skill_share_hub/views/analysis_graphs/line_chart.dart';
import 'package:skill_share_hub/views/analysis_graphs/message_chart_data_call.dart';
import 'package:skill_share_hub/views/blocked_users.dart';
import 'package:skill_share_hub/views/chat_views/chat_list_screen.dart';
import 'package:skill_share_hub/views/home_views/chart.dart';
import 'package:skill_share_hub/views/home_views/chat_bot.dart';
import 'package:skill_share_hub/views/home_views/chat_bot_2.dart';
import 'package:skill_share_hub/views/home_views/chat_menu.dart';
import 'package:skill_share_hub/views/home_views/connections.dart';
import 'package:skill_share_hub/views/home_views/explore.dart';
import 'package:skill_share_hub/views/home_views/profile.dart';
import 'package:skill_share_hub/views/home_views/todo.dart';
import 'package:skill_share_hub/views/util/custom_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int curCardIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: ColorsUtil.bgclr,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 50),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Image.asset("assets/images/icon.png"),
                  ),
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Profile(),
                            ),
                          );
                        },
                        child: Container(
                          height: 30,
                          width: 30,
                          child: Image.asset("assets/images/profile-pic1.png"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ChatBot(),
                            ),
                          );
                        },
                        child: Container(
                          child: Image.asset("assets/images/chatbot.png"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ToDo()));
                        },
                        child: Container(
                          child: Image.asset("assets/images/check.png"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: () {
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) => const ChatMenu()));
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ChatListScreen(),
                            ),
                          );
                        },
                        child: Container(
                          child: Image.asset("assets/images/notifications.png"),
                        ),
                      ),
                      SizedBox(width: 10),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ConnectionsPage(
                                authToken:
                                    Provider.of<UserProvider>(context).token!,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          height: 30,
                          width: 30,
                          child: Icon(
                            Icons.people_outline,
                            color: ColorsUtil.primaryclr,
                            size: 30,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 15),
              // TextFormField(
              //   style: theme.textTheme.bodyLarge!.copyWith(color: Colors.black),
              //   cursorColor: ColorsUtil.primaryclr,
              //   decoration: const InputDecoration(
              //       hintText: "Search for a skill to learn..."),
              // ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Explore()),
                  );
                },
                child: Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: ColorsUtil.borderclr,
                    ),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  padding: EdgeInsets.only(left: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Search for a skill to learn..."),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Text(
                    "Hi,${Provider.of<UserProvider>(context).user!.username}!",
                    style: theme.textTheme.headlineSmall,
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    "Let's help each other by ",
                    style: theme.textTheme.bodySmall,
                  ),
                  Text("sharing ",
                      style: theme.textTheme.bodySmall!
                          .copyWith(color: ColorsUtil.primaryclr)),
                  Text("and ", style: theme.textTheme.bodySmall),
                  Text("swapping",
                      style: theme.textTheme.bodySmall!.copyWith(
                        color: ColorsUtil.primaryclr,
                      )),
                ],
              ),
              const SizedBox(height: 30),
              // Row(
              //   children: [
              //     Text(
              //       "Continue Learning",
              //       style: theme.textTheme.bodyMedium!
              //           .copyWith(color: ColorsUtil.textclr),
              //     ),
              //   ],
              // ),
              // const SizedBox(height: 15),
              // Container(
              //   height: 80,
              //   width: width,
              //   padding: const EdgeInsets.all(15),
              //   margin: const EdgeInsets.symmetric(horizontal: 5),
              //   decoration: BoxDecoration(
              //       borderRadius: BorderRadius.circular(50),
              //       color: Colors.white,
              //       boxShadow: [
              //         BoxShadow(
              //             offset: const Offset(1, 1),
              //             spreadRadius: 3,
              //             blurRadius: 5,
              //             color: Colors.grey.shade300)
              //       ]),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: [
              //       Image.asset("assets/images/profile-pic1.png"),
              //       Text(
              //         "MongoDB",
              //         style: theme.textTheme.titleMedium,
              //       ),
              //       Image.asset("assets/images/sync.png"),
              //       Text(
              //         "JavaScript",
              //         style: theme.textTheme.titleMedium,
              //       ),
              //       Image.asset("assets/images/profile-pic2.png"),
              //     ],
              //   ),
              // ),
              const SizedBox(height: 35),
              Container(
                // height: 170,
                width: width,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: const DecorationImage(
                      opacity: 0.3,
                      image: AssetImage("assets/images/hero.png")),
                  gradient: const LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: [
                      Color(0XFF1FA0D7),
                      Color(0xFFB2CDFF),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      "Lets help each other by sharing your skills and got benefited by getting their skills. Just start now !",
                      style: theme.textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    // const Spacer(),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        fixedSize: const Size(130, 30),
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Explore()));
                      },
                      child: Text(
                        "Explore now !",
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  card_custom(
                    theme: theme,
                    heading: "Connections",
                    txt: "3",
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
                          "Tasks Today",
                          style: theme.textTheme.bodyMedium!
                              .copyWith(color: ColorsUtil.textclr),
                        ),
                        Text(
                          "03",
                          style: theme.textTheme.headlineMedium!.copyWith(
                              fontSize: 40, color: ColorsUtil.textclr),
                        )
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
              // SizedBox(
              //   height: 120,
              //   width: width - 100,
              //   child: LineChartSample(),
              // ),
              Image.asset("assets/images/graph.png"),
              SizedBox(height: 20),
              TextButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => TrailChart()));
                  },
                  child: Text("View more")),
              const SizedBox(height: 60),
              Row(
                children: [
                  Text(
                    "Recommended for you",
                    style: theme.textTheme.bodyMedium!.copyWith(
                        color: ColorsUtil.textclr, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              details_card(width, theme),
            ],
          ),
        ),
      ),
    );
  }

  Column details_card(double width, ThemeData theme) {
    return Column(
      children: [
        //   ],
        // )
        SizedBox(
          height: 270,
          width: width,
          child: Center(
            child: CarouselSlider.builder(
              itemCount: 3,
              itemBuilder: (context, ind, j) {
                return Container(
                  height: 250,
                  width: width - 100,
                  margin: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 5.0),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color.fromRGBO(255, 255, 255, 1),
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(1, 1),
                        spreadRadius: 1,
                        blurRadius: 6,
                        color: Colors.grey.shade300,
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 17,
                            width: 33,
                            decoration: BoxDecoration(
                              border: Border.all(color: ColorsUtil.borderclr),
                              borderRadius: BorderRadius.circular(360),
                            ),
                            // padding: EdgeInsets.all(3),
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
                        ],
                      ),
                      const SizedBox(height: 9),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Python Development",
                            style: theme.textTheme.titleMedium,
                          ),
                          Image.asset("assets/images/cardpic.png")
                        ],
                      ),
                      const SizedBox(height: 15),
                      const Divider(
                        color: Color(0xFFD9D9D9),
                      ),
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          Text(
                            "Other skills",
                            style: theme.textTheme.bodySmall!.copyWith(
                                color: const Color(0xFFBABABA), fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          Container(
                            height: 5,
                            width: 5,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFBABABA),
                            ),
                          ),
                          const SizedBox(width: 7),
                          Text(
                            "Web development",
                            style: theme.textTheme.bodySmall!
                                .copyWith(color: const Color(0xFFBABABA)),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            height: 5,
                            width: 5,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFBABABA),
                            ),
                          ),
                          const SizedBox(width: 7),
                          Text(
                            "java Scripting",
                            style: theme.textTheme.bodySmall!
                                .copyWith(color: const Color(0xFFBABABA)),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            height: 5,
                            width: 5,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFBABABA),
                            ),
                          ),
                          const SizedBox(width: 7),
                          Text(
                            "Green sock library",
                            style: theme.textTheme.bodySmall!
                                .copyWith(color: const Color(0xFFBABABA)),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                fixedSize: Size((width - 150) / 2, 30),
                                backgroundColor: Colors.white),
                            onPressed: () {},
                            child: Text(
                              "Know more",
                              style: theme.textTheme.titleMedium!
                                  .copyWith(color: ColorsUtil.primaryclr),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              fixedSize: Size((width - 150) / 2, 30),
                            ),
                            onPressed: () {},
                            child: Text(
                              "Message",
                              style: theme.textTheme.titleMedium!
                                  .copyWith(color: Colors.white),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                );
              },
              options: CarouselOptions(
                height: 270,
                viewportFraction: 0.9,
                autoPlay: true,
                onPageChanged: (ind, reason) {
                  setState(() {
                    curCardIndex = ind;
                  });
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        SizedBox(
          height: 7,
          width: width,
          child: Center(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              shrinkWrap: true,
              itemBuilder: (context, ind) {
                return Container(
                  height: 7,
                  width: (curCardIndex == ind) ? 16 : 7,
                  margin: const EdgeInsets.only(right: 7),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: (curCardIndex == ind)
                        ? ColorsUtil.primaryclr
                        : const Color(0xFFD9D9D9),
                  ),
                );
              },
            ),
          ),
        ),
        SizedBox(height: 20),
        // ElevatedButton(
        //   onPressed: () {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //         builder: (context) => BlockedUsers(),
        //       ),
        //     );
        //   },
        //   child: Text(
        //     "Blocked users",
        //     style: TextStyle(
        //       color: Colors.white,
        //     ),
        //   ),
        // )
      ],
    );
  }
}
