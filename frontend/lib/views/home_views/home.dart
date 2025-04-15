import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:skill_share_hub/colors.dart';
import 'package:skill_share_hub/constants.dart';
import 'package:skill_share_hub/models/connection_model.dart' as connection;
import 'package:skill_share_hub/models/recommendation%20models/personalized_recommendations_model.dart';
import 'package:skill_share_hub/providers/todo_provider.dart';
import 'package:skill_share_hub/providers/user_provider.dart';
import 'package:skill_share_hub/repo/connection_repo.dart';
import 'package:skill_share_hub/repo/recommendationsRepo.dart';
import 'package:skill_share_hub/repo/todorepo.dart';
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
import 'package:skill_share_hub/views/util/shimmer_user.dart';
import 'package:skill_share_hub/models/connection_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int curCardIndex = 0;
  bool isLoading = false;
  int connectionsCount = 0;
  int todoCount = 0;
  late PersonalizedRecommendation personalizedRecommendations;
  List<connection.Datum> _connections = [];

  Future<void> _loadConnections() async {
    // if (isLoading) return;
    // setState(() {
    //   _isLoadingConnections = true;
    // });

    try {
      final Connection connectionData = await ConnectionRepo().getMyConnections(
          'accepted',
          1,
          20,
          Provider.of<UserProvider>(context, listen: false).token!);

      if (connectionData.success == true && connectionData.data != null) {
        // debugPrint("Connections: ${connectionData.data}");
        setState(() {
          _connections.addAll(connectionData.data!);
        });
      } else {
        print('API Error: ${connectionData.toString()}');
      }
    } catch (e) {
      print('Error loading connections: $e');
    } finally {}
  }

  //method to fetch connections count

  Future<void> fetchConnectionsCount() async {
    String token = Provider.of<UserProvider>(context, listen: false).token!;
    final response = await ConnectionRepo().getConnectionsCount(token);
    setState(() {
      connectionsCount = response ?? 0;
    });
  }

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      isLoading = true;
      setState(() {});

      Provider.of<UserProvider>(context, listen: false).getConnectionsCount();
      Provider.of<TodoProvider>(context, listen: false).fetchTodos();
      final data = await RecommendationRepo().fetchPersonalizedRecommendations(
          Provider.of<UserProvider>(context, listen: false).token!);

      personalizedRecommendations = data!;
      await _loadConnections();

      setState(() {
        // todoCount = todoCountResponse ?? 0;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    //Filter the todosCount for those who have completed field is true
    int completedTodosCount = Provider.of<TodoProvider>(context)
        .todos
        .where((todo) => todo.completed == false)
        .toList()
        .length;

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
                          child: Icon(
                            Icons.chat_bubble_outline,
                            color: ColorsUtil.primaryclr,
                          ),
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
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Profile(),
                            ),
                          );
                        },
                        child: CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(
                              'https://img.freepik.com/premium-vector/conceptual-illustration-person-crossing-finish-line-with-determination_1263357-35011.jpg?ga=GA1.1.1483351532.1733847503&semt=ais_hybrid'),
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
                  child: Text(
                    "View more",
                    style: theme.textTheme.bodyLarge!.copyWith(
                      color: ColorsUtil.primaryclr,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
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
              (isLoading)
                  ? ShimmerUser()
                  : details_card(width, theme, personalizedRecommendations),
            ],
          ),
        ),
      ),
    );
  }

  Column details_card(
      double width, ThemeData theme, PersonalizedRecommendation rec) {
    return Column(
      children: [
        //   ],
        // )
        SizedBox(
          height: 270,
          width: width,
          child: Center(
            child: CarouselSlider.builder(
              itemCount: min(
                  ((rec != null && rec.data != null) ? rec.data!.length : 0),
                  10),
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
                      ),
                      // BoxShadow(
                      //   offset: Offset(4, 4),
                      //   spreadRadius: 2,
                      //   blurRadius: 10,
                      //   color: Colors.black.withOpacity(0.1),
                      // )
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                rec.data![ind].name ?? "No name",
                                style: theme.textTheme.titleMedium,
                              ),
                              Text(
                                rec.data![ind].experts![0].firstName ??
                                    "No name",
                                style: theme.textTheme.titleMedium,
                              )
                            ],
                          ),
                          (rec.data![ind].experts!.length > 0 &&
                                  rec.data![ind].experts![0].profilePicture !=
                                      null &&
                                  rec.data![ind].experts![0].profilePicture!
                                      .isNotEmpty)
                              ? CircleAvatar(
                                  radius: 20,
                                  backgroundImage: NetworkImage(rec
                                      .data![ind].experts![0].profilePicture!),
                                )
                              : const CircleAvatar(
                                  radius: 20,
                                  backgroundImage:
                                      AssetImage("assets/images/cardpic.png"),
                                ),
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
                      (rec.data![ind].experts![0].skills != null &&
                              rec.data![ind].experts![0].skills!.isNotEmpty)
                          ? Column(
                              children: [
                                for (var i = 0;
                                    i <
                                        min(
                                            rec.data![ind].experts![0].skills!
                                                .length,
                                            3);
                                    i++)
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
                                        rec.data![ind].experts![0].skills![i]
                                                .name ??
                                            "No name",
                                        style: theme.textTheme.bodySmall!
                                            .copyWith(
                                                color: const Color(0xFFBABABA)),
                                      ),
                                    ],
                                  ),
                              ],
                            )
                          : SizedBox(),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // ElevatedButton(
                          //   style: ElevatedButton.styleFrom(
                          //     fixedSize: Size((width - 150) / 2, 30),
                          //     backgroundColor: Colors.white,
                          //   ),
                          //   onPressed: () {},
                          //   child: Text(
                          //     "Know more",
                          //     style: theme.textTheme.titleMedium!
                          //         .copyWith(color: ColorsUtil.primaryclr),
                          //   ),
                          // ),

                          //check whether the user is already a connection
                          // if yes, show "Message" button
                          // if no, show "Connect" button
                          _connections.any((connection) =>
                                  connection.requesterId!.id ==
                                      rec.data![ind].experts![0].id ||
                                  connection.recipientId!.id ==
                                      rec.data![ind].experts![0].id)
                              ? ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    fixedSize: Size((width - 150) / 2, 30),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatListScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "Message",
                                    style: theme.textTheme.titleMedium!
                                        .copyWith(color: Colors.white),
                                  ),
                                )
                              : //if not, show "Connect" button

                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    fixedSize: Size((width - 150) / 2, 30),
                                  ),
                                  onPressed: () async {
                                    final response =
                                        await ConnectionRepo().createConnection(
                                      rec.data![ind].experts![0].id!,
                                      "",
                                      Provider.of<UserProvider>(context,
                                              listen: false)
                                          .token!,
                                    );
                                  },
                                  child: Text(
                                    "Connect",
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
              itemCount: min(
                  ((rec != null && rec.data != null) ? rec.data!.length : 0),
                  10),
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
