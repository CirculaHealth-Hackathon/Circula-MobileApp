import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:circulahealth/api/chat_service.dart';
import 'package:circulahealth/api/google_sign_in.dart';
import 'package:circulahealth/api/joke_service.dart';
import 'package:circulahealth/models/user.dart';
import 'package:circulahealth/providers/main_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:profanity_filter/profanity_filter.dart';

class ChatMessage {
  final String text;
  final bool isMe;
  final bool isImage;
  final String avatarUrl;

  ChatMessage(
      {required this.text,
      required this.isMe,
      required this.avatarUrl,
      this.isImage = false});
}

class TheMessage {
  final String message;
  final String senderEmail;
  final String receiverEmail;
  final String avatarUrl;

  TheMessage(
      {required this.message,
      required this.senderEmail,
      required this.receiverEmail,
      required this.avatarUrl});
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  List<dynamic> chatMessages = [];
  final filter = ProfanityFilter();
  final TextEditingController _controller = TextEditingController();
  bool _botTyping = false;
  late ChatService chatService;
  JokeService jokeService = new JokeService();
  late MainProvider _mainProvider;
  UserDetails? userData;

  final List<RegExp> badWordPatterns = [
    RegExp(r'\bf+u+c+k+\b', caseSensitive: false),
    RegExp(r'\bf+u+c+k+e+r+\b', caseSensitive: false),
    RegExp(r'\bs+h+i+t+\b', caseSensitive: false),
    RegExp(r'\ba+s+s+h*o+l+e+\b', caseSensitive: false),
    RegExp(r'\bb+i+t+c+h+\b', caseSensitive: false),
    RegExp(r'\bd+a+m+n+\b', caseSensitive: false),
    RegExp(r'\bd+a+r+n+\b', caseSensitive: false),
    RegExp(r'\bp+e+n+i+s+\b', caseSensitive: false),
    RegExp(r'\bv+a+g+i+n+a+\b', caseSensitive: false),
    RegExp(r'\bd+i+c+k+\b', caseSensitive: false),
  ];

  bool containsOffensiveWord(String text) {
    for (final pattern in badWordPatterns) {
      if (pattern.hasMatch(text)) {
        return true;
      }
    }
    return false;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _mainProvider = Provider.of<MainProvider>(context, listen: false);
      setState(() {
        _mainProvider.setIsLoading(true);
      });
      var user = await getUserDetails(_mainProvider.userCredential);
      userData = user;
      var currentChatMessages =
          await getChatMessages(_mainProvider.userCredential);
      setState(() {
        chatMessages = currentChatMessages;
        _mainProvider.setIsLoading(false);
        Future.delayed(const Duration(milliseconds: 150), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeIn,
            );
          }
        });
      });
    });
  }

  void scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _sendMessage(String userId) async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
    });
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      _controller.clear();
      _controller.clear();
    }
    setState(() {
      _isLoading = false;
    });
  }

  // void _sendImage() {
  //   setState(() {
  //     messages.add(ChatMessage(
  //       text: "[Image Sent]",
  //       isMe: true,
  //       isImage: true,
  //       avatarUrl: "https://i.pravatar.cc/150?img=5",
  //     ));
  //   });
  // }

  Widget _buildMessageBubble(var message, String userId, String senderId) {
    final isMe = userId == senderId;
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isMe) ...[
          const CircleAvatar(
            backgroundImage: NetworkImage(""),
            radius: 16,
          ),
          const SizedBox(width: 6),
        ],
        CustomPaint(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            margin: const EdgeInsets.symmetric(vertical: 6),
            constraints: const BoxConstraints(maxWidth: 250),
            decoration: BoxDecoration(
              color: isMe ? Colors.blue[200] : Colors.grey[300],
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft: Radius.circular(isMe ? 12 : 0),
                bottomRight: Radius.circular(isMe ? 0 : 12),
              ),
            ),
            child: Text(message),
          ),
        ),
        if (isMe) ...[
          const SizedBox(width: 6),
          CircleAvatar(
            backgroundImage: NetworkImage(userData?.photoUrl ?? ""),
            radius: 16,
          ),
        ],
      ],
    );
  }

  final TextEditingController _textController = TextEditingController();

  void _showInputDialog(BuildContext context) {
    String? selectedType;

    showDialog(
      context: context,
      builder: (secondContext) {
        return StatefulBuilder(
          builder: (secondContext, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Please Fill In the Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal[800],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Text Input
                      TextField(
                        controller: _textController,
                        decoration: InputDecoration(
                          hintText: "Type your message...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 10),

                      // Radio buttons
                      Column(
                        children: [
                          'Offensive Content',
                          'Inappropriate',
                          'Not Useful'
                        ].map((type) {
                          return RadioListTile<String>(
                            title: Text(type),
                            value: type,
                            groupValue: selectedType,
                            onChanged: (value) {
                              setState(() {
                                selectedType = value;
                              });
                            },
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 10),

                      // Submit Button
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                _textController.clear();
                                Navigator.of(secondContext)
                                    .pop(); // Close dialog
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final text = _textController.text.trim();

                                if (text.isEmpty || selectedType == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please fill all fields'),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                  return;
                                }
                                try {
                                  Navigator.of(secondContext)
                                      .pop(); // Close dialog
                                  _mainProvider.setIsLoading(true);
                                  await addReport(_mainProvider.userCredential,
                                      text, selectedType ?? "");
                                  _textController.clear();
                                  _mainProvider.setIsLoading(false);
                                  AwesomeDialog(
                                    context: context,
                                    dialogType: DialogType.success,
                                    animType: AnimType.scale,
                                    title: 'Success!',
                                    desc:
                                        'Successfully reported! Thank you for helping us!',
                                    btnOkOnPress: () {},
                                    btnOkColor: Colors.green,
                                    headerAnimationLoop: false,
                                  ).show();
                                } catch (e) {
                                  _mainProvider.setIsLoading(false);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text(
                                'Submit',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MainProvider>(builder: (context, mainProvider, child) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Center(
            child: Text(
              "Circula AI Assistant",
            ),
          ),
          actions: [
            PopupMenuButton<String>(
              onSelected: (String value) {
                _showInputDialog(context);
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                    value: 'Report', child: const Text('Report'), onTap: () {}),
              ],
            )
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(8),
                itemCount: chatMessages.length,
                itemBuilder: (context, index) {
                  return _buildMessageBubble(
                      chatMessages[index].message,
                      chatMessages[index].senderEmail,
                      chatMessages[index].receiverEmail);
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCFCFC),
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                          color: const Color(0xFFDFDFDF),
                          width: 2.0,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      alignment: Alignment.center,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              decoration: const InputDecoration(
                                hintText: 'Ask AI chat anything...',
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                              onSubmitted: (value) async {
                                if (_isLoading) {
                                  return;
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          InkWell(
                            onTap: () {},
                            child: const Icon(Icons.image),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                          0xFF2170FF), // ✅ set your background color here
                      foregroundColor:
                          Colors.white, // optional: set text/icon color
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                    onPressed: () async {
                      if (_isLoading || _controller.text.trim() == "") {
                        return;
                      }
                      if (filter.hasProfanity(_controller.text.trim()) ||
                          containsOffensiveWord(_controller.text.trim())) {
                        _controller.clear();
                        return AwesomeDialog(
                          context: context,
                          dialogType: DialogType.info,
                          animType: AnimType.scale,
                          title: 'Info!',
                          desc: 'Not allowed to use offensive languages!',
                          btnOkOnPress: () {},
                          btnOkColor: Colors.green,
                          headerAnimationLoop: false,
                        ).show();
                      }
                      var userMessage = _controller.text.trim();
                      setState(() {
                        var theMessage = TheMessage(
                            message: _controller.text.trim(),
                            senderEmail: mainProvider.userCredential,
                            receiverEmail: mainProvider.userCredential,
                            avatarUrl: "");
                        chatMessages.add(theMessage);
                        WidgetsBinding.instance
                            .addPostFrameCallback((_) => scrollToBottom());
                        _controller.text = "";
                      });

                      await addMessage(mainProvider.userCredential,
                          mainProvider.userCredential, userMessage);
                      _controller.text = "";
                      var joke = await jokeService.getRandomJoke();
                      setState(() {
                        var theMessage = TheMessage(
                            message: "${joke.setup}\n😂\n${joke.punchline}",
                            senderEmail: "chatbot@gmail.com",
                            receiverEmail: mainProvider.userCredential,
                            avatarUrl: "");
                        chatMessages.add(theMessage);
                        WidgetsBinding.instance
                            .addPostFrameCallback((_) => scrollToBottom());
                      });
                      await addMessage(
                          "chatbot@gmail.com",
                          mainProvider.userCredential,
                          "${joke.setup}\n😂\n${joke.punchline}");
                    },
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class BubbleTailPainter extends CustomPainter {
  final bool isMe;
  final Color color;

  BubbleTailPainter({required this.isMe, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();

    if (isMe) {
      // Tail on right
      path.moveTo(size.width, 0);
      path.lineTo(size.width + 6, 6);
      path.lineTo(size.width, 12);
    } else {
      // Tail on left
      path.moveTo(0, 0);
      path.lineTo(-6, 6);
      path.lineTo(0, 12);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant BubbleTailPainter oldDelegate) {
    return oldDelegate.isMe != isMe || oldDelegate.color != color;
  }
}
