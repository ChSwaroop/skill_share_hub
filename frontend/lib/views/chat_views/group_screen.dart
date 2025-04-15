import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skill_share_hub/colors.dart';
import 'package:skill_share_hub/models/connection_model.dart';
import 'package:skill_share_hub/providers/chat_provider.dart';
import 'package:skill_share_hub/providers/user_provider.dart';
import 'package:skill_share_hub/models/login_model.dart';
import 'package:skill_share_hub/repo/connection_repo.dart';

class CreateGroupChatScreen extends StatefulWidget {
  const CreateGroupChatScreen({Key? key}) : super(key: key);

  @override
  _CreateGroupChatScreenState createState() => _CreateGroupChatScreenState();
}

class _CreateGroupChatScreenState extends State<CreateGroupChatScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  List<Datum> _availableContacts = [];
  List<Datum> _selectedContacts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  void _loadContacts() async {
    setState(() {
      _isLoading = true;
    });

    // Get current user connections from the UserProvider
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.user != null && userProvider.user!.connections != null) {
      // Fetch full user details for each connection
      // In a real app, you might want to fetch these from your backend
      // _availableContacts = userProvider.connections;
      try {
        final Connection connectionData = await ConnectionRepo()
            .getMyConnections('accepted', 1, 20, userProvider.token!);

        if (connectionData.success == true && connectionData.data != null) {
          debugPrint("connections: ${connectionData.data![0].status}");
          setState(() {
            _availableContacts.addAll(connectionData.data!);
            // _connectionsPage++;
            // if (connectionData.data!.length < 20) {
            //   _hasMoreConnections = false;
            // }
          });
        } else {
          print('API Error: ${connectionData.toString()}');
        }
      } catch (e) {
        print('Error loading connections: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _toggleContactSelection(Datum contact) {
    setState(() {
      if (_selectedContacts.any((user) => user.id == contact.id)) {
        _selectedContacts.removeWhere((user) => user.id == contact.id);
      } else {
        _selectedContacts.add(contact);
      }
    });
  }

  void _createGroupChat() {
    final groupName = _groupNameController.text.trim();
    if (groupName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a group name')),
      );
      return;
    }

    if (_selectedContacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select at least one contact')),
      );
      return;
    }

    String userId = Provider.of<UserProvider>(context, listen: false).user!.id!;

    // Get participantIds from selected contacts
    final List<String> participantIds = _selectedContacts.map((contact) {
      final connection = contact;
      final isCurrentUserRequester = connection.requesterId?.id == userId;

      // Determine which user to display
      final displayUser = isCurrentUserRequester
          ? connection.recipientId
          : connection.requesterId;
      return displayUser!.id!;
    }).toList();

    // Create the group chat using the provider
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.createGroupChat(groupName, participantIds);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Creating group chat...')),
    );

    // Navigate back to the chats list
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Group Chat'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _selectedContacts.isNotEmpty ? _createGroupChat : null,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Group name input
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    style: theme.textTheme.bodyLarge!
                        .copyWith(color: Colors.black),
                    cursorColor: ColorsUtil.primaryclr,
                    controller: _groupNameController,
                    decoration: InputDecoration(
                      labelText: 'Group Name',
                      hintText: 'Enter a name for your group',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.group),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                ),

                // Selected contacts counter
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Text(
                        'Selected Contacts: ${_selectedContacts.length}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ColorsUtil.primaryclr,
                        ),
                      ),
                      Spacer(),
                      if (_selectedContacts.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedContacts.clear();
                            });
                          },
                          child: Text('Clear All'),
                        ),
                    ],
                  ),
                ),

                // Selected contacts chips
                if (_selectedContacts.isNotEmpty)
                  Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedContacts.length,
                      itemBuilder: (context, index) {
                        String userId =
                            Provider.of<UserProvider>(context, listen: false)
                                .user!
                                .id!;
                        // final contact = _selectedContacts[index];
                        final connection = _selectedContacts[index];
                        final isCurrentUserRequester =
                            connection.requesterId?.id == userId;

                        // Determine which user to display
                        final displayUser = isCurrentUserRequester
                            ? connection.recipientId
                            : connection.requesterId;
                        final contact = displayUser;

                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Chip(
                            avatar: CircleAvatar(
                              backgroundImage: (contact!.profilePicture !=
                                          null &&
                                      contact.profilePicture!.isNotEmpty)
                                  ? NetworkImage(contact.profilePicture!)
                                  : NetworkImage(
                                      "https://img.freepik.com/premium-vector/conceptual-illustration-person-crossing-finish-line-with-determination_1263357-35011.jpg?ga=GA1.1.1483351532.1733847503&semt=ais_hybrid"),
                              child: (contact.profilePicture == null ||
                                      contact.profilePicture!.isEmpty)
                                  ? null // No need for text initials when using fallback image
                                  : null,
                            ),
                            label: Text(contact.username ?? ''),
                            onDeleted: () {
                              _toggleContactSelection(connection);
                            },
                          ),
                        );
                      },
                    ),
                  ),

                Divider(),

                // Available contacts list
                Expanded(
                  child: _availableContacts.isEmpty
                      ? Center(child: Text('No contacts available'))
                      : ListView.builder(
                          itemCount: _availableContacts.length,
                          itemBuilder: (context, index) {
                            String userId = Provider.of<UserProvider>(context,
                                    listen: false)
                                .user!
                                .id!;
                            // final contact = _selectedContacts[index];
                            final connection = _availableContacts[index];
                            final isCurrentUserRequester =
                                connection.requesterId?.id == userId;

                            // Determine which user to display
                            final displayUser = isCurrentUserRequester
                                ? connection.recipientId
                                : connection.requesterId;
                            final contact = displayUser;

                            final isSelected = _selectedContacts
                                .any((user) => user.id == connection.id);

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: (contact!.profilePicture !=
                                            null &&
                                        contact.profilePicture!.isNotEmpty)
                                    ? NetworkImage(contact.profilePicture!)
                                    : NetworkImage(
                                        "https://img.freepik.com/premium-vector/conceptual-illustration-person-crossing-finish-line-with-determination_1263357-35011.jpg?ga=GA1.1.1483351532.1733847503&semt=ais_hybrid"),
                                child: (contact.profilePicture == null ||
                                        contact.profilePicture!.isEmpty)
                                    ? null // No need for text initials when using fallback image
                                    : null,
                              ),
                              title: Text(contact.username ?? ''),
                              subtitle: Text(contact.username ?? ''),
                              trailing: Checkbox(
                                activeColor: ColorsUtil.primaryclr,
                                value: isSelected,
                                onChanged: (_) {
                                  _toggleContactSelection(connection);
                                },
                              ),
                              onTap: () {
                                _toggleContactSelection(connection);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
