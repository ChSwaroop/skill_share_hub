import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:skill_share_hub/repo/agora_repo.dart';

enum CallStatus { idle, connecting, connected, disconnected }

class CallManagerProvider extends ChangeNotifier {
  // Agora engine instance
  RtcEngine? _engine;

  RtcEngine? get engine => _engine;

  // Call state
  CallStatus _status = CallStatus.idle;
  CallStatus get status => _status;

  // Channel info
  String? _channelName;
  String? _token;
  int? _uid;

  // Call settings
  bool _isVideoEnabled = true;
  bool _isAudioEnabled = true;
  bool _isSpeakerEnabled = true;

  // Remote users
  final List<int> _remoteUsers = [];
  List<int> get remoteUsers => _remoteUsers;

  // Getters
  bool get isVideoEnabled => _isVideoEnabled;
  bool get isAudioEnabled => _isAudioEnabled;
  bool get isSpeakerEnabled => _isSpeakerEnabled;

  // Initialize and join a call
  Future<void> initializeAndJoin({
    required String appId,
    required String channelName,
    required String token,
    int? uid,
    bool isVideo = true,
  }) async {
    // Reset state
    _remoteUsers.clear();
    _channelName = channelName;
    _token = token;
    _uid = uid ?? 0;
    _isVideoEnabled = isVideo;

    // Update status
    _status = CallStatus.connecting;
    notifyListeners();

    // Request permissions
    await _requestPermissions(isVideo);

    // Create RTC engine instance
    _engine = createAgoraRtcEngine();
    await _engine!.initialize(RtcEngineContext(appId: appId));

    // Register event handlers
    _registerEventHandlers();

    // Set channel profile and client role
    await _engine!
        .setChannelProfile(ChannelProfileType.channelProfileLiveBroadcasting);
    await _engine!.setClientRole(
        role: ClientRoleType.clientRoleBroadcaster); // changed by me

    // Enable video if needed
    if (isVideo) {
      await _engine!.enableVideo();
    } else {
      await _engine!.disableVideo();
    }

    // Join the channel
    await _engine!.joinChannel(
      token: token,
      channelId: channelName,
      uid: _uid!,
      options: const ChannelMediaOptions(),
    );
  }

  // Register event handlers
  void _registerEventHandlers() {
    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          _status = CallStatus.connected;
          notifyListeners();
        },
        onUserJoined: (connection, uid, elapsed) {
          if (!_remoteUsers.contains(uid)) {
            _remoteUsers.add(uid);
            notifyListeners();
          }
        },
        onUserOffline: (connection, uid, reason) {
          _remoteUsers.remove(uid);
          // For 1-to-1 calls, if the remote user leaves, end the call
          if (_remoteUsers.isEmpty && _channelName != null) {
            // Call leaveCall without backend notification since we're just responding
            // to the other user leaving
            leaveCall();

            // If this happens in a screen, you might want to pop back
            // This requires a BuildContext, so you might need a different approach
            // like using a callback or stream to notify screens
          }
          notifyListeners();
        },
        onTokenPrivilegeWillExpire: (connection, token) {
          // Token is about to expire, should request a new token
          // Implement token refresh logic here
        },
        onError: (err, msg) {
          // Handle errors
          debugPrint('Agora error: $err - $msg');
        },
      ),
    );
  }

  // Request necessary permissions
  Future<void> _requestPermissions(bool isVideo) async {
    await [
      Permission.microphone,
      if (isVideo) Permission.camera,
    ].request();
  }

  // Toggle camera
  Future<void> toggleCamera() async {
    if (_engine != null) {
      _isVideoEnabled = !_isVideoEnabled;

      if (_isVideoEnabled) {
        await _engine!.enableLocalVideo(true);
      } else {
        await _engine!.enableLocalVideo(false);
      }

      notifyListeners();
    }
  }

  // Toggle microphone
  Future<void> toggleMicrophone() async {
    if (_engine != null) {
      _isAudioEnabled = !_isAudioEnabled;
      await _engine!.muteLocalAudioStream(!_isAudioEnabled);
      notifyListeners();
    }
  }

  // Toggle speaker
  Future<void> toggleSpeaker() async {
    if (_engine != null) {
      _isSpeakerEnabled = !_isSpeakerEnabled;
      await _engine!.setEnableSpeakerphone(_isSpeakerEnabled);
      notifyListeners();
    }
  }

  // Switch camera
  Future<void> switchCamera() async {
    if (_engine != null && _isVideoEnabled) {
      await _engine!.switchCamera();
      notifyListeners();
    }
  }

  // Leave call
  // Future<void> leaveCall() async {
  //   if (_engine != null) {
  //     await _engine!.leaveChannel();
  //     _status = CallStatus.disconnected;
  //     _remoteUsers.clear();
  //     notifyListeners();

  //     // Destroy the engine instance
  //     await _engine!.release();
  //     _engine = null;

  //     // Reset state
  //     _status = CallStatus.idle;
  //     _channelName = null;
  //     _token = null;
  //     notifyListeners();
  //   }
  // }
  // In CallManagerProvider class
  Future<void> leaveCall({AgoraRepo? agoraRepo, String? userId}) async {
    if (_engine != null) {
      // Call the backend to end the call if agoraRepo and userId are provided
      if (agoraRepo != null && userId != null && _channelName != null) {
        await agoraRepo.endCall(
          channelName: _channelName!,
          userId: userId,
        );
      }

      await _engine!.leaveChannel();
      _status = CallStatus.disconnected;
      _remoteUsers.clear();
      notifyListeners();

      // Destroy the engine instance
      await _engine!.release();
      _engine = null;

      // Reset state
      _status = CallStatus.idle;
      _channelName = null;
      _token = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    leaveCall();
    super.dispose();
  }
}
