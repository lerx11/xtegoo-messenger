import { AccessToken } from 'livekit-server-sdk';
import { config } from '../config';

// Генерация токена для комнаты LiveKit
export const generateLiveKitToken = (
  roomName: string,
  participantName: string,
  userId: string
): string => {
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

  return at.toJwt();
};
