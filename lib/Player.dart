import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter/services.dart';

class Player extends StatefulWidget {
  final Function goHomeScreen;
  final YoutubePlayerController _youtubePlayerController;

  const Player(this.goHomeScreen, this._youtubePlayerController, {super.key});

  @override
  PlayerState createState() => PlayerState();
}

class PlayerState extends State<Player> {
  late Function goHomeScreen;
  late YoutubePlayerController _youtubePlayerController;

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
  }

  @override
  void dispose() {
    debugPrint("dispose~!~!");
    showNavigationBar();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height,
        child: Center(
          child: Column(
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
                ),
              ),
              OutlinedButton(onPressed: () => {}, child: Text("hide")),
              OutlinedButton(onPressed: showNavigationBar, child: Text("show")),
              OutlinedButton(
                  onPressed: () => {goHomeScreen(), showNavigationBar()},
                  child: Text('go back home')),
              Container(
                width: 100,
                height: 100,
                color: Colors.cyan,
              )
            ],
          ),
        ));
  }
}
