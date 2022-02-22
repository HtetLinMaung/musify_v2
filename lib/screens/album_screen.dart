import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:musify/components/layout.dart';
import 'package:musify/constants.dart';
import 'package:musify/main.dart';
import 'package:musify/models/Song.dart';
import 'package:musify/models/album.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:musify/screens/player_screen.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../utils/musify_http_client.dart';

class AlbumScreen extends HookConsumerWidget {
  static const routeName = 'Album';

  const AlbumScreen({Key? key}) : super(key: key);

  Future<List<Song>> fetchSongs(String albumId) async {
    var songRes =
        await MusifyHttpClient.get("/musifyserver/songs?albums=$albumId");
    if (songRes['code'] != 200) {
      return [];
    }
    var songs = <Song>[];
    for (var s in songRes['data']) {
      songs.add(Song(
        id: s['_id'],
        name: s['name'],
        wallpaper: "$kMusifyHost${s['wallpaper']}",
        url: s['url'],
        duration: s['duration'],
        artistName: s['artist']['name'],
      ));
    }
    return songs;
  }

  String fmtDuration(int ms) {
    var sec = ms ~/ 1000;
    var min = sec ~/ 60;
    sec = sec % 60;
    return "$min:${sec < 10 ? '0' : ''}$sec";
  }

  Future<void> playSong(List<Song> songs, AudioPlayer player, int index) async {
    var children = songs
        .map((s) => AudioSource.uri(
            Uri.parse("$kMusifyHost/musifyserver/stream?k=${s.url}")))
        .toList();
    await player
        .setAudioSource(ConcatenatingAudioSource(children: children))
        .catchError((error) {
      // catch load errors: 404, invalid url ...
      print("An error occured $error");
    });
    await player.seek(Duration.zero, index: index);
    if (player.playing) {
      await player.stop();
    }
    await player.play();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AudioPlayer player = ref.watch(playerProvider);
    final album = ModalRoute.of(context)!.settings.arguments as Album;

    return Layout(
      appBar: AppBar(
        title: Text(
          album.name,
          style: GoogleFonts.varelaRound(
            textStyle: const TextStyle(color: Colors.black),
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: FutureBuilder<List<Song>>(
        future: fetchSongs(album.id),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var songs = snapshot.data ?? [];
            return ListView.builder(
              itemCount: songs.length,
              itemBuilder: (context, index) {
                var song = songs[index];
                return ListTile(
                  leading: Container(
                    height: 45,
                    width: 45,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(song.wallpaper),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  title: Text(
                    song.name,
                    style: GoogleFonts.varelaRound(
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  subtitle: Text(
                    song.artistName,
                    style: GoogleFonts.varelaRound(),
                  ),
                  trailing: const Icon(
                    Icons.more_horiz,
                    color: Colors.black,
                  ),
                  onTap: () {
                    ref.read(songsProvider.notifier).state = songs;
                    playSong(songs, player, index);
                    Navigator.pushNamed(context, PlayerScreen.routeName);
                  },
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
