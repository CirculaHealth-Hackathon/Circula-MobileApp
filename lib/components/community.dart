import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:circulahealth/components/animated_button.dart';
import 'package:circulahealth/providers/main_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class Community extends StatefulWidget {
  const Community({super.key});

  @override
  State<Community> createState() => _CommunityState();
}

class _CommunityState extends State<Community> {
  TextEditingController _onYourMindController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Consumer<MainProvider>(builder: (context, mainProvider, child) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Container(
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
                    const Icon(Icons.search),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Find Post...',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        onSubmitted: (value) {
                          print(value);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  "Circula Community",
                  style: TextStyle(
                    fontSize: 36.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
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
                child: TextField(
                  controller: _onYourMindController,
                  decoration: const InputDecoration(
                    hintText: "What's on your mind?",
                    // prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  onSubmitted: (value) {
                    if (value != "") {}
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 15.0,
                ),
                child: CustomAnimatedButton(
                    onButtonpressed: () async {
                      if (_onYourMindController.text != "") {
                        FocusScope.of(context).unfocus();
                        try {
                          setState(() {
                            mainProvider.setIsLoading(true);
                          });
                          final firestore = FirebaseFirestore.instance;

                          // Get the user info from "users" collection
                          final userSnapshot = await firestore
                              .collection('users')
                              .doc(mainProvider.userCredential.user?.uid)
                              .get();
                          if (userSnapshot.exists) {
                            final userData = userSnapshot.data();
                            final postData = {
                              'userId': mainProvider.userCredential.user?.uid,
                              'userName': userData?['username'],
                              'userProfilePicture': userData?['photoUrl'],
                              'userFullName': userData?['fullName'] ?? "",
                              'description': _onYourMindController.text,
                              'timestamp': DateTime.now().toUtc(),
                              'likers': [],
                              'comments': []
                            };
                            await firestore.collection('posts').add(postData);
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.success,
                              animType: AnimType.scale,
                              title: 'Success!',
                              desc: 'Successfully posted!',
                              btnOkOnPress: () {},
                              btnOkColor: Colors.green,
                              headerAnimationLoop: false,
                            ).show();
                            _onYourMindController.text = "";
                          }
                          setState(() {
                            mainProvider.setIsLoading(false);
                          });
                        } catch (e) {
                          setState(() {
                            mainProvider.setIsLoading(false);
                          });
                        }
                      }
                    },
                    buttonTitle: "Post"),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('posts')
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final posts = snapshot.data?.docs;
                        return ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: posts?.length,
                          itemBuilder: (context, index) {
                            final post =
                                posts?[index].data() as Map<String, dynamic>;

                            final DateTime? timestamp =
                                (post['timestamp'] as Timestamp?)?.toDate();
                            final timeAgo = timestamp != null
                                ? _formatTimeAgo(timestamp)
                                : 'Unknown time';
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                            color: Colors.grey,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            50.0,
                                          ),
                                        ),
                                        child: post['userProfilePicture'] !=
                                                null
                                            ? ClipOval(
                                                child: Image.network(
                                                  post['userProfilePicture'],
                                                  width: 50,
                                                  height: 50,
                                                  fit: BoxFit.cover,
                                                  loadingBuilder: (context,
                                                      child, loadingProgress) {
                                                    if (loadingProgress ==
                                                        null) {
                                                      return child;
                                                    }
                                                    return Container(
                                                      width: 50,
                                                      height: 50,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        border: Border.all(
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                      child: const Center(
                                                          child:
                                                              CircularProgressIndicator()),
                                                    );
                                                  },
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return const SizedBox(
                                                      width: 50,
                                                      height: 50,
                                                      child: Center(
                                                          child: Icon(
                                                              Icons.person,
                                                              size: 35)),
                                                    );
                                                  },
                                                ),
                                              )
                                            : const Icon(Icons.person,
                                                size: 50),
                                      ),
                                      const SizedBox(width: 10.0),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            post["userName"] != ""
                                                ? post["userName"] != ""
                                                    ? post["userName"]
                                                    : "Anonymous"
                                                : post["userFullName"] != ""
                                                    ? post["userFullName"]
                                                    : "Anonymous",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            timeAgo,
                                            style: const TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                    ),
                                    child: Text(
                                      post["description"] ?? "",
                                    ),
                                  ),
                                  const Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.thumb_up_alt_outlined,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(width: 7.5),
                                      Text(
                                        "Like",
                                        style: TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      SizedBox(width: 15.0),
                                      Icon(
                                        Icons.comment_outlined,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(width: 7.5),
                                      Text(
                                        "Comment",
                                        style: TextStyle(
                                          color: Colors.grey,
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            );
                          },
                        );
                      }),
                ),
              )
            ],
          ),
        ),
      );
    });
  }

  String _formatTimeAgo(DateTime dateTime) {
    final Duration diff = DateTime.now().difference(dateTime);

    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return DateFormat.yMMMd().format(dateTime); // e.g. May 13, 2025
  }
}
