import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skill_share_hub/colors.dart';
import 'package:skill_share_hub/models/user_search_model.dart';
import 'package:skill_share_hub/providers/user_provider.dart';
import 'package:skill_share_hub/repo/connection_repo.dart';

class CustomUsersView extends StatefulWidget {
  final List<User> users;
  const CustomUsersView({required this.users, super.key});

  @override
  State<CustomUsersView> createState() => _CustomUsersViewState();
}

class _CustomUsersViewState extends State<CustomUsersView> {
  int curCardIndex = 0;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    return Column(
      children: [
        SizedBox(
          height: 270,
          width: width,
          child: Center(
            child: (widget.users.length == 0)
                ? Center(
                    child: Text(
                      "No users found with this skill",
                      style: theme.textTheme.titleMedium,
                    ),
                  )
                : CarouselSlider.builder(
                    itemCount: widget.users.length,
                    itemBuilder: (context, ind, j) {
                      var skills = widget.users[ind].skills;
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
                                  widget.users[ind].firstName ??
                                      widget.users[ind].username ??
                                      "",
                                  style: theme.textTheme.titleMedium,
                                ),
                                Container(
                                  height: 50,
                                  width: 50,
                                  child: (widget.users[ind].profilePicture !=
                                              null &&
                                          widget.users[ind].profilePicture!
                                              .isNotEmpty)
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(360),
                                          child: Image.network(
                                            widget.users[ind].profilePicture!,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Image.asset(
                                          "assets/images/cardpic.png"),
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
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // ElevatedButton(
                                //   style: ElevatedButton.styleFrom(
                                //       fixedSize: Size((width - 150) / 2, 30),
                                //       backgroundColor: Colors.white),
                                //   onPressed: () {},
                                //   child: Text(
                                //     "Know more",
                                //     style: theme.textTheme.titleMedium!
                                //         .copyWith(color: ColorsUtil.primaryclr),
                                //   ),
                                // ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    fixedSize: Size((width - 150) / 2, 30),
                                  ),
                                  onPressed: () async {
                                    final response =
                                        await ConnectionRepo().createConnection(
                                      widget.users[ind].id!,
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
              itemCount: widget.users.length,
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
