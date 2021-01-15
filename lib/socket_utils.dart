import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart';

class SocketUtils {
  static Socket _socket;

  static init(userHash) {
    if (_socket == null) {
      _socket = io('https://ch4t.galup.app/', {
        'transports': ['websocket'],
        'autoConnect': false,
      });
      _socket.onConnect((data) {
        print("connected...");
        print(data);
        _socket.emit('chat:conexion', {
          'hash': userHash,
        });
      });
      _socket.onConnectError((data) {
        print(data);
      });
      _socket.onConnectTimeout((data) {
        print(data);
      });
      _socket.onDisconnect((data) {
        print(data);
        _socket = null;
      });

      _socket.connect();
    }
  }

  static sendSingleChatMessage({
    @required userName,
    @required senderHash,
    @required receiverHash,
    @required message,
    @required type,
    @required image,
    @required date,
  }) {
    _socket.emit(
      'chat:message',
      {
        'username': userName,
        'hash_sender': senderHash,
        'hash_receiver': receiverHash,
        'message': message,
        'imgurl': image,
        'type': type,
        'dateapp': date,
      },
    );
  }

  static setOnChatMessageReceivedListener(Function onChatMessageReceived) {
    _socket.on('chat:server', (data) {
      print('Recibido $data');
      onChatMessageReceived(data);
    });
  }

  static disconnect(userHash) {
    if (_socket != null) {
      _socket.emit('chat:desconexion', {
        'hash': userHash,
      });
      _socket.close();
    }
  }
}
