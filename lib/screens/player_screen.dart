import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musify/constants.dart';
import 'package:musify/models/Song.dart';
import 'package:just_audio/just_audio.dart';

class PlayerScreen extends StatefulWidget {
  static const routeName = "Player";

  const PlayerScreen({Key? key}) : super(key: key);

  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final _player = AudioPlayer();
  Song? _song;

  Future<void> stopSetAndPlay() async {
    await _player.stop();
    await setAndPlay();
  }

  Future<void> setAndPlay() async {
    var duration = await _player
        .setUrl("$kMusifyHost/musifyserver/stream?k=${_song?.url}");
    print(duration);
    await _player.play();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      setAndPlay();
    });
  }

  @override
  Widget build(BuildContext context) {
    final oldSong = _song;
    final song = ModalRoute.of(context)!.settings.arguments as Song;
    _song = song;
    if (song.url != oldSong?.url) {
      stopSetAndPlay();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Now Playing',
          style: GoogleFonts.varelaRound(
            textStyle: const TextStyle(color: Colors.black),
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(song.wallpaper),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
