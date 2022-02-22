import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musify/main.dart';
import 'package:musify/models/Song.dart';
import 'package:just_audio/just_audio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';

class PlayerScreen extends HookConsumerWidget {
  static const routeName = "Player";

  const PlayerScreen({Key? key}) : super(key: key);

  Widget _previousButton(AudioPlayer player) {
    return IconButton(
      icon: const Icon(Icons.skip_previous_rounded),
      iconSize: 42,
      onPressed: player.hasPrevious ? player.seekToPrevious : null,
    );
  }

  Widget _nextButton(AudioPlayer player) {
    return IconButton(
      icon: const Icon(Icons.skip_next_rounded),
      iconSize: 42,
      onPressed: player.hasNext ? player.seekToNext : null,
    );
  }

  Widget _wallpaper(int index, List<Song> songs, Animation<double> _animation) {
    return ScaleTransition(
      scale: _animation,
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(songs[index].wallpaper),
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
    );
  }

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
        icon: const Icon(Icons.play_arrow_rounded),
        iconSize: 64.0,
        onPressed: player.play,
      );
    } else if (processingState != ProcessingState.completed) {
      // 4
      return IconButton(
        icon: const Icon(Icons.pause_rounded),
        iconSize: 64.0,
        onPressed: player.pause,
      );
    } else {
      // 5
      return IconButton(
        icon: const Icon(Icons.replay_rounded),
        iconSize: 64.0,
        onPressed: () =>
            player.seek(Duration.zero, index: player.effectiveIndices?.first),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AnimationController _animationController = useAnimationController(
        duration: const Duration(milliseconds: 400), initialValue: 1);
    _animationController.repeat(reverse: false);
    Animation<double> _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.fastOutSlowIn,
    );

    final AudioPlayer player = ref.watch(playerProvider);
    final songs = ref.watch(songsProvider);
    player.playerStateStream.listen((playerState) {
      if (player.playing) {
        _animationController.animateTo(1);
      } else {
        _animationController.animateTo(0.5);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Now Playing',
          style: GoogleFonts.varelaRound(
            textStyle: const TextStyle(color: Colors.black),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz_rounded),
          ),
        ],
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
                child: StreamBuilder<int?>(
                  stream: player.currentIndexStream,
                  builder: (_, snapshot) {
                    final index = snapshot.data ?? 0;
                    return _wallpaper(index, songs, _animation);
                  },
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StreamBuilder<int?>(
                        stream: player.currentIndexStream,
                        builder: (_, snapshot) {
                          final index = snapshot.data ?? 0;

                          return Text(
                            songs[index].name,
                            style: GoogleFonts.varelaRound(
                              textStyle: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                      // const SizedBox(height: 5),
                      StreamBuilder<int?>(
                        stream: player.currentIndexStream,
                        builder: (_, snapshot) {
                          final index = snapshot.data ?? 0;

                          return Text(
                            songs[index].artistName,
                            style: GoogleFonts.varelaRound(
                              textStyle: const TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          );
                        },
                      ),
                      StreamBuilder<Duration?>(
                        stream: player.positionStream,
                        builder: (_, snapshot) {
                          Duration progress = snapshot.data ?? Duration.zero;

                          return StreamBuilder<Duration?>(
                              stream: player.bufferedPositionStream,
                              builder: (_, snapshot2) {
                                return ProgressBar(
                                  progress: progress,
                                  buffered: snapshot2.data,
                                  total: player.duration ?? Duration.zero,
                                  onSeek: (duration) {
                                    player.seek(duration,
                                        index: player.currentIndex);
                                  },
                                );
                              });
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          StreamBuilder<SequenceState?>(
                            stream: player.sequenceStateStream,
                            builder: (_, __) {
                              return _previousButton(player);
                            },
                          ),
                          StreamBuilder<PlayerState>(
                            stream: player.playerStateStream,
                            builder: (context, snapshot) {
                              final playerState = snapshot.data;
                              return _playerButton(playerState, player);
                            },
                          ),
                          StreamBuilder<SequenceState?>(
                            stream: player.sequenceStateStream,
                            builder: (_, __) {
                              return _nextButton(player);
                            },
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.format_quote_rounded,
                                color: Colors.white,
                              ),
                              iconSize: 25,
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.share_rounded),
                              color: Colors.white,
                              iconSize: 25,
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.list_rounded),
                              color: Colors.white,
                              iconSize: 35,
                            ),
                          ],
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(35),
                          color: const Color(0xff14345B),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
