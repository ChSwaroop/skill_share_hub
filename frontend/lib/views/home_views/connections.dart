import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import 'package:skill_share_hub/models/connection_model.dart';
import 'package:skill_share_hub/providers/user_provider.dart';
import 'package:skill_share_hub/repo/connection_repo.dart';

// Your Connection model (as provided in your question)

// ... (Connection, Datum, Id classes) ...

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
    // Implement your API call to cancel the request here
    print('Cancel request for connection ID: $connectionId');
    // After successful cancellation, remove the item from _pendingConnections
    setState(() {
      _pendingConnections.removeWhere((item) => item.id == connectionId);
    });
  }

  Future<void> _removeConnection(String connectionId) async {
    // Implement your API call to remove the connection here
    print('Remove connection for connection ID: $connectionId');
    // After successful removal, remove the item from _connections
    setState(() {
      _connections.removeWhere((item) => item.id == connectionId);
    });
  }

  @override
  Widget build(BuildContext context) {
    String userId = Provider.of<UserProvider>(context).user!.id!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Connections'),
        bottom: TabBar(
          controller: _tabController,
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
              userId),
          _buildConnectionsList(
              _pendingConnections,
              _loadPendingConnections,
              _cancelRequest,
              _isLoadingPendingConnections,
              _hasMorePendingConnections,
              userId),
        ],
      ),
    );
  }

  Widget _buildConnectionsList(List<Datum> connections, Function loadMore,
      Function action, bool isLoading, bool hasMore, String userId) {
    return ListView.builder(
      itemCount: connections.length + (hasMore ? 1 : 10), //add 10 for shimmer
      itemBuilder: (context, index) {
        if (index < connections.length) {
          final connection = connections[index];
          return ListTile(
            leading: (connection.recipientId?.profilePicture != null &&
                    connection.recipientId!.profilePicture!.isNotEmpty)
                ? CircleAvatar(
                    radius: 50,
                    backgroundImage: connection.requesterId?.id == userId
                        ? (connection.recipientId?.profilePicture != null &&
                                connection
                                    .recipientId!.profilePicture!.isNotEmpty)
                            ? NetworkImage(
                                connection.recipientId!.profilePicture!)
                            : null
                        : (connection.recipientId?.profilePicture != null &&
                                connection
                                    .recipientId!.profilePicture!.isNotEmpty)
                            ? NetworkImage(
                                connection.requesterId!.profilePicture!)
                            : null,
                  )
                : Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(360),
                      color: Colors.grey.shade300,
                    ),
                    child: Icon(Icons.account_circle, size: 50),
                  ),
            title: Text(connection.requesterId?.id == userId
                ? connection.recipientId?.username ?? 'Unknown'
                : connection.requesterId?.username ?? 'Unknown'),
            subtitle: Text(connection.status ?? ''),
            trailing: IconButton(
              icon: Icon(connections == _connections
                  ? Icons.person_remove
                  : Icons.cancel),
              onPressed: () => action(connection.id),
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
        } else if (isLoading) {
          return _buildShimmer();
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
