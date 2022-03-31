import 'dart:math';

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
      title: 'Chat Bot',
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
  String state = 'intro';
  String question = '';
  String student = '';

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
          ? HexColor('#9000FF')
          : HexColor('#FFFFFF'),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: themeValue == Brightness.dark
            ? HexColor('#3C3A3A')
            : HexColor('#9000FF'),
        title: Text(
          'ChatBot',
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color:
                  themeValue == Brightness.dark ? Colors.white : Colors.black),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: Body(messages: messages)),
            Container(
              decoration: BoxDecoration(
                color: HexColor('#9000FF'),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: messageController,
                      style: TextStyle(
                          color: Colors.black87, fontFamily: 'Poppins'),
                      decoration: new InputDecoration(
                        contentPadding: EdgeInsets.only(left: 20),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: new OutlineInputBorder(
                            borderSide: new BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(20)),
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
                        hintText: 'Tulis sesuatu untuk menanyakan',
                      ),
                    ),
                  ),
                  Container(
                    width: 70,
                    height: 70,
                    padding: const EdgeInsets.only(
                      left: 20.0,
                    ),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: Icon(
                          Icons.send,
                          color: Colors.purple,
                        ),
                        onPressed: () {
                          sendMessage(messageController.text);
                          messageController.clear();
                        },
                      ),
                    ),
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
      Uri.parse('http://chat-end.ragamlima.com/api/sent_message'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'message': text,
        'state': state,
        'question': question,
        'student': student,
      }),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      final data = jsonDecode(response.body);
      print(data);
      chatAnswer = data['message'];
      state = data['state'];
      question = data['question'];
      student = data['student'];
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
        vertical: 50,
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
        child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        isUserMessage
            ? Container()
            : Container(
                padding: const EdgeInsets.only(right: 15),
                width: 60,
                child: ClipRRect(child: Image.asset('assets/logo.png')),
              ),
        LayoutBuilder(
          builder: (context, constrains) {
            return Expanded(
              child: Container(
                constraints: BoxConstraints(minWidth: 10, maxWidth: 250),
                decoration: BoxDecoration(
                  color:
                      isUserMessage ? Colors.purple.shade400 : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(15),
                child: Text(
                  message.text?.text?[0] ?? '',
                  style: TextStyle(
                    color: isUserMessage ? Colors.white : Colors.black,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    ));
  }
}
