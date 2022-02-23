import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:musify/main.dart';
import 'package:musify/models/Song.dart';
import 'package:musify/screens/player_screen.dart';

class MiniPlayer extends HookConsumerWidget {
  const MiniPlayer({Key? key}) : super(key: key);

  Widget _playerButton(PlayerState? playerState, AudioPlayer player) {
    // 1
    final processingState = playerState?.processingState;
    if (processingState == ProcessingState.loading ||
        processingState == ProcessingState.buffering) {
      // 2
      return Container(
        margin: const EdgeInsets.all(8.0),
        width: 36.0,
        height: 36.0,
        child: const CircularProgressIndicator(),
      );
    } else if (player.playing != true) {
      // 3
      return IconButton(
        icon: const Icon(Icons.play_arrow_rounded),
        iconSize: 36.0,
        onPressed: player.play,
      );
    } else if (processingState != ProcessingState.completed) {
      // 4
      return IconButton(
        icon: const Icon(Icons.pause_rounded),
        iconSize: 36.0,
        onPressed: player.pause,
      );
    } else {
      // 5
      return IconButton(
        icon: const Icon(Icons.replay_rounded),
        iconSize: 36.0,
        onPressed: () =>
            player.seek(Duration.zero, index: player.effectiveIndices?.first),
      );
    }
  }

  Widget _nextButton(AudioPlayer player) {
    return IconButton(
      icon: const Icon(Icons.skip_next_rounded),
      iconSize: 42,
      onPressed: player.hasNext ? player.seekToNext : null,
    );
  }

  Widget _wallpaper(int index, List<Song> songs) {
    return Container(
      margin: const EdgeInsets.only(
        right: 15,
      ),
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(songs[index].wallpaper),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);
    final songs = ref.watch(songsProvider);

    return StreamBuilder<PlayerState>(
      stream: player.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;

        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, PlayerScreen.routeName);
          },
          child: Row(
            children: [
              _wallpaper(player.currentIndex ?? 0, songs),
              Text(
                songs[player.currentIndex ?? 0].name,
                style: GoogleFonts.varelaRound(
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const Expanded(
                child: Text(''),
              ),
              _playerButton(playerState, player),
              _nextButton(player),
            ],
          ),
        );
      },
    );
  }
}
