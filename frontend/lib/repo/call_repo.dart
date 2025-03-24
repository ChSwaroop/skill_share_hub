import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skill_share_hub/constants.dart';
import 'package:skill_share_hub/providers/call_manager_provider.dart';
import 'package:skill_share_hub/providers/user_provider.dart';
import 'package:skill_share_hub/repo/agora_repo.dart';
import 'package:skill_share_hub/views/call_views/audio_call.dart';
import 'package:skill_share_hub/views/call_views/video_call.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CallRepo {
  final AgoraRepo _agoraService;

  CallRepo({required AgoraRepo agoraService}) : _agoraService = agoraService;

  // Start a video call
  Future<void> startVideoCall({
    required BuildContext context,
    required List<String> participants,
    required String displayName,
  }) async {
    try {
      // Get channel name from backend
      final channelName = await _agoraService.startCall(
        currentUserId:
            Provider.of<UserProvider>(context, listen: false).user!.id!,
        callType: 'video',
        participants: participants,
      );

      // Navigate to video call screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider(
            create: (context) => CallManagerProvider(),
            child: VideoCallScreen(
              channelName: channelName,
              isVideo: true,
            ),
          ),
        ),
      );
    } catch (e) {
      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Call Error'),
          content: Text('Failed to start video call: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  // Start an audio call
  Future<void> startAudioCall({
    required BuildContext context,
    required List<String> participants,
    required String displayName,
  }) async {
    try {
      // Get channel name from backend
      final channelName = await _agoraService.startCall(
        currentUserId:
            Provider.of<UserProvider>(context, listen: false).user!.id!,
        callType: 'audio',
        participants: participants,
      );

      // Navigate to audio call screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider(
            create: (context) => CallManagerProvider(),
            child: AudioCallScreen(
              channelName: channelName,
              callerName: displayName,
            ),
          ),
        ),
      );
    } catch (e) {
      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Call Error'),
          content: Text('Failed to start audio call: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  // In CallRepo class
  Future<void> endCall({
    required BuildContext context,
    required String channelName,
  }) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final callManager =
          Provider.of<CallManagerProvider>(context, listen: false);

      // End call on backend
      await _agoraService.endCall(
        channelName: channelName,
        userId: userProvider.user!.id!,
      );

      // Leave call in Agora SDK
      await callManager.leaveCall();

      // Navigate back
      Navigator.of(context).pop();
    } catch (e) {
      print('Error ending call: $e');
      // Still try to leave call locally even if backend fails
      final callManager =
          Provider.of<CallManagerProvider>(context, listen: false);
      await callManager.leaveCall();
      Navigator.of(context).pop();
    }
  }
}
