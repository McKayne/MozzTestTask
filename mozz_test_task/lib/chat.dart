import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.title, required this.chatIndex});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  final int chatIndex;

  @override
  State<ChatScreen> createState() => _ChatState();
}

class _ChatState extends State<ChatScreen> {
  List<dynamic> _chatMessages = [];
  final TextEditingController _messageController = TextEditingController();

  _ChatState() {
    _fetchChatMessages();
  }

  void _fetchChatMessages() {
    CollectionReference chats = FirebaseFirestore.instance.collection('chats');

    _chatMessages.clear();

    chats.get().then((QuerySnapshot snapshot) {
      final selectedChat = snapshot.docs[widget.chatIndex];

      setState(() {
        _chatMessages = selectedChat.get("messages");
      });
    }).catchError((error) => {
      showToast("Ошибка запроса чата: $error")
    });
  }

  void _deleteChatMessage(int messageIndex) {
    CollectionReference chats = FirebaseFirestore.instance.collection('chats');

    chats.get().then((QuerySnapshot snapshot) {
      final selectedChat = snapshot.docs[widget.chatIndex];

      var collection = FirebaseFirestore.instance.collection('chats');
      var currentMessages = selectedChat["messages"];

      currentMessages.removeAt(messageIndex);

      collection
          .doc(selectedChat.id)
          .update({"messages" : currentMessages}) // <-- Updated data
          .then((value) => {
        _fetchChatMessages()
      }).catchError((error) => {
        showToast("Ошибка удаления сообщения: $error")
      });
    }).catchError((error) => {
      showToast("Ошибка запроса чата: $error")
    });
  }

  void _appendMessage(String chatMessage) {
    CollectionReference chats = FirebaseFirestore.instance.collection('chats');

    chats.get().then((QuerySnapshot snapshot) {
      final selectedChat = snapshot.docs[widget.chatIndex];

      var collection = FirebaseFirestore.instance.collection('chats');
      var currentMessages = selectedChat["messages"];

      final message = {"timestamp": DateTime.now().millisecondsSinceEpoch, "type": "plain", "is_outgoing": _chatMessages.length % 2 == 0, "message": chatMessage};
      currentMessages.add(message);

      collection
          .doc(selectedChat.id)
          .update({"messages" : currentMessages}) // <-- Updated data
          .then((value) => {
        _fetchChatMessages()
      }).catchError((error) => {
        showToast("Ошибка добавления сообщения: $error")
      });
    }).catchError((error) => {
      showToast("Ошибка запроса чата: $error")
    });
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> messageWidgets = [];

    for (int i = 0; i < _chatMessages.length; i++) {
      Color chatAvatarColor = Color(0).withOpacity(1.0);

      messageWidgets.add(
          _ChatMessageItem(
            chatIndex: i,
            chatContactName: _chatMessages[i]["message"],
            chatPreviewMessage: "",
            chatTimestamp: _chatMessages[i]["timestamp"],
            chatAvatarColor: chatAvatarColor,
            clickCallback: _deleteChatMessage,
          )
      );
    }

    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Column(
        // Column is also a layout widget. It takes a list of children and
        // arranges them vertically. By default, it sizes itself to fit its
        // children horizontally, and tries to be as tall as its parent.
        //
        // Column has various properties to control how it sizes itself and
        // how it positions its children. Here we use mainAxisAlignment to
        // center the children vertically; the main axis here is the vertical
        // axis because Columns are vertical (the cross axis would be
        // horizontal).
        //
        // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
        // action in the IDE, or press "p" in the console), to see the
        // wireframe for each widget.
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(child: SingleChildScrollView(
            child: Column(
              // Column is also a layout widget. It takes a list of children and
              // arranges them vertically. By default, it sizes itself to fit its
              // children horizontally, and tries to be as tall as its parent.
              //
              // Column has various properties to control how it sizes itself and
              // how it positions its children. Here we use mainAxisAlignment to
              // center the children vertically; the main axis here is the vertical
              // axis because Columns are vertical (the cross axis would be
              // horizontal).
              //
              // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
              // action in the IDE, or press "p" in the console), to see the
              // wireframe for each widget.
              mainAxisAlignment: MainAxisAlignment.start,
              children: messageWidgets,
            ),
          )),

          TextField(
            controller: _messageController,
            onSubmitted: (text) {
              _messageController.text = "";
              _appendMessage(text);
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Сообщение',
            ),
          )
        ],
      )// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class _ChatMessageItem extends StatefulWidget {
  const _ChatMessageItem({
    super.key,
    required this.chatIndex, required this.chatContactName,
    required this.chatPreviewMessage, this.chatTimestamp,
    required this.chatAvatarColor, required this.clickCallback
  });

  final int chatIndex;
  final String chatContactName, chatPreviewMessage;
  final int? chatTimestamp;
  final Color chatAvatarColor;
  final void Function(int) clickCallback;

  @override
  State<StatefulWidget> createState() => _ChatMessageState();
}

class _ChatMessageState extends State<_ChatMessageItem> {

  @override
  Widget build(BuildContext context) {

    final chatTimestamp = widget.chatTimestamp;
    String chatDateTime = chatTimestamp != null ? DateFormat('dd.MM.yyyy').format(DateTime.fromMicrosecondsSinceEpoch(chatTimestamp * 1000)) : "";

    return MaterialApp(
      // The Flutter cells will be noticeably different (due to background color
      // and the Flutter logo). The banner breaks immersion.
      debugShowCheckedModeBanner: false,
      home: Container(
        color: Colors.white,
        child: Builder(
          builder: (context) {
            return GestureDetector(
              onLongPress: () async {
                final result = await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Подтверждение удаления'),
                      content: const Text('Вы действительно хотите удалить это сообщение?'),
                      actions: [
                        TextButton(
                          child: const Text('Отмена'),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        TextButton(
                          child: const Text('Удалить'),
                          onPressed: () {
                            widget.clickCallback(widget.chatIndex);
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: Card(
                // Mimic the platform Material look.
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
                color: Colors.lightGreen,
                child: Stack(
                  children: [
                    Row(
                      children: [
                        Expanded(
                            flex: 2,
                            child: Container(
                                margin: const EdgeInsets.only(left: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.chatContactName,
                                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      widget.chatPreviewMessage,
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 16
                                      ),
                                    ),
                                  ],
                                ))
                        ),

                        Expanded(
                            flex: 2,
                            child: Container(
                                margin: const EdgeInsets.only(right: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      chatDateTime,
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 16
                                      ),
                                    ),
                                    const Text(
                                      "",
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 16
                                      ),
                                    )
                                  ],
                                )
                            )
                        )
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

const Color _toastBackgroundColor = Color(0xff2b2b2b);
const Color _toastTextColor = Color(0xffffffff);

void showToast(String message) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      // Also possible "TOP" and "CENTER"
      backgroundColor: _toastBackgroundColor,
      textColor: _toastTextColor
  );
}