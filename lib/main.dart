import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:helloworld/player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

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

  int _counter = 0;

  bool isPlaying = false;

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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
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
                          child: Text("show")),
                      Row(
                        children: [
                          IconButton(
                              iconSize: 72,
                              onPressed: handlePressPlay,
                              icon: isPlaying
                                  ? const Icon(Icons.pause_outlined)
                                  : const Icon(Icons.play_arrow_outlined)),
                        ],
                      )
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
