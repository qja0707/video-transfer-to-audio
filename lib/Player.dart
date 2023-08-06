import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter/services.dart';

class Player extends StatefulWidget {
  final String _videoID;
  final Function goHomeScreen;

  const Player(this._videoID, this.goHomeScreen, {super.key});

  @override
  PlayerState createState() => PlayerState();
}

class PlayerState extends State<Player> {
  late String _videoID;
  late Function goHomeScreen;

  late YoutubePlayerController _controller;

  void showNavigationBar() {
    debugPrint('show');

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
  }

  @override
  void initState() {
    super.initState();

    _videoID = widget._videoID;
    goHomeScreen = widget.goHomeScreen;

    _controller = YoutubePlayerController(
      initialVideoId: _videoID,
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    );
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
                  key: ObjectKey(_controller),
                  controller: _controller,
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
