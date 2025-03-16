import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:skill_share_hub/constants.dart';
import 'package:skill_share_hub/providers/call_manager_provider.dart';
import 'dart:async';

import 'package:skill_share_hub/repo/agora_repo.dart';

class VideoCallScreen extends StatefulWidget {
  final String channelName;
  final bool isVideo;

  const VideoCallScreen({
    Key? key,
    required this.channelName,
    this.isVideo = true,
  }) : super(key: key);

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final String appId = '480789d02efd459dac0bce47c214df3e';
  bool _isLoading = true;
  String? _errorMessage;
  final AgoraRepo _agoraService = AgoraRepo(baseUrl: baseUrl);

  @override
  void initState() {
    super.initState();
    _initializeCall();
  }

  Future<void> _initializeCall() async {
    try {
      // Get call manager
      final callManager =
          Provider.of<CallManagerProvider>(context, listen: false);

      // Generate token from backend
      final tokenData = await _agoraService.generateToken(
        channelName: widget.channelName,
      );

      // Initialize and join channel
      await callManager.initializeAndJoin(
        appId: appId,
        channelName: widget.channelName,
        token: tokenData['token'],
        uid: tokenData['uid'],
        isVideo: widget.isVideo,
      );

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<CallManagerProvider>(
        builder: (context, callManager, _) {
          if (_isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (_errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Failed to join call',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              // Remote video views
              callManager.remoteUsers.isEmpty
                  ? Center(
                      child: Text(
                        'Waiting for others to join...',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    )
                  : _buildRemoteVideoViews(callManager),

              // Local video view (small picture-in-picture)
              Positioned(
                right: 16,
                top: 60,
                child: widget.isVideo && callManager.isVideoEnabled
                    ? Container(
                        width: 120,
                        height: 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: AgoraVideoView(
                            controller: VideoViewController(
                              rtcEngine: callManager.engine!,
                              canvas: const VideoCanvas(uid: 0),
                            ),
                          ),
                        ),
                      )
                    : const SizedBox(),
              ),

              // Call controls
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: _buildCallControls(callManager),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRemoteVideoViews(CallManagerProvider callManager) {
    // Single remote user - full screen
    if (callManager.remoteUsers.length == 1) {
      return Center(
        child: widget.isVideo
            ? AgoraVideoView(
                controller: VideoViewController.remote(
                  rtcEngine: callManager.engine!,
                  canvas: VideoCanvas(uid: callManager.remoteUsers[0]),
                  connection: RtcConnection(channelId: widget.channelName),
                ),
              )
            : _buildAudioOnlyView(callManager.remoteUsers[0]),
      );
    }

    // Multiple remote users - grid layout
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: callManager.remoteUsers.length > 4 ? 3 : 2,
        childAspectRatio: 3 / 4,
      ),
      itemCount: callManager.remoteUsers.length,
      itemBuilder: (context, index) {
        final uid = callManager.remoteUsers[index];
        return Padding(
          padding: const EdgeInsets.all(2),
          child: widget.isVideo
              ? AgoraVideoView(
                  controller: VideoViewController.remote(
                    rtcEngine: callManager.engine!,
                    canvas: VideoCanvas(uid: uid),
                    connection: RtcConnection(channelId: widget.channelName),
                  ),
                )
              : _buildAudioOnlyView(uid),
        );
      },
    );
  }

  Widget _buildAudioOnlyView(int uid) {
    return Container(
      color: Colors.blueGrey,
      child: Center(
        child: CircleAvatar(
          radius: 50,
          backgroundColor: Colors.blue.shade300,
          child: Icon(
            Icons.person,
            size: 60,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildCallControls(CallManagerProvider callManager) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: Colors.black54,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Microphone toggle
          _buildControlButton(
            icon: callManager.isAudioEnabled ? Icons.mic : Icons.mic_off,
            color: callManager.isAudioEnabled ? Colors.white : Colors.red,
            onPressed: callManager.toggleMicrophone,
          ),

          // End call
          _buildControlButton(
            icon: Icons.call_end,
            color: Colors.red,
            onPressed: () {
              callManager.leaveCall();
              Navigator.pop(context);
            },
            isEndCall: true,
          ),

          // Camera toggle (for video calls)
          if (widget.isVideo)
            _buildControlButton(
              icon: callManager.isVideoEnabled
                  ? Icons.videocam
                  : Icons.videocam_off,
              color: callManager.isVideoEnabled ? Colors.white : Colors.red,
              onPressed: callManager.toggleCamera,
            ),

          // Speaker toggle
          _buildControlButton(
            icon: callManager.isSpeakerEnabled
                ? Icons.volume_up
                : Icons.volume_off,
            color: callManager.isSpeakerEnabled ? Colors.white : Colors.red,
            onPressed: callManager.toggleSpeaker,
          ),

          // Switch camera (for video calls)
          if (widget.isVideo)
            _buildControlButton(
              icon: Icons.flip_camera_ios,
              color: Colors.white,
              onPressed: callManager.switchCamera,
            ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    bool isEndCall = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isEndCall ? Colors.red : Colors.black45,
      ),
      child: IconButton(
        icon: Icon(icon),
        color: color,
        iconSize: isEndCall ? 32 : 28,
        onPressed: onPressed,
      ),
    );
  }
}
