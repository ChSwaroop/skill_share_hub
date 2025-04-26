import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:skill_share_hub/colors.dart';
import 'package:skill_share_hub/constants.dart';
import 'package:skill_share_hub/providers/user_provider.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({Key? key}) : super(key: key);

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  int _satisfactionRating = 0;
  bool? _contentClear;
  bool? _topicsCovered;
  final TextEditingController _commentsController = TextEditingController();
  int _starRating = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  void _submitFeedback() async {
    if (_satisfactionRating == 0 ||
        _contentClear == null ||
        _topicsCovered == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final feedback = {
      'starRating': _starRating,
      'satisfactionRating': _satisfactionRating,
      'contentClear': _contentClear,
      'topicsCovered': _topicsCovered,
      'comments': _commentsController.text,
    };

    final authToken = Provider.of<UserProvider>(context, listen: false).token;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/feedback'),
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer $authToken",
        },
        body: jsonEncode(feedback),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feedback submitted successfully!')),
        );
        Navigator.pop(context);
      } else {
        debugPrint(response.body);
        throw Exception('Failed to submit feedback');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsUtil.bgclr,
      appBar: AppBar(
        backgroundColor: ColorsUtil.bgclr,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: ColorsUtil.textclr),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'App Feedback',
          style: TextStyle(
            color: ColorsUtil.textclr,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Center(
              child: const Text(
                'Give your awesome feedback',
                style: TextStyle(
                  color: ColorsUtil.textclr,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => GestureDetector(
                    onTap: () {
                      setState(() {
                        _starRating = index + 1;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Icon(
                        _starRating > index ? Icons.star : Icons.star_border,
                        color: _starRating > index
                            ? ColorsUtil.primaryclr
                            : ColorsUtil.borderclr,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildQuestionItem(
              'How satisfied were you with the overall app experience?',
              _buildSatisfactionRating(),
            ),
            const SizedBox(height: 24),
            _buildQuestionItem(
              'Was the app intuitive and easy to navigate?',
              _buildYesNoSelection(
                value: _contentClear,
                onChanged: (value) {
                  setState(() {
                    _contentClear = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 24),
            _buildQuestionItem(
              'Do you feel the app covered all necessary features?',
              _buildYesNoSelection(
                value: _topicsCovered,
                onChanged: (value) {
                  setState(() {
                    _topicsCovered = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Any additional comments?',
              style: TextStyle(
                fontSize: 14,
                color: ColorsUtil.textclr,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: ColorsUtil.borderclr),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                cursorColor: ColorsUtil.primaryclr,
                style: Theme.of(context).textTheme.bodyText1?.copyWith(
                      color: ColorsUtil.textclr,
                      fontSize: 14,
                    ),
                controller: _commentsController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Describe here',
                  hintStyle: TextStyle(color: ColorsUtil.secondarytxtclr),
                  contentPadding: EdgeInsets.all(16),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitFeedback,
                style: ElevatedButton.styleFrom(
                  primary: ColorsUtil.primaryclr,
                  onPrimary: ColorsUtil.btntxtclr,
                  minimumSize: const Size(120, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Submit'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionItem(String question, Widget selectionWidget) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(
            Icons.circle,
            size: 8,
            color: ColorsUtil.textclr,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                question,
                style: const TextStyle(
                  fontSize: 14,
                  color: ColorsUtil.textclr,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              selectionWidget,
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSatisfactionRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(
        5,
        (index) => GestureDetector(
          onTap: () {
            setState(() {
              _satisfactionRating = index + 1;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(right: 12),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _satisfactionRating == index + 1
                    ? ColorsUtil.primaryclr
                    : ColorsUtil.borderclr,
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: _satisfactionRating == index + 1
                      ? ColorsUtil.primaryclr
                      : ColorsUtil.secondarytxtclr,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildYesNoSelection({
    required bool? value,
    required Function(bool?) onChanged,
  }) {
    return Row(
      children: [
        _buildSelectionButton(
          label: 'Yes',
          isSelected: value == true,
          onTap: () => onChanged(true),
        ),
        const SizedBox(width: 12),
        _buildSelectionButton(
          label: 'No',
          isSelected: value == false,
          onTap: () => onChanged(false),
        ),
      ],
    );
  }

  Widget _buildSelectionButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? ColorsUtil.primaryclr : ColorsUtil.bgclr,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? ColorsUtil.primaryclr : ColorsUtil.borderclr,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? ColorsUtil.btntxtclr : ColorsUtil.textclr,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
