import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musify/constants.dart';
import 'package:musify/main.dart';
import 'package:musify/models/Song.dart';
import 'package:just_audio/just_audio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PlayerScreen extends HookConsumerWidget {
  static const routeName = "Player";

  const PlayerScreen({Key? key}) : super(key: key);

  Widget _playerButton(PlayerState? playerState, AudioPlayer player) {
    // 1
    final processingState = playerState?.processingState;
    if (processingState == ProcessingState.loading ||
        processingState == ProcessingState.buffering) {
      // 2
      return Container(
        margin: const EdgeInsets.all(8.0),
        width: 64.0,
        height: 64.0,
        child: const CircularProgressIndicator(),
      );
    } else if (player.playing != true) {
      // 3
      return IconButton(
        icon: const Icon(Icons.play_arrow),
        iconSize: 64.0,
        onPressed: player.play,
      );
    } else if (processingState != ProcessingState.completed) {
      // 4
      return IconButton(
        icon: const Icon(Icons.pause),
        iconSize: 64.0,
        onPressed: player.pause,
      );
    } else {
      // 5
      return IconButton(
        icon: const Icon(Icons.replay),
        iconSize: 64.0,
        onPressed: () =>
            player.seek(Duration.zero, index: player.effectiveIndices?.first),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AudioPlayer player = ref.watch(playerProvider);
    final song = ModalRoute.of(context)!.settings.arguments as Song;

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
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        StreamBuilder<PlayerState>(
                          stream: player.playerStateStream,
                          builder: (context, snapshot) {
                            final playerState = snapshot.data;
                            return _playerButton(playerState, player);
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
