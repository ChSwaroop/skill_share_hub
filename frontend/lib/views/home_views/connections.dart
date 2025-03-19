import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skill_share_hub/colors.dart';

import 'package:skill_share_hub/models/connection_model.dart';
import 'package:skill_share_hub/providers/user_provider.dart';
import 'package:skill_share_hub/repo/connection_repo.dart';

class ConnectionsPage extends StatefulWidget {
  final String authToken;

  ConnectionsPage({required this.authToken});

  @override
  _ConnectionsPageState createState() => _ConnectionsPageState();
}

class _ConnectionsPageState extends State<ConnectionsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Datum> _connections = [];
  List<Datum> _pendingConnections = [];
  int _connectionsPage = 1;
  int _pendingConnectionsPage = 1;
  bool _isLoadingConnections = false;
  bool _isLoadingPendingConnections = false;
  bool _hasMoreConnections = true;
  bool _hasMorePendingConnections = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadConnections();
    _loadPendingConnections();
  }

  Future<void> _loadConnections() async {
    if (_isLoadingConnections || !_hasMoreConnections) return;
    setState(() {
      _isLoadingConnections = true;
    });

    try {
      final Connection connectionData = await ConnectionRepo()
          .getMyConnections('accepted', _connectionsPage, 20, widget.authToken);

      if (connectionData.success == true && connectionData.data != null) {
        setState(() {
          _connections.addAll(connectionData.data!);
          _connectionsPage++;
          if (connectionData.data!.length < 20) {
            _hasMoreConnections = false;
          }
        });
      } else {
        print('API Error: ${connectionData.toString()}');
      }
    } catch (e) {
      print('Error loading connections: $e');
    } finally {
      setState(() {
        _isLoadingConnections = false;
      });
    }
  }

  Future<void> _loadPendingConnections() async {
    if (_isLoadingPendingConnections || !_hasMorePendingConnections) return;
    setState(() {
      _isLoadingPendingConnections = true;
    });

    try {
      final Connection connectionData = await ConnectionRepo().getMyConnections(
          'pending', _pendingConnectionsPage, 20, widget.authToken);

      if (connectionData.success == true && connectionData.data != null) {
        setState(() {
          _pendingConnections.addAll(connectionData.data!);
          _pendingConnectionsPage++;
          if (connectionData.data!.length < 20) {
            _hasMorePendingConnections = false;
          }
        });
      } else {
        print('API Error: ${connectionData.toString()}');
      }
    } catch (e) {
      print('Error loading pending connections: $e');
    } finally {
      setState(() {
        _isLoadingPendingConnections = false;
      });
    }
  }

  Future<void> _cancelRequest(String connectionId) async {
    try {
      // Call the API to cancel the request
      await ConnectionRepo().updateConnectionStatus(
        connectionId,
        'cancelled',
        widget.authToken,
      );
      // After successful cancellation, remove the item from _pendingConnections
      setState(() {
        _pendingConnections.removeWhere((item) => item.id == connectionId);
      });
    } catch (e) {
      print('Error cancelling request: $e');
      // Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to cancel request. Please try again.')),
      );
    }
  }

  Future<void> _removeConnection(String connectionId) async {
    try {
      // Show confirmation dialog
      final bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Remove Connection'),
            content: Text('Are you sure you want to remove this connection?'),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: Text('Remove', style: TextStyle(color: Colors.red)),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          );
        },
      );

      if (confirmed != true) return;

      // Call the API to delete the connection
      await ConnectionRepo().deleteConnection(
        connectionId,
        widget.authToken,
      );

      // After successful deletion, remove the item from _connections
      setState(() {
        _connections.removeWhere((item) => item.id == connectionId);
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection removed successfully')),
      );
    } catch (e) {
      print('Error removing connection: $e');
      // Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to remove connection. Please try again.')),
      );
    }
  }

  Future<void> _respondToRequest(String connectionId, String status) async {
    try {
      // Call the API to update connection status (accept/reject)
      await ConnectionRepo().updateConnectionStatus(
        connectionId,
        status,
        widget.authToken,
      );

      // After successful update, refresh the lists accordingly
      if (status == 'accepted') {
        // Reload both lists
        setState(() {
          _connections = [];
          _pendingConnections = [];
          _connectionsPage = 1;
          _pendingConnectionsPage = 1;
          _hasMoreConnections = true;
          _hasMorePendingConnections = true;
        });
        _loadConnections();
        _loadPendingConnections();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connection request accepted')),
        );
      } else {
        // Just remove from pending
        setState(() {
          _pendingConnections.removeWhere((item) => item.id == connectionId);
        });

        // Show rejection message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connection request rejected')),
        );
      }
    } catch (e) {
      print('Error responding to request: $e');
      // Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to respond to request. Please try again.')),
      );
    }
  }

  void _showResponseDialog(String connectionId, String username) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Connection Request'),
          content: Text(
              '$username wants to connect with you. What would you like to do?'),
          actions: [
            TextButton(
              child: Text('Reject', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _respondToRequest(connectionId, 'rejected');
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsUtil.primaryclr,
              ),
              child: Text(
                'Accept',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _respondToRequest(connectionId, 'accepted');
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String userId = Provider.of<UserProvider>(context).user!.id!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Connections'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: ColorsUtil.primaryclr,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            color: ColorsUtil.primaryclr,
            borderRadius: BorderRadius.circular(10),
          ),
          labelStyle: theme.textTheme.bodyMedium!.copyWith(
            color: Colors.white,
          ),
          unselectedLabelStyle: theme.textTheme.bodyMedium!.copyWith(
            color: ColorsUtil.primaryclr,
          ),
          tabs: [
            Tab(text: 'Connections'),
            Tab(text: 'Pending'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildConnectionsList(
            _connections,
            _loadConnections,
            _removeConnection,
            _isLoadingConnections,
            _hasMoreConnections,
            userId,
            isAccepted: true,
          ),
          _buildPendingConnectionsList(
            _pendingConnections,
            _loadPendingConnections,
            _isLoadingPendingConnections,
            _hasMorePendingConnections,
            userId,
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionsList(List<Datum> connections, Function loadMore,
      Function removeAction, bool isLoading, bool hasMore, String userId,
      {required bool isAccepted}) {
    return connections.isEmpty && !isLoading
        ? Center(child: Text('No connections yet'))
        : ListView.builder(
            itemCount: connections.length + (hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < connections.length) {
                final connection = connections[index];
                final isCurrentUserRequester =
                    connection.requesterId?.id == userId;

                // Determine which user to display
                final displayUser = isCurrentUserRequester
                    ? connection.recipientId
                    : connection.requesterId;

                return ListTile(
                  leading: (displayUser?.profilePicture != null &&
                          displayUser!.profilePicture!.isNotEmpty)
                      ? CircleAvatar(
                          backgroundImage:
                              NetworkImage(displayUser.profilePicture!),
                        )
                      : Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(360),
                            color: Colors.grey.shade300,
                          ),
                          child: Icon(Icons.account_circle, size: 40),
                        ),
                  title: Text(displayUser?.username ?? 'Unknown'),
                  subtitle: Text('Connected'),
                  trailing: IconButton(
                    icon: Icon(Icons.person_remove),
                    onPressed: () => removeAction(connection.id),
                    tooltip: 'Remove connection',
                  ),
                );
              } else if (hasMore && index == connections.length) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: isLoading
                        ? _buildShimmer()
                        : TextButton(
                            onPressed: loadMore as void Function()?,
                            child: Text('View More'),
                          ),
                  ),
                );
              }
              return Container();
            },
          );
  }

  Widget _buildPendingConnectionsList(List<Datum> pendingConnections,
      Function loadMore, bool isLoading, bool hasMore, String userId) {
    return pendingConnections.isEmpty && !isLoading
        ? Center(child: Text('No pending requests'))
        : ListView.builder(
            itemCount: pendingConnections.length + (hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < pendingConnections.length) {
                final connection = pendingConnections[index];
                final isCurrentUserRequester =
                    connection.requesterId?.id == userId;

                // Determine which user to display
                final displayUser = isCurrentUserRequester
                    ? connection.recipientId
                    : connection.requesterId;

                return ListTile(
                  leading: (displayUser?.profilePicture != null &&
                          displayUser!.profilePicture!.isNotEmpty)
                      ? CircleAvatar(
                          backgroundImage:
                              NetworkImage(displayUser.profilePicture!),
                        )
                      : Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(360),
                            color: Colors.grey.shade300,
                          ),
                          child: Icon(Icons.account_circle, size: 40),
                        ),
                  title: Text(displayUser?.username ?? 'Unknown'),
                  subtitle: Text(isCurrentUserRequester
                      ? 'Request sent by you'
                      : 'Request received'),
                  trailing: isCurrentUserRequester
                      // I sent the request - show cancel button
                      ? IconButton(
                          icon: Icon(Icons.cancel, color: Colors.red),
                          onPressed: () => _cancelRequest(connection.id!),
                          tooltip: 'Cancel request',
                        )
                      // Someone sent me a request - show respond options
                      : TextButton(
                          child: Text('Respond',
                              style: TextStyle(color: ColorsUtil.primaryclr)),
                          onPressed: () => _showResponseDialog(
                            connection.id!,
                            displayUser?.username ?? 'Unknown user',
                          ),
                        ),
                );
              } else if (hasMore && index == pendingConnections.length) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: isLoading
                        ? _buildShimmer()
                        : TextButton(
                            onPressed: loadMore as void Function()?,
                            child: Text('View More'),
                          ),
                  ),
                );
              }
              return Container();
            },
          );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListTile(
        leading: CircleAvatar(backgroundColor: Colors.white),
        title: Container(
            width: double.infinity, height: 10.0, color: Colors.white),
        subtitle: Container(
            width: double.infinity, height: 10.0, color: Colors.white),
      ),
    );
  }
}
