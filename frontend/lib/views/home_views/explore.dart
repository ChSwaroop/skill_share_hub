import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skill_share_hub/colors.dart';
import 'package:skill_share_hub/models/user_search_model.dart';
import 'package:skill_share_hub/providers/user_provider.dart';
import 'package:skill_share_hub/repo/connection_repo.dart';
import 'package:skill_share_hub/repo/search_repo.dart';
import 'package:skill_share_hub/views/util/custom_carousel_view.dart';
import 'package:skill_share_hub/views/util/shimmer_user.dart';

class Explore extends StatefulWidget {
  const Explore({super.key});

  @override
  State<Explore> createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  int curCardIndex = 0;
  List<User> searchResults = [];
  bool isSearching = false;

  Future<void> _performSearch(String query) async {
    setState(() {
      isSearching = true;
    });

    debugPrint("Searching for: $query");
    // Call your API service here
    final data = await UserService().searchUsersBySkill(
        query, Provider.of<UserProvider>(context, listen: false).token!);
    if (data != null && data.users != null) {
      setState(() {
        searchResults = data.users!;
      });
    }

    setState(() {
      isSearching = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _performSearch("flu");
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    TextEditingController search = TextEditingController();

    Timer? _debounceTimer;

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
                  Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: Image.network(
                        "https://img.freepik.com/premium-vector/conceptual-illustration-person-crossing-finish-line-with-determination_1263357-35011.jpg?ga=GA1.1.1483351532.1733847503&semt=ais_hybrid"),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              TextFormField(
                autofocus: true,
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
              (isSearching)
                  ? ShimmerUser()
                  : CustomUsersView(users: searchResults),
              const SizedBox(height: 44),
              // Text(
              //   "Recommended for you",
              //   style: theme.textTheme.bodyMedium!.copyWith(
              //     color: const Color(0xFF3D3D3D),
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              // const SizedBox(height: 16),
              // details_card(width, theme, searchResults),
            ],
          ),
        ),
      ),
    );
  }
}
