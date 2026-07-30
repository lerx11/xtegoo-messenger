import { AccessToken } from 'livekit-server-sdk';
import { config } from '../config';

export const generateLiveKitToken = async (
  roomName: string,
  participantName: string,
  userId: string
): Promise<string> => {
  const at = new AccessToken(config.livekit.apiKey, config.livekit.apiSecret, {
    identity: userId,
    name: participantName,
  });

  at.addGrant({
    roomJoin: true,
    room: roomName,
    canPublish: true,
    canSubscribe: true,
  });

  return await at.toJwt();
};
