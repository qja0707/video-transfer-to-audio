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

  bool isChangingVideo = false;

  double sliderPlaytime = 0;

  List<VideoItem> playList = [];

  int playIndex = 0;

  String currentPlayVideoId = '';

  YoutubeExplode youtubeExplode = YoutubeExplode();

  final textController = TextEditingController();

  final _controller = YoutubePlayerController(
    initialVideoId: '',
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

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      if (isChangingVideo) {
        return;
      }

      if (isPlaying != _controller.value.isPlaying) {
        setState(() {
          isPlaying = _controller.value.isPlaying;
        });
      }
      final totalDuration = _controller.metadata.duration.inSeconds;

      final currentDuration = _controller.value.position.inSeconds;

      if (totalDuration <= 0) {
        return;
      }

      setState(() {
        sliderPlaytime = currentDuration / totalDuration;
      });

      debugPrint(currentDuration.toString() + "/" + totalDuration.toString());

      if (totalDuration != currentDuration) {
        return;
      }

      handleChangeVideo(true);
    });
  }

  @override
  void dispose() {
    textController.dispose();

    super.dispose();
  }

  void hideNavigationBar() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  void moveToScreen(context) {
    debugPrint('move screen');

    Scrollable.ensureVisible(context,
        duration: Duration(seconds: durationTime));
  }

  void handleChangeVideo(bool isNext) {
    isChangingVideo = true;

    int direction = isNext ? 1 : -1;

    int videoIndex = playIndex + direction;

    if (videoIndex < 0) {
      videoIndex = playList.length - 1;
    } else if (videoIndex >= playList.length) {
      videoIndex = 0;
    }

    _controller.load(playList[videoIndex].id);

    debugPrint(_controller.metadata.toString());

    if (isPlaying) {
      _controller.play();
    }

    setState(() {
      playIndex = videoIndex;
    });

    isChangingVideo = false;
  }

  void handlePressPlay() {
    if (playList.isEmpty) {
      return;
    }

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

    if (playList.isEmpty) {
      _controller.load(videoItem.id);
    }

    setState(() {
      playList = [...playList, videoItem];
    });

    textController.clear();
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
                                    hintText: 'https://vedio.url',
                                    hintStyle:
                                        TextStyle(color: Colors.black12)))),
                        IconButton(
                            iconSize: 40,
                            onPressed: handlePressAdd,
                            icon: const Icon(Icons.add))
                      ])),
                      Row(
                        children: [
                          IconButton(
                              iconSize: 72,
                              onPressed: () => handleChangeVideo(false),
                              icon: const Icon(Icons.skip_previous)),
                          IconButton(
                              iconSize: 72,
                              onPressed: handlePressPlay,
                              icon: isPlaying
                                  ? const Icon(Icons.pause_outlined)
                                  : const Icon(Icons.play_arrow)),
                          IconButton(
                              iconSize: 72,
                              onPressed: () => handleChangeVideo(true),
                              icon: const Icon(Icons.skip_next)),
                        ],
                      ),
                      Card(
                          child: Column(
                        children: [
                          Slider(
                              value: sliderPlaytime,
                              onChanged: (double value) {
                                debugPrint('move screen');

                                _controller.seekTo(
                                  Duration(
                                      seconds: (_controller
                                                  .metadata.duration.inSeconds *
                                              value)
                                          .floor()),
                                );
                              }),
                        ],
                      )),
                      ListView.builder(
                        itemCount: playList.length,
                        itemBuilder: (context, index) {
                          return Text(playList[index].title,
                              style: TextStyle(
                                  fontSize: 20,
                                  color: index == playIndex
                                      ? Colors.blue
                                      : Colors.black));
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
