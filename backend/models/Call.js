const mongoose = require('mongoose');
const { Schema } = mongoose;
// // const { RtcTokenBuilder, RtcRole } = require('agora-access-token');
// // const dotenv = require('dotenv');

// // dotenv.config();

// // // Define the Call schema
// // const callSchema = new Schema({
// //   caller: {
// //     type: mongoose.Schema.Types.ObjectId,
// //     ref: 'User',
// //     required: true
// //   },
// //   recipient: {
// //     type: mongoose.Schema.Types.ObjectId,
// //     ref: 'User',
// //     required: true
// //   },
// //   callType: {
// //     type: String,
// //     enum: ['audio', 'video'],
// //     required: true
// //   },
// //   startTime: {
// //     type: Date,
// //     default: Date.now
// //   },
// //   endTime: {
// //     type: Date
// //   },
// //   duration: {
// //     type: Number, // Duration in seconds
// //     default: 0
// //   },
// //   status: {
// //     type: String,
// //     enum: ['pending', 'ongoing', 'completed', 'missed'],
// //     default: 'pending'
// //   },
// //   channelName: {
// //     type: String
// //   },
// //   createdAt: {
// //     type: Date,
// //     default: Date.now
// //   },
// //   updatedAt: {
// //     type: Date,
// //     default: Date.now
// //   }
// // });

// // // Middleware to update the updatedAt field on save
// // callSchema.pre('save', function(next) {
// //   this.updatedAt = Date.now();
// //   next();
// // });

// // // Static method to generate Agora token
// // callSchema.statics.generateAgoraToken = function(channelName, userId) {
// //   const appID = process.env.AGORA_APP_ID;
// //   const appCertificate = process.env.AGORA_APP_CERTIFICATE;
// //   const expirationTimeInSeconds = 3600; // Token valid for 1 hour
// //   const currentTimestamp = Math.floor(Date.now() / 1000);
// //   const privilegeExpiredTs = currentTimestamp + expirationTimeInSeconds;

// //   // Generate the token with the user ID and channel name
// //   return RtcTokenBuilder.buildTokenWithUid(
// //     appID,
// //     appCertificate,
// //     channelName,
// //     userId,
// //     RtcRole.PUBLISHER,
// //     privilegeExpiredTs
// //   );
// // };

// // // Create the Call model
// // const Call = mongoose.model('Call', callSchema);

// // 


// // Call Schema to track active calls
// const callSchema = new mongoose.Schema({
//   channelName: { type: String, required: true, unique: true },
//   callType: { type: String, required: true }, // 'audio' or 'video'
//   initiator: { type: String, required: true }, // userId of the caller
//   participants: [{ type: String }], // array of userIds
//   startTime: { type: Date, default: Date.now },
//   active: { type: Boolean, default: true }
// });

const callSchema = new mongoose.Schema({
  channelName: String,
  callType: { type: String, enum: ['audio', 'video'], required: true },
  initiator: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  participants: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  fcmTokens: [String], // Store tokens for push notifications
  rtcToken: String, // Optional - to store generated RTC token
  startTime: { type: Date, default: Date.now },
  endTime: Date,
  duration: Number,
  active: { type: Boolean, default: true },
  status: { type: String, enum: ['initiated', 'ongoing', 'ended', 'missed'], default: 'initiated' },
  callEndReason: { type: String, enum: ['completed', 'missed', 'rejected', 'network_failure'], default: null }
});


const Call = mongoose.model('Call', callSchema);

module.exports = Call;