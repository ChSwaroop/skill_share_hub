import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:skill_share_hub/colors.dart';
import 'package:skill_share_hub/views/home_views/chart.dart';
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
        padding: const EdgeInsets.symmetric(horizontal: 35.0, vertical: 50),
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
                      Container(
                        height: 30,
                        width: 30,
                        child: Image.asset("assets/images/profile-pic1.png"),
                      ),
                      SizedBox(width: 10),
                      Container(
                        child: Image.asset("assets/images/chatbot.png"),
                      ),
                      // SizedBox(width: 10),
                      // Container(
                      //   child: Image.asset("assests/images/check.png"),
                      // ),
                      SizedBox(width: 10),
                      Container(
                        child: Image.asset("assets/images/notifications.png"),
                      )
                    ],
                  )
                ],
              ),
              SizedBox(height: 15),
              TextFormField(
                decoration:
                    InputDecoration(hintText: "Search for a skill to learn..."),
              ),
              SizedBox(height: 30),
              Row(
                children: [
                  Text(
                    "Hi, Rishika!",
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
              SizedBox(height: 30),
              Row(
                children: [
                  Text(
                    "Continue Learning",
                    style: theme.textTheme.bodyMedium!
                        .copyWith(color: ColorsUtil.textclr),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Container(
                height: 80,
                width: width,
                padding: EdgeInsets.all(15),
                margin: EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          offset: Offset(1, 1),
                          spreadRadius: 3,
                          blurRadius: 5,
                          color: Colors.grey.shade300)
                    ]),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset("assets/images/profile-pic1.png"),
                    Text(
                      "MongoDB",
                      style: theme.textTheme.titleMedium,
                    ),
                    Image.asset("assets/images/sync.png"),
                    Text(
                      "JavaScript",
                      style: theme.textTheme.titleMedium,
                    ),
                    Image.asset("assets/images/profile-pic2.png"),
                  ],
                ),
              ),
              SizedBox(height: 35),
              Container(
                height: 170,
                width: width,
                padding: EdgeInsets.all(25),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                      opacity: 0.3,
                      image: AssetImage("assets/images/hero.png")),
                  gradient: LinearGradient(
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
                    Spacer(),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        fixedSize: Size(130, 30),
                      ),
                      onPressed: () {},
                      child: Text(
                        "Explore now !",
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  card_custom(theme: theme , heading: "Skills shared & learned" , txt: "12",),
                  SizedBox(width: 15),
                  Container(
                    height: 90,
                    width: 130,
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Color(0xFFFFECA7),
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
              SizedBox(height: 20),
              SizedBox(
                height: 120,
                width: width - 100,
                child: LineChartSample(),
              ),
              SizedBox(height: 60),
              Row(
                children: [
                  Text(
                    "Recommended for you",
                    style: theme.textTheme.bodyMedium!.copyWith(
                        color: ColorsUtil.textclr, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 15),
              SizedBox(
                height: 270,
                width: width,
                child: Center(
                  child: CarouselSlider.builder(
                    itemCount: 3,
                    itemBuilder: (context , ind  , j){
                      return Container(
                        height: 250,
                        width: width - 100,
                        margin: EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 5.0),
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              offset: Offset(2, 2),
                              blurRadius: 9,
                              spreadRadius: 2,
                              color: Colors.grey.shade300,
                            ),
                            // BoxShadow(
                            //   offset: Offset(-1, -1),
                            //   blurRadius: 9,
                            //   spreadRadius: 2,
                            //   color: Colors.white,
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
                                    border:
                                        Border.all(color: ColorsUtil.borderclr),
                                    borderRadius: BorderRadius.circular(360),
                                  ),
                                  // padding: EdgeInsets.all(3),
                                  child: Center(
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.star,
                                          color: Colors.yellow,
                                          size: 15,
                                        ),
                                        Text(
                                          "4.2",
                                          style: theme.textTheme.bodySmall!
                                              .copyWith(
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
                            SizedBox(height: 9),
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
                            SizedBox(height: 15),
                            Divider(
                              color: Color(0xFFD9D9D9),
                            ),
                            SizedBox(height: 7),
                            Row(
                              children: [
                                Text(
                                  "Other skills",
                                  style: theme.textTheme.bodySmall!.copyWith(
                                      color: Color(0xFFBABABA), fontSize: 12),
                                ),
                              ],
                            ),
                            SizedBox(height: 7),
                            Row(
                              children: [
                                Container(
                                  height: 5,
                                  width: 5,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFBABABA),
                                  ),
                                ),
                                SizedBox(width: 7),
                                Text(
                                  "Web development",
                                  style: theme.textTheme.bodySmall!
                                      .copyWith(color: Color(0xFFBABABA)),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                  height: 5,
                                  width: 5,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFBABABA),
                                  ),
                                ),
                                SizedBox(width: 7),
                                Text(
                                  "java Scripting",
                                  style: theme.textTheme.bodySmall!
                                      .copyWith(color: Color(0xFFBABABA)),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                  height: 5,
                                  width: 5,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFBABABA),
                                  ),
                                ),
                                SizedBox(width: 7),
                                Text(
                                  "Green sock library",
                                  style: theme.textTheme.bodySmall!
                                      .copyWith(color: Color(0xFFBABABA)),
                                ),
                              ],
                            ),
                            Spacer(),
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
                      viewportFraction: 0.95,
                      autoPlay: true,
                      onPageChanged: (ind , reason){
                          setState(() {
                            curCardIndex = ind;
                          });
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(height: 28),
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
                        margin: EdgeInsets.only(right: 7),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: (curCardIndex == ind) ? ColorsUtil.primaryclr : Color(0xFFD9D9D9),
                        ),
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

