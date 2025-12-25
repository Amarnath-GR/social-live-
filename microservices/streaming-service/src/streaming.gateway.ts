import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  ConnectedSocket,
  MessageBody,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';

@WebSocketGateway({ cors: true })
export class StreamingGateway {
  @WebSocketServer()
  server: Server;

  @SubscribeMessage('joinStream')
  handleJoinStream(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { streamId: string; userId: string },
  ) {
    client.join(`stream:${data.streamId}`);
    client.to(`stream:${data.streamId}`).emit('userJoined', { userId: data.userId });
  }

  @SubscribeMessage('leaveStream')
  handleLeaveStream(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { streamId: string; userId: string },
  ) {
    client.leave(`stream:${data.streamId}`);
    client.to(`stream:${data.streamId}`).emit('userLeft', { userId: data.userId });
  }

  @SubscribeMessage('streamMessage')
  handleStreamMessage(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { streamId: string; message: string; userId: string },
  ) {
    this.server.to(`stream:${data.streamId}`).emit('newMessage', {
      message: data.message,
      userId: data.userId,
      timestamp: new Date(),
    });
  }

  @SubscribeMessage('streamUpdate')
  handleStreamUpdate(
    @MessageBody() data: { streamId: string; viewerCount: number },
  ) {
    this.server.to(`stream:${data.streamId}`).emit('streamUpdated', {
      viewerCount: data.viewerCount,
    });
  }
}