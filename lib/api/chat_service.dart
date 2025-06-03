import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatService {
  late IO.Socket socket;

  void connect(String userId) {
    print(userId);
    socket = IO.io(
        'https://mawquiz-backend-production.up.railway.app/socket',
        <String, dynamic>{
          'transports': ['websocket'],
          'autoConnect': false,
          'query': {
            'userId': userId.toString(),
          },
        });

    socket.on('connect', (_) {
      print('Connected to chat server');
    });

    socket.on('receiveMessage', (data) {
      print('New message from server: $data');
      // Handle incoming message, update UI, etc.
    });

    socket.on('messageSent', (data) {
      print('Your message was sent: $data');
    });
  }

  void sendMessage(int senderId, int receiverId, String message) {
    socket.emit('sendMessage', {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
    });
  }

  void disconnect() {
    socket.dispose();
  }
}
