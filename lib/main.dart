import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:helloworld/player.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoItem {
  final String id;
  final String title;

  VideoItem(this.id, this.title);
}

void main() {
  debugPrint("main start");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final playListScreenKey = GlobalKey();
  final playerScreenKey = GlobalKey();

  int durationTime = 1;

  bool isPlaying = false;

  List<VideoItem> playList = [];

  YoutubeExplode youtubeExplode = YoutubeExplode();

  final textController = TextEditingController();

  final _controller = YoutubePlayerController(
    initialVideoId: 'UNKyDog278k',
    flags: const YoutubePlayerFlags(
      mute: false,
      autoPlay: false,
      disableDragSeek: false,
      loop: false,
      isLive: false,
      forceHD: false,
      enableCaption: true,
    ),
  );

  void hideNavigationBar() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  void moveToScreen(context) {
    debugPrint('move screen');

    Scrollable.ensureVisible(context,
        duration: Duration(seconds: durationTime));
  }

  void handlePressPlay() {
    if (_controller.value.isPlaying) {
      _controller.pause();

      setState(() {
        isPlaying = false;
      });

      return;
    }

    _controller.play();

    setState(() {
      isPlaying = true;
    });
  }

  Future<void> handlePressAdd() async {
    String url = textController.text;

    if (url.isEmpty) {
      return;
    }

    String? videoId = YoutubePlayer.convertUrlToId(url);

    if (videoId == null) {
      return;
    }

    var videoData = await youtubeExplode.videos.get(url);

    VideoItem videoItem = VideoItem(videoId, videoData.title);

    setState(() {
      playList = [...playList, videoItem];
    });
  }

  @override
  void dispose() {
    textController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            Container(
                key: playListScreenKey,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Colors.white,
                child: SafeArea(
                  child: Column(
                    children: [
                      OutlinedButton(
                          onPressed: () => {
                                moveToScreen(playerScreenKey.currentContext),
                                hideNavigationBar()
                              },
                          child: const Text("show")),
                      Card(
                          child: Row(children: [
                        Flexible(
                            child: TextField(
                                controller: textController,
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText:
                                        'https://youtube.com/shorts/JGqRKgZ7HIU'))),
                        IconButton(
                            iconSize: 40,
                            onPressed: handlePressAdd,
                            icon: const Icon(Icons.add))
                      ])),
                      Row(
                        children: [
                          IconButton(
                              iconSize: 72,
                              onPressed: handlePressPlay,
                              icon: isPlaying
                                  ? const Icon(Icons.pause_outlined)
                                  : const Icon(Icons.play_arrow_outlined)),
                        ],
                      ),
                      ListView.builder(
                        itemCount: playList.length,
                        itemBuilder: (context, index) {
                          return Text(
                            playList[index].title,
                            style: const TextStyle(fontSize: 20),
                          );
                        },
                        shrinkWrap: true,
                      ),
                    ],
                  ),
                )),
            Container(
              key: playerScreenKey,
              child: Player(
                  () => {moveToScreen(playListScreenKey.currentContext)},
                  _controller),
            )
          ],
        ));
  }
}
