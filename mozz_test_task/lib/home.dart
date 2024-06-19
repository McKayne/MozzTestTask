import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'chat.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'dart:async';

class ChatHomeScreen extends StatefulWidget {
  const ChatHomeScreen({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<ChatHomeScreen> createState() => _ChatHomeState();
}

class _ChatHomeState extends State<ChatHomeScreen> {

  var _homeScreenPresentedState = false;

  late Timer _lifecycleTimer;

  final List<(String, int, String, int?)> _chats = [];

  final TextEditingController _chatNameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    const oneSec = Duration(seconds: 1);
    _lifecycleTimer = Timer.periodic(oneSec, (Timer t) {
      _handleStateChange();
    });
  }

  void _handleStateChange() {
    final isTopOfNavigationStack = ModalRoute.of(context)?.isCurrent ?? false;

    if (_homeScreenPresentedState != isTopOfNavigationStack) {
      _homeScreenPresentedState = isTopOfNavigationStack;

      if (isTopOfNavigationStack) {
        _fetchChats();
      }
    }
  }

  @override
  void dispose() {
    _lifecycleTimer.cancel();
    super.dispose();
  }

  void _fetchChats() {
    CollectionReference chats = FirebaseFirestore.instance.collection('chats');

    setState(() {
      _chats.clear();
    });

    chats.get().then((QuerySnapshot snapshot) {
      snapshot.docs.forEach((doc) {
        final chatName = doc.get("name");
        final chatAvatarColor = doc.get("avatar_color");
        final chatMessages = doc.get("messages");

        setState(() {
          if (chatMessages.length > 0) {
            _chats.add(
                (chatName, chatAvatarColor, "${chatMessages[chatMessages.length - 1]["is_outgoing"] ? "Вы: " : ""}${chatMessages[chatMessages.length - 1]["message"]}", chatMessages[chatMessages.length - 1]["timestamp"])
            );
          } else {
            _chats.add((chatName, chatAvatarColor, "", null));
          }
        });
      });
    }).catchError((error) => {
      showToast("Ошибка запроса чатов: $error")
    });
  }

  void _appendNewChat(String chatContact) {
    CollectionReference chats = FirebaseFirestore.instance.collection('chats');

    List<Map<String, Object>> chatMessages = [];

    chats.add({
      'name': chatContact,
      'avatar_color': _randomChatAvatarColor(),
      'messages': chatMessages
    }).then((value) => {
      _chatNameController.text = "",
      showToast("Чат с $chatContact успешно добавлен"),
      _homeScreenPresentedState = false
      //_fetchChats()
    }).catchError((error) => {
      showToast("Ошибка добавления чата: $error")
    });
  }

  int _randomChatAvatarColor() {
    return (math.Random().nextDouble() * 0xFFFFFF).toInt();
  }
  
  void _chatItemClick(int chatIndex) {
    String chatName = _chats[chatIndex].$1;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(title: chatName, chatIndex: chatIndex),
      ),
    );
  }

  void _deleteChat(int chatIndex) {
    CollectionReference chats = FirebaseFirestore.instance.collection('chats');

    chats.get().then((QuerySnapshot snapshot) {
      final selectedChat = snapshot.docs[chatIndex];

      var collection = FirebaseFirestore.instance.collection('chats');

      collection
          .doc(selectedChat.id)
          .delete()
          .then((value) => {
        _homeScreenPresentedState = false
        //_fetchChats()
      }).catchError((error) => {
        showToast("Ошибка удаления чата: $error")
      });
    }).catchError((error) => {
      showToast("Ошибка запроса чата: $error")
    });
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> chatWidgets = [];

    for (int i = 0; i < _chats.length; i++) {
      Color chatAvatarColor = Color(_chats[i].$2).withOpacity(1.0);

      chatWidgets.add(
          _ChatListItem(
            chatIndex: i,
            chatContactName: _chats[i].$1,
            chatPreviewMessage: _chats[i].$3,
            chatTimestamp: _chats[i].$4,
            chatAvatarColor: chatAvatarColor,
            clickCallback: _chatItemClick,
            chatDeleteCallback: _deleteChat,
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
          const TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Поиск',
            ),
          ),

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
              children: chatWidgets,
            ),
          ))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Новый чат'),
                content: TextField(
                  controller: _chatNameController,
                  autofocus: true,
                  decoration: const InputDecoration(
                      hintText: "Введите имя контакта"),
                ),
                actions: [
                  TextButton(
                    child: const Text('Отмена'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  TextButton(
                    child: const Text('Добавить'),
                    onPressed: () {
                      _appendNewChat(_chatNameController.text);
                      Navigator.pop(context);
                      //Navigator.pop(context, _textController.text);
                    },
                  ),
                ],
              );
            },
          );
        }, //_incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class _ChatListItem extends StatefulWidget {
  const _ChatListItem({
    super.key,
    required this.chatIndex, required this.chatContactName,
    required this.chatPreviewMessage, this.chatTimestamp,
    required this.chatAvatarColor,
    required this.clickCallback, required this.chatDeleteCallback
  });

  final int chatIndex;
  final String chatContactName, chatPreviewMessage;
  final int? chatTimestamp;
  final Color chatAvatarColor;
  final void Function(int) clickCallback;
  final void Function(int) chatDeleteCallback;

  @override
  State<StatefulWidget> createState() => _ChatListItemState();
}

class _ChatListItemState extends State<_ChatListItem> {

  String _chatNameAbbreviation() {
    final chatContactName = widget.chatContactName.toUpperCase();

    List<String> chatNameParts = chatContactName.split(" ");
    if (chatNameParts.length > 1) {
      return "${chatNameParts[0][0]}${chatNameParts[1][0]}";
    } else if (chatNameParts.length == 1 && chatNameParts[0].length > 1) {
      return "${chatNameParts[0][0]}${chatNameParts[0][1]}";
    } else if (chatNameParts.length == 1 && chatNameParts[0].isNotEmpty) {
      return chatNameParts[0][0];
    }

    return "NN";
  }

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
                      content: const Text('Вы действительно хотите удалить этот чат?'),
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
                            widget.chatDeleteCallback(widget.chatIndex);
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              onTap: () => widget.clickCallback(widget.chatIndex),
              child: Card(
                // Mimic the platform Material look.
                margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 16,
                color: Colors.white,
                child: Stack(
                  children: [
                    Row(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          width: 80,
                          height: 80,
                          child: Card(
                            color: widget.chatAvatarColor,
                            semanticContainer: true,
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40.0),
                            ),
                            elevation: 5,
                            margin: const EdgeInsets.all(10),
                            child: Center(
                              child: Text(
                                _chatNameAbbreviation(),
                                style: const TextStyle(
                                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20
                                ),
                              ),
                            ),
                          ),
                        ),

                        Expanded(
                            flex: 2,
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
                            )
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