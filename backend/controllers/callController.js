const Call = require('../models/Call');
const User = require('../models/user');
const { RtcTokenBuilder, RtcRole } = require('agora-access-token');
const dotenv = require('dotenv');

dotenv.config();

// Function to generate an Agora token
const generateAgoraToken = (channelName, uid) => {
  const appID = process.env.AGORA_APP_ID;
  const appCertificate = process.env.AGORA_APP_CERTIFICATE;
  const expirationTimeInSeconds = 3600; // Token valid for 1 hour
  const currentTimestamp = Math.floor(Date.now() / 1000);
  const privilegeExpiredTs = currentTimestamp + expirationTimeInSeconds;

  return RtcTokenBuilder.buildTokenWithUid(
    appID,
    appCertificate,
    channelName,
    uid,
    RtcRole.PUBLISHER,
    privilegeExpiredTs
  );
};

// Initiate a Call
exports.initiateCall = async (req, res) => {
  try {
    const { receiver, callType } = req.body; // callType can be "audio" or "video"
    const caller = req.user.userId;

    // Check if the receiver exists
    const receiverUser = await User.findById(receiver);
    if (!receiverUser) return res.status(404).json({ message: 'Receiver not found' });

    // Generate a unique channel name for each call
    const channelName = `call_${caller}_${receiver}_${Date.now()}`;
    
    // Generate Agora token for the call
    const token = generateAgoraToken(channelName, caller);

    // Create a new call entry with "initiated" status
    const call = new Call({
      caller,
      receiver,
      callType,
      channelName,
      status: 'initiated'
    });
    await call.save();

    res.status(201).json({ message: 'Call initiated successfully', call, token, channelName });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Accept a Call
exports.acceptCall = async (req, res) => {
  try {
    const { callId } = req.params;
    const call = await Call.findById(callId);

    // Ensure call exists and is in "initiated" status
    if (!call || call.status !== 'initiated') {
      return res.status(400).json({ message: 'Call not available to accept' });
    }

    // Generate Agora token for receiver
    const token = generateAgoraToken(call.channelName, call.receiver);

    call.status = 'accepted';
    call.acceptedAt = new Date();
    await call.save();

    res.json({ message: 'Call accepted', call, token });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

// End a Call
exports.endCall = async (req, res) => {
  try {
    const { callId } = req.params;
    const call = await Call.findById(callId);

    // Ensure call exists and has been accepted
    if (!call || call.status !== 'accepted') {
      return res.status(400).json({ message: 'Call not available to end' });
    }

    call.status = 'ended';
    call.endedAt = new Date();
    await call.save();

    res.json({ message: 'Call ended', call });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Get Call History
exports.getCallHistory = async (req, res) => {
  try {
    const userId = req.user.userId;

    // Fetch calls involving the user, either as caller or receiver
    const calls = await Call.find({
      $or: [{ caller: userId }, { receiver: userId }]
    }).sort({ initiatedAt: -1 }); // Sort by most recent calls first

    res.json(calls);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};
