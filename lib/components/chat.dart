import 'package:circulahealth/providers/main_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(ChatApp());

class ChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Chat UI',
      home: ChatScreen(),
    );
  }
}

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

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  final TextEditingController _controller = TextEditingController();
  bool _botTyping = false;

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
      await FirebaseFirestore.instance
          .collection('chats')
          .doc("${userId}_bot")
          .collection('messages')
          .add({
        'senderId': userId,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
        'receiverId': "bot"
      });
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

  Widget _buildMessageBubble(
      var message, String userId, String senderId, String photoUrl) {
    final isMe = userId == senderId;
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isMe) ...[
          CircleAvatar(
            backgroundImage: NetworkImage(photoUrl),
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
            backgroundImage: NetworkImage(photoUrl),
            radius: 16,
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MainProvider>(builder: (context, mainProvider, child) {
      return Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text(
              "Circula AI Assistant",
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('chats')
                      .doc("${mainProvider.userCredential.user?.uid}_bot")
                      .collection('messages')
                      .orderBy('timestamp', descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final messages = snapshot.data!.docs;
                    WidgetsBinding.instance
                        .addPostFrameCallback((_) => scrollToBottom());
                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(8),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        return _buildMessageBubble(
                            messages[index]["text"],
                            mainProvider.userCredential.user?.uid ?? "",
                            messages[index]["senderId"],
                            mainProvider.userCredential.user?.photoURL ?? "");
                      },
                    );
                  }),
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
                                await _sendMessage(
                                    mainProvider.userCredential.user?.uid ??
                                        "");
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
                      if (_isLoading) {
                        return;
                      }
                      await _sendMessage(
                          mainProvider.userCredential.user?.uid ?? "");
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
