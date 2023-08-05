import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter/services.dart';

class Player extends StatefulWidget {
  final String _videoID;
  final String _videoTitle;

  Player(this._videoID, this._videoTitle);

  @override
  PlayerState createState() => PlayerState(_videoID, _videoTitle);
}

class PlayerState extends State<Player> {
  String _videoID;
  String _videoTitle;

  PlayerState(this._videoID, this._videoTitle);

  late YoutubePlayerController _controller;

  // late double _screenWidth;

  void _hideNavigationBar() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  void _show() {
    debugPrint('show');
    // This will show both the top status bar and the bottom navigation bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
  }

  @override
  void initState() {
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
    // _screenWidth = MediaQuery.of(context).size.width;

    _hideNavigationBar();
  }

  @override
  void dispose() {
    debugPrint("dispose~!~!");
    _show();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            '$_videoTitle',
            style: TextStyle(fontSize: 20.0),
          ),
        ),
        body: Center(
          child: Column(
            children: [
              Container(
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
              OutlinedButton(
                  onPressed: _hideNavigationBar, child: Text("hide")),
              OutlinedButton(onPressed: _show, child: Text("show")),
              Container(
                width: 100,
                height: 100,
                color: Colors.red,
              )
            ],
          ),
        ));
  }
}
