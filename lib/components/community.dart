import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:circulahealth/api/dio.dart';
import 'package:circulahealth/api/google_sign_in.dart';
import 'package:circulahealth/components/animated_button.dart';
import 'package:circulahealth/providers/main_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Community extends StatefulWidget {
  const Community({super.key});

  @override
  State<Community> createState() => _CommunityState();
}

class _CommunityState extends State<Community> {
  TextEditingController _onYourMindController = new TextEditingController();
  late MainProvider _mainProvider;
  var posts = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        _mainProvider = Provider.of<MainProvider>(context, listen: false);
        setState(() {
          _mainProvider.setIsLoading(true);
        });
        posts = await getPosts();
        setState(() {
          _mainProvider.setIsLoading(false);
        });
      } catch (e) {
        print(e);
        setState(() {
          _mainProvider.setIsLoading(false);
        });
      }
    });
  }

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
                          final body = {
                            'email': mainProvider.userCredential,
                            'text': _onYourMindController.text,
                          };
                          var dio = setupDio();
                          var response = await dio.post(
                            "https://circula-nestjs-production.up.railway.app/users/add-post",
                            data: body,
                          );
                          posts = await getPosts();
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
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];

                      final timeAgo = post?.createdAt != null
                          ? _formatTimeAgo(post?.createdAt)
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
                                  child: post?.user?.photoUrl != "" &&
                                          post?.user?.photoUrl != null
                                      ? ClipOval(
                                          child: Image.network(
                                            post?.user?.photoUrl ?? "",
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child,
                                                loadingProgress) {
                                              if (loadingProgress == null) {
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
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return const SizedBox(
                                                width: 50,
                                                height: 50,
                                                child: Center(
                                                    child: Icon(Icons.person,
                                                        size: 35)),
                                              );
                                            },
                                          ),
                                        )
                                      : const Icon(Icons.person, size: 50),
                                ),
                                const SizedBox(width: 10.0),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      post?.user?.username != "" &&
                                              post?.user?.username != null
                                          ? post?.user?.username != "" &&
                                                  post?.user?.username != null
                                              ? post?.user?.username
                                              : post?.email
                                          : post?.user?.fullName != "" &&
                                                  post?.user?.fullName != null
                                              ? post?.user?.fullName
                                              : post?.email,
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
                                post?.text ?? "",
                              ),
                            ),
                            const Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
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
                  ),
                ),
              )
            ],
          ),
        ),
      );
    });
  }

  String _formatTimeAgo(String isoString) {
    final date = DateTime.parse(isoString).toLocal();
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';

    return '${(diff.inDays / 30).floor()}mo ago';
  }
}
