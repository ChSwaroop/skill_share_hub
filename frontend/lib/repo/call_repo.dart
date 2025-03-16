import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skill_share_hub/providers/call_manager_provider.dart';
import 'package:skill_share_hub/repo/agora_repo.dart';
import 'package:skill_share_hub/views/call_views/audio_call.dart';
import 'package:skill_share_hub/views/call_views/video_call.dart';

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
}
