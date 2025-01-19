import 'package:flutter/material.dart';
import 'package:skill_share_hub/colors.dart';

class Chatbot extends StatefulWidget {
  const Chatbot({super.key});

  @override
  State<Chatbot> createState() => _ChatbotState();
}

class _ChatbotState extends State<Chatbot> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: ColorsUtil.bgclr,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: Text(
          "Help Bot !",
          style: theme.textTheme.bodyMedium!
              .copyWith(color: const Color(0xFF1E1E1E), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 25,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: height - 180,
                width: width,
                child: ListView.builder(
                  itemCount: 3,
                  itemBuilder: (context, ind) {
                    return Row(
                      mainAxisAlignment: (ind % 2 == 0)
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.end,
                      children: [
                        Stack(
                          alignment: const Alignment(-0.8, -1),
                          children: [
                            Container(
                              height: 85,
                              width: width / 1.5,
                              margin: const EdgeInsets.symmetric(vertical: 15),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: ColorsUtil.primaryclr,
                              ),
                              child: Center(
                                child: Text(
                                  "hi ! Im here to help. Could you tell me a bit about the skill share hub and the components",
                                  style: theme.textTheme.bodyLarge!
                                      .copyWith(color: Colors.white),
                                ),
                              ),
                            ),
                            Container(
                              height: 34,
                              width: 34,
                              decoration: const BoxDecoration(
                                color: ColorsUtil.primaryclr,
                                shape: BoxShape.circle,
                              ),
                              child: (ind % 2 == 0)
                                  ? Image.asset("assets/images/smallbot.png")
                                  : const SizedBox(),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
              Container(
                height: 54,
                width: width,
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: ColorsUtil.primaryclr),
                    borderRadius: BorderRadius.circular(40)),
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 39,
                      width: 49,
                      decoration: const BoxDecoration(
                        color: ColorsUtil.primaryclr,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Image.asset("assets/images/smallcam.png"),
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        style: theme.textTheme.bodyLarge!
                            .copyWith(color: Colors.black),
                        decoration: const InputDecoration(
                            contentPadding:
                                EdgeInsets.symmetric(vertical: 15.0),
                            hintText: "Type something...",
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none),
                        cursorColor: ColorsUtil.primaryclr,
                      ),
                    ),
                    Row(
                      children: [
                        Image.asset("assets/images/gallery.png"),
                        const SizedBox(width: 8),
                        Image.asset("assets/images/mic.png"),
                        const SizedBox(width: 8),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
