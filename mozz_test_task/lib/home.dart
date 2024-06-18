import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:math' as math;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  final TextEditingController _chatNameController = TextEditingController();

  final Color _toastBackgroundColor = const Color(0xff2b2b2b);
  final Color _toastTextColor = const Color(0xffffffff);

  void appendNewChat(String chatContact) {
    Fluttertoast.showToast(
        msg: "Adding $chatContact",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        // Also possible "TOP" and "CENTER"
        backgroundColor: _toastBackgroundColor,
        textColor: _toastTextColor
    );
  }

  void showAppendChatAlert() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });

    AlertDialog(
      title: const Text('Add a new class'),
      content: const TextField(
        //controller: textController,
        autofocus: true,
        decoration: InputDecoration(
            hintText: "Enter the name of the class."),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: const Text('Add'),
          onPressed: () {
            setState((){
              //_items.add(textController.text)  // 👈 add list item to the list
            });
            Navigator.pop(context);
            //Navigator.pop(context, textController.text);
          },
        ),
      ],
    );
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  Color _randomChatAvatarColor() {
    return Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
  }
  
  void _chatItemClick(int chatIndex) {
    Fluttertoast.showToast(
        msg: "Selected chat $chatIndex",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        // Also possible "TOP" and "CENTER"
        backgroundColor: _toastBackgroundColor,
        textColor: _toastTextColor
    );
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> chatWidgets = [

    ];

    for (int i = 0; i < 20; i++) {
      Color chatAvatarColor = _randomChatAvatarColor();

      chatWidgets.add(
          ChatListItem(
            chatIndex: i,
            chatContactName: "Test Chat ${i + 1}",
            chatAvatarColor: chatAvatarColor,
            clickCallback: _chatItemClick,
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
                  appendNewChat(_chatNameController.text);
                  Navigator.pop(context);
                  //Navigator.pop(context, _textController.text);
                },
              ),
            ],
          );
        },
      );
      if (result != null) {
        result as String;
        setState(() {
          //_items.add(result);
        });
      }
      }, //_incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class ChatListItem extends StatefulWidget {
  const ChatListItem({
    super.key,
    required this.chatIndex, required this.chatContactName,
    required this.chatAvatarColor, required this.clickCallback
  });

  final int chatIndex;
  final String chatContactName;
  final Color chatAvatarColor;
  final void Function(int) clickCallback;

  @override
  State<StatefulWidget> createState() => _ChatListItemState();
}

class _ChatListItemState extends State<ChatListItem> with WidgetsBindingObserver {

  int cellNumber = 0;
  AppLifecycleState? appLifecycleState;

  @override
  void initState() {
    // Keep track of what the current platform lifecycle state is.
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      appLifecycleState = state;
    });
  }

  // Show a random bright color.
  Color randomLightColor() {
    return Colors.white; //const Color(0xffff0000);
  }

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
    return MaterialApp(
      // The Flutter cells will be noticeably different (due to background color
      // and the Flutter logo). The banner breaks immersion.
      debugShowCheckedModeBanner: false,
      home: Container(
        color: Colors.white,
        child: Builder(
          builder: (context) {
            return GestureDetector(
              onTap: () => widget.clickCallback(widget.chatIndex),
              child: Card(
                // Mimic the platform Material look.
                margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 16,
                color: randomLightColor(),
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
                                // Show a number provided by the platform based on
                                // the cell's index.
                                _chatNameAbbreviation(),
                                style: const TextStyle(
                                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20
                                ),
                              ),
                            ),
                          ),
                        ),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              // Show a number provided by the platform based on
                              // the cell's index.
                              widget.chatContactName,
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                            const Text(
                              // Show a number provided by the platform based on
                              // the cell's index.
                              "Today",
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 16
                              ),
                            ),
                          ],
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