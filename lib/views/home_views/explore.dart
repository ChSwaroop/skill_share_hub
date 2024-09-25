import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:skill_share_hub/colors.dart';

class Explore extends StatefulWidget {
  const Explore({super.key});

  @override
  State<Explore> createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  int curCardIndex = 0;
  int curCardIndex2 = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: ColorsUtil.bgclr,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 31.0, vertical: 40),
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
                  Image.asset("assets/images/icon.png"),
                  Image.asset("assets/images/profile-pic1.png"),
                ],
              ),
              const SizedBox(height: 25),
              TextFormField(
                style: theme.textTheme.bodyLarge!.copyWith(color: Colors.black),
                decoration: const InputDecoration(hintText: "search for a person..."),
                cursorColor: ColorsUtil.primaryclr,
              ),
              const SizedBox(height: 25),
              const Row(
                children: [
                  Icon(
                    Icons.filter_alt_rounded,
                    color: ColorsUtil.primaryclr,
                  )
                ],
              ),
              const SizedBox(
                height: 40,
              ),
              Text(
                "Most popular people to connect!",
                style: theme.textTheme.bodyMedium!.copyWith(
                  color: const Color(0xFF3D3D3D),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              details_card(width, theme),
              const SizedBox(height: 44),
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
                  margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(2, 2),
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
                viewportFraction: 0.95,
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
      ],
    );
  }
}
