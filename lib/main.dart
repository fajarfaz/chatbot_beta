import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Bot',
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late DialogFlowtter dialogFlowtter;
  final TextEditingController messageController = TextEditingController();

  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    DialogFlowtter.fromFile().then((instance) => dialogFlowtter = instance);
  }

  @override
  Widget build(BuildContext context) {
    var themeValue = MediaQuery.of(context).platformBrightness;
    return Scaffold(
      backgroundColor: themeValue == Brightness.dark
          ? HexColor('#262626')
          : HexColor('#FFFFFF'),
      appBar: AppBar(
        backgroundColor: themeValue == Brightness.dark
            ? HexColor('#3C3A3A')
            : HexColor('#BFBFBF'),
        title: Text(
          'Flutter Bot',
          style: TextStyle(
              color:
                  themeValue == Brightness.dark ? Colors.white : Colors.black),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: Body(messages: messages)),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: messageController,
                      style: TextStyle(
                          color: themeValue == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          fontFamily: 'Poppins'),
                      decoration: new InputDecoration(
                        enabledBorder: new OutlineInputBorder(
                            borderSide: new BorderSide(
                                color: themeValue == Brightness.dark
                                    ? Colors.white
                                    : Colors.black),
                            borderRadius: BorderRadius.circular(15)),
                        hintStyle: TextStyle(
                          color: themeValue == Brightness.dark
                              ? Colors.white54
                              : Colors.black54,
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                        ),
                        labelStyle: TextStyle(
                            color: themeValue == Brightness.dark
                                ? Colors.white
                                : Colors.black),
                        hintText: 'Send a message',
                      ),
                    ),
                  ),
                  IconButton(
                    color: themeValue == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                    icon: Icon(Icons.send),
                    onPressed: () {
                      sendMessage(messageController.text);
                      messageController.clear();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void sendMessage(String text) async {
    if (text.isEmpty) return;
    setState(() {
      addMessage(
        Message(text: DialogText(text: [text])),
        true,
      );
    });

    // DetectIntentResponse response = await dialogFlowtter.detectIntent(
    //   queryInput: QueryInput(text: TextInput(text: text)),
    // );
    var chatAnswer;
    final response = await http.post(
      Uri.parse('http://192.168.1.21/api/sent_message'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'message': text,
      }),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      chatAnswer = jsonDecode(response.body);
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      print(response.statusCode);
    }
    /*if (text == 'lol') {
      chatAnswer = 'hi answer';
    } else {
      chatAnswer = text;
    }*/

    // if (response.message == null) return;
    setState(() {
      addMessage(Message(text: DialogText(text: [chatAnswer])), false);
    });
    return sendMessage(text = '');
  }

  void answerMessage(String chat) async {
    var chatAnswer = 'a';

    if (chat == 'lol') {
      chatAnswer = 'hi answer';
    } else {
      chatAnswer = 'else answer';
    }
    return answerMessage(chatAnswer);
  }

  void addMessage(Message message, [bool isUserMessage = false]) {
    messages.add({
      'message': message,
      'isUserMessage': isUserMessage,
    });
  }

  @override
  void dispose() {
    dialogFlowtter.dispose();
    super.dispose();
  }
}

class Body extends StatelessWidget {
  final List<Map<String, dynamic>> messages;

  const Body({
    Key? key,
    this.messages = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: (context, i) {
        var obj = messages[messages.length - 1 - i];
        Message message = obj['message'];
        bool isUserMessage = obj['isUserMessage'] ?? false;
        return Row(
          mainAxisAlignment:
              isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _MessageContainer(
              message: message,
              isUserMessage: isUserMessage,
            ),
          ],
        );
      },
      separatorBuilder: (_, i) => Container(height: 10),
      itemCount: messages.length,
      reverse: true,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 20,
      ),
    );
  }
}

class _MessageContainer extends StatelessWidget {
  final Message message;
  final bool isUserMessage;

  const _MessageContainer({
    Key? key,
    required this.message,
    this.isUserMessage = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 250),
      child: LayoutBuilder(
        builder: (context, constrains) {
          return Container(
            decoration: BoxDecoration(
              color: isUserMessage ? Colors.blue : Colors.grey[800],
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(10),
            child: Text(
              message.text?.text?[0] ?? '',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          );
        },
      ),
    );
  }
}
