import 'package:flutter/material.dart';
import 'package:musify/screens/album_screen.dart';
import 'package:musify/screens/listen_now_screen.dart';
import 'package:musify/screens/player_screen.dart';

void main() => runApp(const Musify());

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
