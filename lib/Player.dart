import 'package:flutter/material.dart';
import 'package:helloworld/assets/colors.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter/services.dart';

class Player extends StatefulWidget {
  final Function goHomeScreen;
  final YoutubePlayerController _youtubePlayerController;
  final Function youtubePlayerOnReady;

  const Player(this.goHomeScreen, this._youtubePlayerController,
      this.youtubePlayerOnReady,
      {super.key});

  @override
  PlayerState createState() => PlayerState();
}

class PlayerState extends State<Player> with TickerProviderStateMixin {
  late Function goHomeScreen;
  late YoutubePlayerController _youtubePlayerController;
  late Function youtubePlayerOnReady;

  late AnimationController indicatorController;

  void showNavigationBar() {
    debugPrint('show');

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
  }

  @override
  void initState() {
    super.initState();

    goHomeScreen = widget.goHomeScreen;
    _youtubePlayerController = widget._youtubePlayerController;
    youtubePlayerOnReady = widget.youtubePlayerOnReady;

    indicatorController = AnimationController(
        vsync: this, lowerBound: 0, upperBound: 1, value: 0);

    indicatorController.addListener(() {});
  }

  @override
  void dispose() {
    debugPrint("dispose~!~!");
    showNavigationBar();

    indicatorController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 0,
                height: 0,
                child: YoutubePlayer(
                  key: ObjectKey(_youtubePlayerController),
                  controller: _youtubePlayerController,
                  actionsPadding: const EdgeInsets.only(left: 16.0),
                  bottomActions: [
                    CurrentPosition(),
                    const SizedBox(width: 10.0),
                    ProgressBar(isExpanded: true),
                    const SizedBox(width: 10.0),
                    RemainingDuration(),
                    //FullScreenButton(),
                  ],
                  onReady: () {
                    debugPrint("controller onready");
                    youtubePlayerOnReady();
                  },
                ),
              ),
              GestureDetector(
                  onLongPressStart: (details) {
                    debugPrint("long press down");

                    indicatorController.animateTo(1,
                        duration: const Duration(seconds: 3));
                  },
                  onLongPressEnd: (longPressEndDetails) {
                    debugPrint("long press up");

                    if (indicatorController.value == 1) {
                      goHomeScreen();

                      showNavigationBar();
                    }

                    indicatorController.animateTo(0,
                        duration: const Duration(seconds: 0));
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: CircularProgressIndicator(
                          color: mainBlue,
                          value: indicatorController.value,
                          strokeWidth: 7,
                        ),
                      ),
                      Container(
                        width: 50,
                        height: 50,
                        color: Colors.cyan,
                      ),
                    ],
                  )
                  //
                  )
            ],
          ),
        ));
  }
}
