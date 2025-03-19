import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skill_share_hub/constants.dart';
import 'package:skill_share_hub/providers/call_manager_provider.dart';
import 'dart:async';

import 'package:skill_share_hub/repo/agora_repo.dart';

class AudioCallScreen extends StatefulWidget {
  final String channelName;
  final String callerName;

  const AudioCallScreen({
    Key? key,
    required this.channelName,
    required this.callerName,
  }) : super(key: key);

  @override
  State<AudioCallScreen> createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen> {
  final String appId = '480789d02efd459dac0bce47c214df3e';
  bool _isLoading = true;
  String? _errorMessage;
  final AgoraRepo _agoraService = AgoraRepo(baseUrl: baseUrl);

  // Call duration tracking
  final Stopwatch _stopwatch = Stopwatch();
  late Timer _timer;
  String _duration = '00:00';

  @override
  void initState() {
    super.initState();
    debugPrint(
        "IN audio call page : " + widget.callerName + " " + widget.channelName);
    _initializeCall();

    // Setup timer for call duration
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_stopwatch.isRunning) {
        final int seconds = _stopwatch.elapsed.inSeconds;
        final int minutes = seconds ~/ 60;
        final int remainingSeconds = seconds % 60;

        setState(() {
          _duration =
              '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _stopwatch.stop();
    super.dispose();
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

      // Initialize and join channel (audio only)
      await callManager.initializeAndJoin(
        appId: appId,
        channelName: widget.channelName,
        token: tokenData['token'],
        uid: tokenData['uid'],
        isVideo: false, // Audio only
      );

      if (mounted) {
        setState(() => _isLoading = false);
        _stopwatch.start();
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
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (_errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Failed to connect call',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
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

          return SafeArea(
            child: Column(
              children: [
                // Top section - caller info
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60),
                      CircleAvatar(
                        radius: 70,
                        backgroundColor: Colors.blue.shade300,
                        child: const Icon(
                          Icons.person,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        widget.callerName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        callManager.status == CallStatus.connected
                            ? _duration
                            : 'Connecting...',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 40),
                      if (callManager.remoteUsers.isNotEmpty)
                        const Text(
                          'Connected',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 16,
                          ),
                        ),
                    ],
                  ),
                ),

                // Bottom section - call controls
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Speaker toggle
                            _buildRoundButton(
                              icon: callManager.isSpeakerEnabled
                                  ? Icons.volume_up
                                  : Icons.volume_off,
                              label: 'Speaker',
                              onPressed: callManager.toggleSpeaker,
                              active: callManager.isSpeakerEnabled,
                            ),

                            // Microphone toggle
                            _buildRoundButton(
                              icon: callManager.isAudioEnabled
                                  ? Icons.mic
                                  : Icons.mic_off,
                              label: 'Mute',
                              onPressed: callManager.toggleMicrophone,
                              active: callManager.isAudioEnabled,
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        // End call button
                        GestureDetector(
                          onTap: () {
                            callManager.leaveCall();
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.call_end,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoundButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool active,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: active ? Colors.blue.shade600 : Colors.grey.shade800,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
