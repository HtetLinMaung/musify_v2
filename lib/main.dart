import 'package:flutter/material.dart';
import 'package:musify/models/Song.dart';
import 'package:musify/screens/album_screen.dart';
import 'package:musify/screens/listen_now_screen.dart';
import 'package:musify/screens/player_screen.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';

final playerProvider = Provider((_) => AudioPlayer());
final songsProvider = StateProvider((_) => <Song>[]);

void main() => runApp(const ProviderScope(
      child: Musify(),
    ));

class Musify extends StatelessWidget {
  const Musify({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        ListenNowScreen.routeName: (context) => const ListenNowScreen(),
        AlbumScreen.routeName: (context) => const AlbumScreen(),
        PlayerScreen.routeName: (context) => const PlayerScreen(),
      },
      initialRoute: ListenNowScreen.routeName,
    );
  }
}
