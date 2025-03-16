import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skill_share_hub/colors.dart';
import 'package:skill_share_hub/models/user_search_model.dart';
import 'package:skill_share_hub/providers/user_provider.dart';
import 'package:skill_share_hub/repo/connection_repo.dart';
import 'package:skill_share_hub/repo/search_repo.dart';

class Explore extends StatefulWidget {
  const Explore({super.key});

  @override
  State<Explore> createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  int curCardIndex = 0;
  int curCardIndex2 = 0;
  List<User> searchResults = [];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    TextEditingController search = TextEditingController();

    Timer? _debounceTimer;

    Future<void> _performSearch(String query) async {
      debugPrint("Searching for: $query");
      // Call your API service here
      final data = await UserService().searchUsersBySkill(
          query, Provider.of<UserProvider>(context, listen: false).token!);
      if (data != null && data.users != null) {
        setState(() {
          searchResults = data.users!;
        });
      }
    }

    void _onSearchChanged(String query) {
      // Cancel previous timer if still running
      if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

      // Start a new timer
      _debounceTimer = Timer(Duration(milliseconds: 500), () {
        if (query.isNotEmpty) {
          _performSearch(query);
        }
      });
    }

    @override
    void dispose() {
      _debounceTimer?.cancel(); // Clean up the timer
      search.dispose();
      super.dispose();
    }

    return Scaffold(
      backgroundColor: ColorsUtil.bgclr,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 31.0, vertical: 40),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                decoration: const InputDecoration(
                    hintText: "search for a skill to learn..."),
                cursorColor: ColorsUtil.primaryclr,
                controller: search,
                onChanged: _onSearchChanged,
              ),
              // const SizedBox(height: 25),
              // const Row(
              //   children: [
              //     Icon(
              //       Icons.filter_alt_rounded,
              //       color: ColorsUtil.primaryclr,
              //     )
              //   ],
              // ),
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
              details_card(width, theme, searchResults),
              const SizedBox(height: 44),
              Text(
                "Recommended for you",
                style: theme.textTheme.bodyMedium!.copyWith(
                  color: const Color(0xFF3D3D3D),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              details_card(width, theme, searchResults),
            ],
          ),
        ),
      ),
    );
  }

  Column details_card(double width, ThemeData theme, List<User> searchResults) {
    return Column(
      children: [
        SizedBox(
          height: 270,
          width: width,
          child: Center(
            child: (searchResults.length == 0)
                ? Center(
                    child: Text(
                      "No users found with this skill",
                      style: theme.textTheme.titleMedium,
                    ),
                  )
                : CarouselSlider.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, ind, j) {
                      var skills = searchResults[ind].skills;
                      if (skills != null && skills.length > 3) {
                        skills = [skills[0], skills[1], skills[2]];
                      }

                      return Container(
                        height: 250,
                        width: width - 100,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 5.0),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
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
                                  height: 20,
                                  width: 38,
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: ColorsUtil.borderclr),
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
                                          style: theme.textTheme.bodySmall!
                                              .copyWith(
                                            fontSize: 11,
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
                                  searchResults[ind].firstName ??
                                      searchResults[ind].username ??
                                      "",
                                  style: theme.textTheme.titleMedium,
                                ),
                                (searchResults[ind].profilePicture != null &&
                                        searchResults[ind]
                                            .profilePicture!
                                            .isNotEmpty)
                                    ? Image.network(
                                        searchResults[ind].profilePicture!,
                                      )
                                    : Image.asset("assets/images/cardpic.png"),
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
                                  "skills",
                                  style: theme.textTheme.bodySmall!.copyWith(
                                      color:
                                          const Color.fromARGB(255, 62, 61, 61),
                                      fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 7),
                            (skills != null)
                                ? Column(
                                    children: [
                                      ...skills.map(
                                        (skill) => Row(
                                          children: [
                                            Container(
                                              height: 5,
                                              width: 5,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Color.fromARGB(
                                                    255, 62, 61, 61),
                                              ),
                                            ),
                                            const SizedBox(width: 7),
                                            Text(
                                              skill.name ?? "",
                                              style: theme.textTheme.bodySmall!
                                                  .copyWith(
                                                color: Color.fromARGB(
                                                    255, 62, 61, 61),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  )
                                : SizedBox(),
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
                                  onPressed: () async {
                                    final response =
                                        await ConnectionRepo().createConnection(
                                      recipientId: searchResults[ind].id!,
                                      authToken: Provider.of<UserProvider>(
                                              context,
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
                      enableInfiniteScroll: false,
                      height: 270,
                      viewportFraction: 0.95,
                      autoPlay: false,
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
              itemCount: searchResults.length,
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
